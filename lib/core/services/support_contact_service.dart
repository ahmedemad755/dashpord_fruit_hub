import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/utils/open_external_url.dart';

class SupportContactService {
  SupportContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String settingsCollection = 'app_settings';
  static const String supportDocument = 'support';
  static const String supportPhoneField = 'phoneNumber';

  final FirebaseFirestore _firestore;

  Future<String> getSupportPhoneNumber() async {
    final snapshot = await _firestore
        .collection(settingsCollection)
        .doc(supportDocument)
        .get(const GetOptions(source: Source.server));

    return snapshot.data()?[supportPhoneField]?.toString().trim() ?? '';
  }

  Future<bool> openSupportWhatsApp() async {
    final supportPhone = await getSupportPhoneNumber();
    final whatsappNumber = normalizeWhatsAppNumber(supportPhone);

    if (whatsappNumber.isEmpty) {
      return false;
    }

    final uri = Uri.https('wa.me', '/$whatsappNumber', {
      'text': 'استفسار بخصوص رفض الصيدلية',
    });

    return openExternalUrl(uri);
  }

  String normalizeWhatsAppNumber(String phone) {
    var number = phone.replaceAll(RegExp(r'[^0-9+]'), '').trim();

    if (number.startsWith('+')) {
      number = number.substring(1);
    }

    if (number.startsWith('00')) {
      number = number.substring(2);
    }

    if (number.startsWith('0')) {
      number = '20${number.substring(1)}';
    }

    return number.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
