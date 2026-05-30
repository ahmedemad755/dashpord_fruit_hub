import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';
import 'package:archive/archive.dart';

// استيراد الكلاسات الحقيقية والأساسية من مشروعك لمنع التكرار والتعارض
import '../../../../core/repos/imag_repo/imag_repo.dart';
import '../../../../core/services/account_status_service.dart';

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
const String supabaseUrl = 'https://your-supabase-url.supabase.co'; 

bool _parseFlexibleBool(Object? value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized =
      value.toString().trim().toLowerCase().replaceAll('"', '').replaceAll("'", "");
  if (normalized.isEmpty) return false;

  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'y' ||
      normalized == 'required' ||
      normalized == 'مطلوب' ||
      normalized == 'نعم' ||
      normalized == 'requires_prescription' ||
      normalized == 'prescription_required' ||
      normalized == 'required_prescription';
}

class GlobalProductData {
  const GlobalProductData({
    required this.barcode,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.isPrescriptionRequired,
    required this.rawData,
  });

  final String barcode;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final bool isPrescriptionRequired;
  final Map<String, dynamic> rawData;

  factory GlobalProductData.fromFirestore(
    String barcode,
    Map<String, dynamic> data,
  ) {
    String readString(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    return GlobalProductData(
      barcode: barcode,
      name: readString(['name', 'product_name', 'productName']),
      category: readString(['category', 'categoryName']),
      description: readString(['description', 'desc']),
      imageUrl: readString([
        'image_url',
        'imageUrl',
        'imageurl',
        'global_image_url',
      ]),
      isPrescriptionRequired: _parseFlexibleBool(
        data['isPrescriptionRequired'] ??
            data['is_prescription_required'] ??
            data['isPrescription'] ??
            data['requiresPrescription'] ??
            data['prescriptionRequired'] ??
            data['prescription'],
      ),
      rawData: data,
    );
  }
}

class BulkProductMatch {
  const BulkProductMatch({
    required this.barcode,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.isPrescriptionRequired,
    required this.globalProduct,
    required this.expirationDate,
    required this.rowNumber,
    required this.hasFoundHeaderForImage, 
    required this.hasFoundHeaderForName,  
  });

  final String barcode;
  final num price;
  final num cost;
  final int quantity;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final bool isPrescriptionRequired;
  final GlobalProductData? globalProduct;
  final DateTime expirationDate;
  final int rowNumber;
  final bool hasFoundHeaderForImage;
  final bool hasFoundHeaderForName;

  String get productName => _preferGlobalOrSheet(name, globalProduct?.name ?? '', hasFoundHeaderForName);
  String get productCategory => _preferGlobalOrSheet(category, globalProduct?.category ?? '', hasFoundHeaderForName);
  String get productDescription => _preferGlobalOrSheet(description, globalProduct?.description ?? '', hasFoundHeaderForName);
  String get productImageUrl => _preferGlobalOrSheet(imageUrl, globalProduct?.imageUrl ?? '', hasFoundHeaderForImage);
  bool get productIsPrescriptionRequired => globalProduct?.isPrescriptionRequired ?? isPrescriptionRequired;

  bool get isMatched => globalProduct != null || productName.isNotEmpty;

  static String _preferGlobalOrSheet(String sheetValue, String globalValue, bool hasExplicitHeader) {
    if (!hasExplicitHeader && globalValue.trim().isNotEmpty) {
      return globalValue.trim();
    }
    final value = sheetValue.trim();
    return value.isNotEmpty ? value : globalValue.trim();
  }

  BulkProductMatch copyWith({
    String? barcode,
    num? price,
    num? cost,
    int? quantity,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    bool? isPrescriptionRequired,
    GlobalProductData? globalProduct,
    DateTime? expirationDate,
    int? rowNumber,
    bool? hasFoundHeaderForImage,
    bool? hasFoundHeaderForName,
  }) {
    return BulkProductMatch(
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrescriptionRequired: isPrescriptionRequired ?? this.isPrescriptionRequired,
      globalProduct: globalProduct ?? this.globalProduct,
      expirationDate: expirationDate ?? this.expirationDate,
      rowNumber: rowNumber ?? this.rowNumber,
      hasFoundHeaderForImage: hasFoundHeaderForImage ?? this.hasFoundHeaderForImage,
      hasFoundHeaderForName: hasFoundHeaderForName ?? this.hasFoundHeaderForName,
    );
  }
}

class GlobalProductMatchingService {
  GlobalProductMatchingService({
    required FirebaseFirestore firestore,
    required ImagRepo imageRepo,
    required AccountStatusService accountStatusService,
  })  : _firestore = firestore,
        _imageRepo = imageRepo,
        _accountStatusService = accountStatusService;

