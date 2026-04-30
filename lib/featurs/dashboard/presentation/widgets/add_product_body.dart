// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/const/dashboardPageTemplate.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/cusstom_textfield.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/imag_feild.dart';
import 'package:image_picker/image_picker.dart';

class AddProductBody extends StatefulWidget {
  XFile? image;
  String? name, code, description, pharmacyId;
  num? price;
  num? cost;
  int? expirationDate;
  int? unitAmount;
  bool hasDiscount = false;
  num? discountPercentage = 0;
  String? selectedCategory;
  String? pharmacyName;
  double? pharmacyLat;
  double? pharmacyLng;
  bool isPrescriptionRequired = false;

  AddProductBody({
    super.key,
    this.image,
    this.name,
    this.price,
    this.cost,
    this.code,
    this.description,
    this.expirationDate,
    this.unitAmount,
    this.pharmacyId,
    this.pharmacyName,
    this.pharmacyLat,
    this.pharmacyLng,

  });

  @override
  State<AddProductBody> createState() => _AddProductBodyState();
}

class _AddProductBodyState extends State<AddProductBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  
  // تعريف الـ Controllers هنا لمرة واحدة فقط لضمان الأداء
  late final TextEditingController expirationController;
  late final TextEditingController pharmacyNameController;
  late final TextEditingController pharmacistIdController;

  @override
  void initState() {
    super.initState();
    expirationController = TextEditingController();
    pharmacyNameController = TextEditingController();
    pharmacistIdController = TextEditingController();
    _getPharmacyIdFromPrefs();
  }

  @override
  void dispose() {
    expirationController.dispose();
    pharmacyNameController.dispose();
    pharmacistIdController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    String userData = Prefs.getString("kUserData");
    if (userData.isNotEmpty) {
      try {
        return jsonDecode(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _getPharmacyIdFromPrefs() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null && userData.isNotEmpty) {
      setState(() {
        widget.pharmacyId = userData['uId']?.toString();
        widget.pharmacyName = userData['pharmacyName']?.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 800;

    return DashboardPageTemplate(
      title: "إضافة دواء جديد",
      subtitle: "يرجى ملء البيانات بدقة لضمان ظهور المنتج بشكل صحيح للعملاء",
      content: SliverToBoxAdapter(
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            children: [
              _buildSectionTitle("بيانات الصيدلية المصدر"),
              buildReadOnlyPharmacyFields(isWeb),
              const SizedBox(height: 24),
              
              _buildSectionTitle("المعلومات الأساسية"),
              _buildResponsiveRow(isWeb, [
                buildNameField(),
                buildCategoryField(),
              ]),

              _buildResponsiveRow(isWeb, [
                buildPriceField(),
                buildCostField()
              ]),

              _buildResponsiveRow(isWeb, [
                buildCodeField(),
                buildUnitAmountField(),
              ]),

              _buildSectionTitle("الصلاحية والخيارات المتقدمة"),
              _buildResponsiveRow(isWeb, [
                buildExpirationDateField(),
                buildDiscountSection(),
              ]),

              const SizedBox(height: 16),
              buildDescriptionField(),
              const SizedBox(height: 32),

              _buildActionSection(isWeb),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets مساعدة لتحسين المظهر ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(bool isWeb, List<Widget> children) {
    if (!isWeb) {
      return Column(
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c),
        )).toList(),
      ),
    );
  }

  Widget _buildActionSection(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 40,
        runSpacing: 24,
        children: [
          SizedBox(width: isWeb ? 350 : double.infinity, child: buildImageField()),
          SizedBox(width: isWeb ? 300 : double.infinity, child: buildAddButton()),
        ],
      ),
    );
  }

  // --- الحقول البرمجية ---

  Widget buildNameField() => CustomTextFormField(
    hintText: "اسم الدواء",
    textInputType: TextInputType.text,
    onSaved: (value) => widget.name = value!,
  );

  Widget buildPriceField() => CustomTextFormField(
    hintText: "السعر الأساسي للبيع",
    textInputType: TextInputType.number,
    onSaved: (value) => widget.price = num.tryParse(value!) ?? 0,
  );

  Widget buildCostField() => CustomTextFormField(
    hintText: "تكلفة المنتج (الشراء)",
    textInputType: TextInputType.number,
    onSaved: (value) => widget.cost = num.tryParse(value!) ?? 0,
  );

  Widget buildCodeField() => CustomTextFormField(
    hintText: "كود المنتج (Barcode)",
    textInputType: TextInputType.text,
    onSaved: (value) => widget.code = value!.toLowerCase(),
  );

  Widget buildUnitAmountField() => CustomTextFormField(
    hintText: "الكمية المتوفرة بالمخزن",
    textInputType: TextInputType.number,
    onSaved: (value) => widget.unitAmount = int.tryParse(value!) ?? 0,
  );

  Widget buildDescriptionField() => CustomTextFormField(
    hintText: "وصف المنتج واستخداماته...",
    textInputType: TextInputType.multiline,
    maxLines: 4,
    onSaved: (value) => widget.description = value!,
  );

  Widget buildExpirationDateField() => CustomTextFormField(
    controller: expirationController,
    hintText: "تاريخ انتهاء الصلاحية",
    textInputType: TextInputType.datetime,
    readOnly: true,
    suffixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
    onTap: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 365)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        setState(() {
          expirationController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
          widget.expirationDate = int.parse("${pickedDate.year}${pickedDate.month.toString().padLeft(2, '0')}${pickedDate.day.toString().padLeft(2, '0')}");
        });
      }
    },
  );

  Widget buildCategoryField() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator(color: Colors.teal);

        return DropdownButtonFormField<String>(
          hint: const Text("اختر التصنيف"),
          value: widget.selectedCategory,
          items: snapshot.data!.docs.map((doc) {
            return DropdownMenuItem<String>(
              value: doc['name'].toString(),
              child: Text(doc['name'].toString()),
            );
          }).toList(),
          onChanged: (value) => setState(() => widget.selectedCategory = value),
          validator: (value) => (value == null) ? "التصنيف مطلوب" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.teal, width: 2)),
          ),
        );
      },
    );
  }

 Widget buildReadOnlyPharmacyFields(bool isWeb) {
  if (widget.pharmacyId == null) return const LinearProgressIndicator(color: Colors.teal);

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('pharmacies').doc(widget.pharmacyId).snapshots(),
    builder: (context, firestoreSnapshot) {
      if (!firestoreSnapshot.hasData || !firestoreSnapshot.data!.exists) return const SizedBox();
      
      var data = firestoreSnapshot.data!.data() as Map<String, dynamic>;
      widget.pharmacyLat = (data['lat'] as num?)?.toDouble() ?? 0.0;
      widget.pharmacyLng = (data['lng'] as num?)?.toDouble() ?? 0.0;
      
      // ✅ الحل: التحديث فقط إذا كانت القيم مختلفة وليس في كل ريندر
      if (pharmacyNameController.text != data['pharmacyName']) {
        pharmacyNameController.text = data['pharmacyName'] ?? '';
      }
      if (pharmacistIdController.text != data['pharmacistId']) {
        pharmacistIdController.text = data['pharmacistId'] ?? '';
      }

      return _buildResponsiveRow(isWeb, [
        CustomTextFormField(
          hintText: "اسم الصيدلية",
          controller: pharmacyNameController,
          readOnly: true,
          textInputType: TextInputType.text,
        ),
        CustomTextFormField(
          hintText: "معرف الصيدلي",
          controller: pharmacistIdController,
          readOnly: true,
          textInputType: TextInputType.text,
        ),
      ]);
    },
  );
}

  Widget buildDiscountSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("يتطلب روشتة طبية", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            subtitle: const Text("سيُطلب من العميل رفع صورة الروشتة", style: TextStyle(fontSize: 10)),
            value: widget.isPrescriptionRequired,
            activeColor: Colors.red,
            onChanged: (val) => setState(() => widget.isPrescriptionRequired = val),
          ),
          const Divider(height: 20),
          SwitchListTile(
            title: const Text("تفعيل الخصم", style: TextStyle(fontSize: 14)),
            value: widget.hasDiscount,
            activeColor: Colors.teal,
            onChanged: (val) => setState(() => widget.hasDiscount = val),
          ),
          if (widget.hasDiscount)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CustomTextFormField(
                hintText: "نسبة الخصم %",
                textInputType: TextInputType.number,
                onSaved: (value) => widget.discountPercentage = num.tryParse(value!) ?? 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildImageField() => ImagFeild(onImagePicked: (image) => setState(() => widget.image = image as XFile?));

  Widget buildAddButton() => GradientButton(
    gradientColors: const [Colors.teal, Colors.green],
    label: "تأكيد وإضافة الدواء",
onPressed: () {
  if (widget.image == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى اختيار صورة للمنتج")));
    return;
  }
  
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();

    // --- الحل هنا: تحويل الـ int (مثل 20270311) إلى DateTime ---
    DateTime expiry;
    try {
      String dateStr = widget.expirationDate.toString();
      if (dateStr.length == 8) {
        expiry = DateTime(
          int.parse(dateStr.substring(0, 4)), // السنة
          int.parse(dateStr.substring(4, 6)), // الشهر
          int.parse(dateStr.substring(6, 8)), // اليوم
        );
      } else {
        expiry = DateTime.now(); // قيمة افتراضية في حال الخطأ
      }
    } catch (e) {
      expiry = DateTime.now();
    }

    final entite = AddProductIntety(
      category: widget.selectedCategory!,
      name: widget.name ?? '',
      price: widget.price ?? 0,
      code: widget.code ?? '',
      description: widget.description ?? '',
      image: widget.image!,
      // نمرر الـ DateTime الجديد هنا
      expirationDate: expiry, 
      unitAmount: widget.unitAmount ?? 0,
      reviews: const [],
      hasDiscount: widget.hasDiscount,
      discountPercentage: widget.discountPercentage ?? 0,
      pharmacyId: widget.pharmacyId,
      cost: widget.cost ?? 0,
      isPrescriptionRequired: widget.isPrescriptionRequired,
      pharmacyName: widget.pharmacyName ?? '',
      pharmacyLat: widget.pharmacyLat ?? 0.0,
      pharmacyLng: widget.pharmacyLng ?? 0.0,
    );

    context.read<AddProductCubit>().addProduct(
      entite,
      documentId: "${widget.code}_${widget.pharmacyId}",
    );
  } else {
    setState(() => autovalidateMode = AutovalidateMode.always);
  }
},
  );
}