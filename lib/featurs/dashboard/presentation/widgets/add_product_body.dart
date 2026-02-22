// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/cusstom_textfield.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/imag_feild.dart';

class AddProductBody extends StatefulWidget {
  late File? image;
  late String? name, code, description, pharmacyId;
  late num? price;
  late int? expirationDate;
  late int? unitAmount;
  late bool hasDiscount = false;
  late num? discountPercentage = 0;
  String? selectedCategory;
  String? pharmacyName;

  AddProductBody({
    super.key,
    this.image,
    this.name,
    this.price,
    this.code,
    this.description,
    this.expirationDate,
    this.unitAmount,
    this.pharmacyId,
    this.pharmacyName,
  });

  @override
  State<AddProductBody> createState() => _AddProductBodyState();
}

class _AddProductBodyState extends State<AddProductBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final TextEditingController expirationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getPharmacyIdFromPrefs(); // جلب الـ ID تلقائياً عند بدء الشاشة
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    String userData = Prefs.getString("kUserData");
    if (userData.isNotEmpty) {
      try {
        return jsonDecode(userData);
      } catch (e) {
        print("Error decoding JSON: $e");
        return null;
      }
    }
    return null;
  }

  void _getPharmacyIdFromPrefs() async {
    try {
      Map<String, dynamic>? userData = await _getUserData();
      if (userData != null && userData.isNotEmpty) {
        setState(() {
          widget.pharmacyId = userData['uId']?.toString();
          widget.pharmacyName = userData['pharmacyName']?.toString();
        });
        print("✅ Pharmacy ID (uId) Loaded: ${widget.pharmacyId}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة دواء جديد"), centerTitle: true),
      body: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              buildReadOnlyPharmacyFields(),
              const SizedBox(height: 16),
              buildNameField(),
              const SizedBox(height: 16),
              buildCategoryField(),
              const SizedBox(height: 16),
              buildPriceField(),
              const SizedBox(height: 16),
              buildDiscountSection(),
              const SizedBox(height: 16),
              buildCodeField(),
              const SizedBox(height: 16),
              buildExpirationDateField(),
              const SizedBox(height: 16),
              buildUnitAmountField(),
              const SizedBox(height: 16),
              buildDescriptionField(),
              const SizedBox(height: 16),
              buildImageField(),
              const SizedBox(height: 24),
              buildAddButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryField() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DropdownMenuItem<String>> categoryItems = snapshot.data!.docs.map((
          doc,
        ) {
          return DropdownMenuItem<String>(
            value: doc['name'].toString(),
            child: Text(doc['name'].toString()),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          hint: const Text("اختر تصنيف المنتج"),
          initialValue: widget.selectedCategory,
          items: categoryItems,
          onChanged: (value) {
            setState(() {
              widget.selectedCategory = value;
            });
          },
          validator: (value) => (value == null) ? "التصنيف مطلوب" : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget buildReadOnlyPharmacyFields() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, prefsSnapshot) {
        // 1. فحص حالة الـ Future (الـ SharedPreferences)
        if (prefsSnapshot.connectionState == ConnectionState.waiting &&
            widget.pharmacyId == null) {
          return const Column(
            children: [
              LinearProgressIndicator(),
              Text("جاري القراءة من ذاكرة الهاتف..."),
            ],
          );
        }

        // 2. التحقق مما إذا كانت البيانات موجودة في الـ Prefs أصلاً
        final userMap = prefsSnapshot.data;
        final String? currentId =
            widget.pharmacyId ?? userMap?['uId']?.toString();

        if (currentId == null || currentId.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(10),
            color: Colors.red[100],
            child: Text(
              "❌ خطأ: لم يتم العثور على uId في الذاكرة.\n"
              "المحتوى المتاح: ${userMap.toString()}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. إذا وجدنا الـ ID، نذهب لـ Firestore
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pharmacies')
              .doc(currentId)
              .snapshots(),
          builder: (context, firestoreSnapshot) {
            if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            if (firestoreSnapshot.hasError) {
              return Text(
                "خطأ في الاتصال بـ Firebase: ${firestoreSnapshot.error}",
              );
            }

            if (!firestoreSnapshot.hasData || !firestoreSnapshot.data!.exists) {
              return Container(
                padding: const EdgeInsets.all(10),
                color: Colors.orange[100],
                child: Text(
                  "⚠️ الـ ID موجود ($currentId) ولكن لا يوجد مستند بهذا الاسم في Firestore كولكشن pharmacies",
                  style: const TextStyle(color: Colors.orange),
                ),
              );
            }

            var data = firestoreSnapshot.data!.data() as Map<String, dynamic>;
            String pName = data['pharmacyName'] ?? "اسم مفقود";
            String pId = data['pharmacistId'] ?? "رقم مفقود";

            return Column(
              children: [
                TextFormField(
                  initialValue: pName,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "الصيدلية",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: pId,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "رقم القيد",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildDiscountSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("هل يوجد خصم؟"),
          value: widget.hasDiscount,
          activeThumbColor: Colors.green,
          onChanged: (val) => setState(() => widget.hasDiscount = val),
        ),
        if (widget.hasDiscount)
          CustomTextFormField(
            onSaved: (value) =>
                widget.discountPercentage = num.tryParse(value!) ?? 0,
            hintText: "نسبة الخصم (%)",
            textInputType: TextInputType.number,
            validator: (value) {
              if (widget.hasDiscount && (value == null || value.isEmpty)) {
                return "يرجى إدخال نسبة الخصم";
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget buildNameField() {
    return CustomTextFormField(
      onSaved: (value) => widget.name = value!,
      hintText: "اسم الدواء",
      textInputType: TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "الاسم مطلوب";
        if (value.trim().length < 3) return "الاسم قصير جداً";
        return null;
      },
    );
  }

  Widget buildPriceField() {
    return CustomTextFormField(
      onSaved: (value) => widget.price = num.tryParse(value!) ?? 0,
      hintText: "السعر الأساسي",
      textInputType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "السعر مطلوب";
        if (num.tryParse(value) == null || num.parse(value) <= 0)
          return "يرجى إدخال سعر صحيح";
        return null;
      },
    );
  }

  Widget buildCodeField() {
    return CustomTextFormField(
      onSaved: (value) => widget.code = value!.toLowerCase(),
      hintText: "كود المنتج (Barcode)",
      textInputType: TextInputType.text,
      validator: (value) =>
          (value == null || value.isEmpty) ? "الكود مطلوب" : null,
    );
  }

  Widget buildExpirationDateField() {
    return CustomTextFormField(
      controller: expirationController,
      hintText: "تاريخ انتهاء الصلاحية",
      textInputType: TextInputType.datetime,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            expirationController.text =
                "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
            widget.expirationDate = int.parse(
              "${pickedDate.year}${pickedDate.month.toString().padLeft(2, '0')}${pickedDate.day.toString().padLeft(2, '0')}",
            );
          });
        }
      },
      onSaved: (value) {},
    );
  }

  Widget buildUnitAmountField() {
    return CustomTextFormField(
      onSaved: (value) => widget.unitAmount = int.tryParse(value!) ?? 0,
      hintText: "الكمية المتوفرة في المخزن",
      textInputType: TextInputType.number,
      validator: (value) =>
          (value == null || value.isEmpty) ? "الكمية مطلوبة" : null,
    );
  }

  Widget buildDescriptionField() {
    return CustomTextFormField(
      onSaved: (value) => widget.description = value!,
      hintText: "وصف الدواء",
      maxLines: 3,
      textInputType: TextInputType.text,
    );
  }

  Widget buildImageField() {
    return ImagFeild(onImagePicked: (image) => widget.image = image!);
  }

  Widget buildAddButton() {
    return GradientButton(
      gradientColors: [Colors.green, Colors.lightGreen],
      label: "تأكيد وإضافة الدواء",
      onPressed: () {
        if (widget.image == null) {
          showError(context, 'يرجى اختيار صورة للمنتج');
          return;
        }

        if (widget.pharmacyId == null) {
          showError(
            context,
            'خطأ في جلب بيانات الصيدلية، حاول إعادة تسجيل الدخول',
          );
          return;
        }

        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          final entite = AddProductIntety(
            category: widget.selectedCategory!,
            name: widget.name ?? '',
            price: widget.price ?? 0,
            code: widget.code ?? '',
            description: widget.description ?? '',
            image: widget.image!,
            expirationDate: widget.expirationDate ?? 0,
            unitAmount: widget.unitAmount ?? 0,
            reviews: [],
            hasDiscount: widget.hasDiscount,
            discountPercentage: widget.discountPercentage ?? 0,
            pharmacyId: widget.pharmacyId,
          );

          String uniqueDocId = "${widget.code}_${widget.pharmacyId}";

          context.read<AddProductCubit>().addProduct(
            entite,
            documentId: uniqueDocId,
          );
        } else {
          setState(() => autovalidateMode = AutovalidateMode.always);
        }
      },
    );
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