  final FirebaseFirestore _firestore;
  final ImagRepo _imageRepo;
  final AccountStatusService _accountStatusService;

  Future<GlobalProductData?> findByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;

    final doc = await _firestore
        .collection('global_products')
        .doc(normalizedBarcode)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return GlobalProductData.fromFirestore(normalizedBarcode, doc.data()!);
  }

  Future<List<BulkProductMatch>> matchExcelBytes(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) return const [];

      final firstSheet = excel.tables.values.first;
      final rows = firstSheet.rows;
      if (rows.isEmpty) return const [];

      return _matchExcelRows(
        rows: rows,
        looksLikeHeader: _looksLikeHeader,
        readString: _cellToString,
        readNum: _cellToNum,
        readDate: _cellToDate,
      );
    } catch (_) {
      final rows = _readRowsFromCsvOrXlsxHandmade(bytes);
      if (rows.isEmpty) return const [];

      return _matchExcelRows(
        rows: rows,
        looksLikeHeader: _stringRowLooksLikeHeader,
        readString: _stringCell,
        readNum: _stringCellToNum,
        readDate: _stringCellToDate,
      );
    }
  }

  Future<List<BulkProductMatch>> _matchExcelRows<T>({
    required List<T> rows,
    required bool Function(T row) looksLikeHeader,
    required String Function(T row, int index) readString,
    required num Function(T row, int index) readNum,
    required DateTime? Function(T row, int index) readDate,
  }) async {
    final hasHeader = looksLikeHeader(rows.first);
    final headerMap = hasHeader
        ? _buildHeaderMap(rows.first, readString)
        : const <String, int>{};
    
    final hasFoundHeaderForImage = _hasAnyHeader(headerMap, const ['imageurl', 'image', 'صورة']);
    final hasFoundHeaderForName = _hasAnyHeader(headerMap, const ['name', 'اسم']);

    final startIndex = hasHeader ? 1 : 0;
    final matches = <BulkProductMatch>[];

    for (var index = startIndex; index < rows.length; index++) {
      final row = rows[index];
      
      final barcode = _readByHeader(row, headerMap, readString, const ['barcode', 'code', 'كود', 'باركود'], 0);
      if (barcode.isEmpty) continue;

      final price = _readNumByHeader(row, headerMap, readNum, const ['price', 'السعر'], 1);
      final cost = _readNumByHeader(row, headerMap, readNum, const ['cost', 'التكلفة'], 2);
      final quantity = _readNumByHeader(row, headerMap, readNum, const ['quantity', 'qty', 'الكمية'], 3).toInt();
      
      final expirationDate = _readDateByHeader(row, headerMap, readDate, const ['expirationdate', 'expirydate', 'تاريخ'], 4) ?? DateTime.now();

      final name = _readByHeader(row, headerMap, readString, const ['name', 'اسم'], -1);
      final category = _readByHeader(row, headerMap, readString, const ['category', 'تصنيف'], -1);
      final description = _readByHeader(row, headerMap, readString, const ['description', 'وصف'], -1);
      final imageUrl = _readByHeader(row, headerMap, readString, const ['imageurl', 'image', 'صورة'], -1);
      final prescriptionText = _readByHeader(
        row,
        headerMap,
        readString,
        const [
          'isprescriptionrequired',
          'is prescription required',
          'requiresprescription',
          'requires prescription',
          'prescriptionrequired',
          'prescription required',
          'prescription',
          'روشتة',
        ],
        -1,
      );

      final globalProduct = await findByBarcode(barcode);
      final isPrescriptionRequired =
          globalProduct?.isPrescriptionRequired ?? _parseBool(prescriptionText);

      matches.add(BulkProductMatch(
        barcode: barcode,
        price: price,
        cost: cost,
        quantity: quantity,
        name: name,
        category: category,
        description: description,
        imageUrl: imageUrl,
        isPrescriptionRequired: isPrescriptionRequired, 
        expirationDate: expirationDate,
        globalProduct: globalProduct,
        rowNumber: index + 1,
        hasFoundHeaderForImage: hasFoundHeaderForImage,
        hasFoundHeaderForName: hasFoundHeaderForName,
      ));
    }

    return matches;
  }

  bool _hasAnyHeader(Map<String, int> headerMap, List<String> aliases) {
    for (final alias in aliases) {
      if (headerMap.containsKey(_normalizeHeader(alias))) return true;
    }
    return false;
  }

  Map<String, int> _buildHeaderMap<T>(
    T row,
    String Function(T row, int index) readString,
  ) {
    final headers = <String, int>{};
    for (var index = 0; index < 30; index++) {
      final rawHeader = readString(row, index);
      if (rawHeader.isEmpty) continue;
      
      final normalized = _normalizeHeader(rawHeader);
      if (normalized.isNotEmpty) {
        headers[normalized] = index;
      }
    }
    return headers;
  }

  String _readByHeader<T>(T row, Map<String, int> headerMap, String Function(T row, int index) readString, List<String> aliases, int fallbackIndex) {
    for (final alias in aliases) {
      final index = headerMap[_normalizeHeader(alias)];
      if (index != null) return readString(row, index).trim();
    }
    if (fallbackIndex < 0) return '';
    return readString(row, fallbackIndex).trim();
  }

  num _readNumByHeader<T>(T row, Map<String, int> headerMap, num Function(T row, int index) readNum, List<String> aliases, int fallbackIndex) {
    for (final alias in aliases) {
      final index = headerMap[_normalizeHeader(alias)];
      if (index != null) return readNum(row, index);
    }
    if (fallbackIndex < 0) return 0;
    return readNum(row, fallbackIndex);
  }

  DateTime? _readDateByHeader<T>(T row, Map<String, int> headerMap, DateTime? Function(T row, int index) readDate, List<String> aliases, int fallbackIndex) {
    for (final alias in aliases) {
      final index = headerMap[_normalizeHeader(alias)];
      if (index != null) return readDate(row, index);
    }
    if (fallbackIndex < 0) return null;
    return readDate(row, fallbackIndex);
  }

  Future<void> commitMatchedProducts({
    required String pharmacyId,
    required String pharmacyName,
    required double pharmacyLat,
    required double pharmacyLng,
    required List<BulkProductMatch> matches,
  }) async {
    final matchedRows = matches.where((match) => match.isMatched).toList();
    if (matchedRows.isEmpty) return;

    if (pharmacyId.trim().isEmpty) {
      throw Exception('تعذر تحديد الصيدلية لعملية الرفع الجماعي');
    }

    await _accountStatusService.ensureAccountCanWrite(pharmacyId);

    WriteBatch batch = _firestore.batch();
    var operationCount = 0;
    final uploadedImageUrls = <String, String>{};

    Future<void> commitIfFull() async {
      if (operationCount < 450) return;
      await batch.commit();
      batch = _firestore.batch();
      operationCount = 0;
    }

    for (final match in matchedRows) {
      final productDocId = '${match.barcode}_$pharmacyId';
      
      final imageUrl = await _siphonImageToSupabase(match.productImageUrl, uploadedImageUrls);
      final productName = match.productName;
      final productCategory = match.productCategory;
      final productDescription = match.productDescription;

      final productData = {
        'name': productName,
        'price': match.price,
        'cost': match.cost,
        'sellingcount': 0,
        'code': match.barcode,
        'description': productDescription,
        'imageurl': imageUrl,
        'global_image_url': imageUrl,
        'averageRating': 0,
        'ratingcount': 0,
        'expirationDate': Timestamp.fromDate(match.expirationDate),
        'unitAmount': match.quantity,
        'reviews': const [],
        'hasDiscount': false,
        'discountPercentage': 0,
        'pharmacyId': pharmacyId,
        'isAvailable': true,
        'category': productCategory,
        'isPrescriptionRequired': match.productIsPrescriptionRequired,
        'pharmacyName': pharmacyName,
        'pharmacyLat': pharmacyLat,
        'pharmacyLng': pharmacyLng,
        'globalProductId': match.barcode,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final pharmacyProductRef = _firestore.collection('pharmacies').doc(pharmacyId).collection('products').doc(match.barcode);
      final legacyProductRef = _firestore.collection('products').doc(productDocId);
      final inventoryRef = _firestore.collection('inventory').doc(productDocId);

      batch.set(pharmacyProductRef, productData, SetOptions(merge: true));
      batch.set(legacyProductRef, productData, SetOptions(merge: true));
      batch.set(inventoryRef, {
        'productId': productDocId,
        'productName': productName,
        'quantity': FieldValue.increment(match.quantity),
        'pharmacyId': pharmacyId,
        'category': productCategory,
        'expiryDate': Timestamp.fromDate(match.expirationDate),
        'costPrice': match.cost,
        'sellingPrice': match.price,
        'productImageUrl': imageUrl,
        'code': match.barcode,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      operationCount += 3;
      await commitIfFull();
    }

    if (operationCount > 0) {
      await batch.commit();
    }
  }

  Future<String> _siphonImageToSupabase(String imageUrl, Map<String, String> uploadedImageUrls) async {
    final normalizedUrl = imageUrl.trim();
    if (normalizedUrl.isEmpty || _isSupabaseStorageUrl(normalizedUrl)) return normalizedUrl;
    if (kIsWeb) return normalizedUrl;

    final cachedUrl = uploadedImageUrls[normalizedUrl];
    if (cachedUrl != null) return cachedUrl;

    // استدعاء الميثود المباشرة من الـ Repo الفعلي لمشروعك بعد حل الـ Result wrapper إذا وُجد
    final uploadResult = await _imageRepo.uploadImageFromUrl(normalizedUrl);
    
    // التعامل الذكي مع الـ Either (FP Dart) إذا كانت الميثود ترجع Left/Right
    return uploadResult.fold(
      (failure) => normalizedUrl,
      (supabaseUrl) {
        uploadedImageUrls[normalizedUrl] = supabaseUrl;
        return supabaseUrl;
      },
    );
  }

  bool _isSupabaseStorageUrl(String imageUrl) {
    return imageUrl.startsWith(supabaseUrl) && imageUrl.contains('/storage/v1/object/public/');
  }

  bool _looksLikeHeader(List<Data?> row) {
    if (row.isEmpty) return false;
    final firstCell = _cleanCellValue(row[0]?.value).toLowerCase();
    return firstCell == 'barcode' || firstCell == 'code' || firstCell == 'كود' || firstCell == 'باركود';
  }

  bool _stringRowLooksLikeHeader(List<String> row) {
    if (row.isEmpty) return false;
    final firstCell = row[0].trim().toLowerCase();
    return firstCell == 'barcode' || firstCell == 'code' || firstCell == 'كود' || firstCell == 'باركود';
  }

  String _cellToString(List<Data?> row, int index) {
    if (index >= row.length) return '';
    return _cleanCellValue(row[index]?.value);
  }

  String _cleanCellValue(dynamic rawValue) {
    if (rawValue == null) return '';
    
    if (rawValue is TextCellValue) return rawValue.value.toString().trim();
    if (rawValue is IntCellValue) return rawValue.value.toString();
    if (rawValue is DoubleCellValue) return rawValue.value.toString();
    if (rawValue is BoolCellValue) return rawValue.value.toString();
    if (rawValue is DateCellValue) return rawValue.toString().trim();
    if (rawValue is DateTimeCellValue) return rawValue.toString().trim();
    
    final cellStr = rawValue.toString();
    if (cellStr.contains('_value:')) {
      final match = RegExp(r'_value:\s*([^\},]+)').firstMatch(cellStr);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    return cellStr.trim();
  }

  DateTime? _cellToDate(List<Data?> row, int index) {
    if (index >= row.length) return null;
    final value = row[index]?.value;
    if (value == null) return null;
    if (value is DateCellValue || value is DateTimeCellValue) {
      return DateTime.tryParse(value.toString().trim());
    }
    return _parseDate(_cleanCellValue(value));
  }

  num _cellToNum(List<Data?> row, int index) {
    if (index >= row.length) return 0;
    final value = row[index]?.value;
    if (value == null) return 0;
    if (value is IntCellValue) return value.value;
    if (value is DoubleCellValue) return value.value;
    if (value is BoolCellValue) return value.value ? 1 : 0;
    return _parseNum(_cleanCellValue(value));
  }

  List<List<String>> _readRowsFromCsvOrXlsxHandmade(Uint8List bytes) {
    try {
      final rawContent = utf8.decode(bytes, allowMalformed: true);
      if (!rawContent.contains('xl/')) {
        final lines = const LineSplitter().convert(rawContent);
        final csvRows = <List<String>>[];

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          final cells = <String>[];
          final buffer = StringBuffer();
          var inQuotes = false;

          for (var i = 0; i < line.length; i++) {
            final char = line[i];
            if (char == '"') {
              inQuotes = !inQuotes; 
            } else if (char == ',' && !inQuotes) {
              cells.add(buffer.toString().trim());
              buffer.clear();
            } else {
              buffer.write(char);
            }
          }
          cells.add(buffer.toString().trim());
          csvRows.add(cells);
        }
        return csvRows;
      }
    } catch (_) {}
    return _readRowsFromXlsx(bytes);
  }

  List<List<String>> _readRowsFromXlsx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final workbookXml = _archiveText(archive, 'xl/workbook.xml');
    final workbookRelsXml = _archiveText(archive, 'xl/_rels/workbook.xml.rels');

    if (workbookXml == null || workbookRelsXml == null) return const [];

    final workbook = XmlDocument.parse(workbookXml);
    final rels = XmlDocument.parse(workbookRelsXml);
    final firstSheet = _firstOrNull(workbook.findAllElements('sheet'));
    if (firstSheet == null) return const [];

    final relationId = firstSheet.getAttribute('id', namespace: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships') ?? firstSheet.getAttribute('r:id');
    if (relationId == null) return const [];

    final relationship = _firstOrNull(rels.findAllElements('Relationship').where((node) => node.getAttribute('Id') == relationId));
    final target = relationship?.getAttribute('Target');
    if (target == null) return const [];

    final sheetPath = _resolveXlsxPath('xl', target);
    final sheetXml = _archiveText(archive, sheetPath);
    if (sheetXml == null) return const [];

    final sharedStrings = _readSharedStrings(archive);
    final sheet = XmlDocument.parse(sheetXml);
    final parsedRows = <List<String>>[];

    for (final rowNode in sheet.findAllElements('row')) {
      final row = <String>[];
      var fallbackColumnIndex = 0;

      for (final cellNode in rowNode.findElements('c')) {
        final cellRef = cellNode.getAttribute('r');
        final columnIndex = cellRef == null ? fallbackColumnIndex : _cellRefColumnIndex(cellRef);

        while (row.length <= columnIndex) {
          row.add('');
        }

        row[columnIndex] = _readXlsxCell(cellNode, sharedStrings);
        fallbackColumnIndex = columnIndex + 1;
      }

      if (row.any((cell) => cell.trim().isNotEmpty)) {
        parsedRows.add(row);
      }
    }
    return parsedRows;
  }

  String? _archiveText(Archive archive, String path) {
    final file = archive.findFile(path);
    if (file == null || !file.isFile) return null;
    file.decompress();
    return utf8.decode(file.content as List<int>, allowMalformed: true);
  }

  String _resolveXlsxPath(String baseDir, String target) {
    if (target.startsWith('/')) return target.substring(1);
    if (target.startsWith('xl/')) return target;
    return '$baseDir/$target';
  }

  List<String> _readSharedStrings(Archive archive) {
    final xml = _archiveText(archive, 'xl/sharedStrings.xml');
    if (xml == null) return const [];

    final document = XmlDocument.parse(xml);
    return document.findAllElements('si').map((node) {
      return node.findAllElements('t').map((text) => text.innerText).join();
    }).toList();
  }

  String _readXlsxCell(XmlElement cellNode, List<String> sharedStrings) {
    final type = cellNode.getAttribute('t');
    if (type == 'inlineStr') {
      return cellNode.findAllElements('t').map((node) => node.innerText).join();
    }

    final rawValue = _firstOrNull(cellNode.findElements('v'))?.innerText ?? '';
    if (type == 's') {
      final index = int.tryParse(rawValue);
      if (index == null || index < 0 || index >= sharedStrings.length) return '';
      return sharedStrings[index].trim();
    }
    return rawValue.trim();
  }

  int _cellRefColumnIndex(String cellRef) {
    var columnIndex = 0;
    for (final codeUnit in cellRef.toUpperCase().codeUnits) {
      if (codeUnit < 65 || codeUnit > 90) break;
      columnIndex = (columnIndex * 26) + (codeUnit - 64);
    }
    return columnIndex - 1;
  }

  String _stringCell(List<String> row, int index) {
    if (index >= row.length) return '';
    return row[index].trim();
  }

  num _stringCellToNum(List<String> row, int index) => _parseNum(_stringCell(row, index));

  DateTime? _stringCellToDate(List<String> row, int index) => _parseDate(_stringCell(row, index));

  num _parseNum(String value) {
    final normalized = value.trim().replaceAll(',', '');
    return num.tryParse(normalized) ?? 0;
  }

  DateTime? _parseDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    final parsedDate = DateTime.tryParse(normalized);
    if (parsedDate != null) return parsedDate;

    final serial = num.tryParse(normalized);
    if (serial == null || serial < 1) return null;
    return DateTime(1899, 12, 30).add(Duration(days: serial.floor()));
  }

  bool _parseBool(Object? value) {
    return _parseFlexibleBool(value);
  }

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  T? _firstOrNull<T>(Iterable<T> values) {
    final iterator = values.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
