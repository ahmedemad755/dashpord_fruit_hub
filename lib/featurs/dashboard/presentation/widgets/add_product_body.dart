// // ignore_for_file: must_be_immutable
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
// import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
// import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart';
// import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/cusstom_textfield.dart';
// import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/imag_feild.dart';

// class AddProductBody extends StatefulWidget {
//   late File? image;
//   late String? name, code, description, pharmacyId;
//   late num? price;
//   late int? expirationDate;
//   late int? unitAmount;
//   late bool hasDiscount = false;
//   late num? discountPercentage = 0;

//   AddProductBody({
//     super.key,
//     this.image,
//     this.name,
//     this.price,
//     this.code,
//     this.description,
//     this.expirationDate,
//     this.unitAmount,
//     this.pharmacyId,
//   });

//   @override
//   State<AddProductBody> createState() => _AddProductBodyState();
// }

// class _AddProductBodyState extends State<AddProductBody> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
//   final TextEditingController expirationController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("إضافة دواء جديد"), centerTitle: true),
//       body: Form(
//         key: formKey,
//         autovalidateMode: autovalidateMode,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             children: [
//               const SizedBox(height: 16),
//               buildPharmacyIdField(),
//               const SizedBox(height: 16),
//               buildNameField(),
//               const SizedBox(height: 16),
//               buildPriceField(),
//               const SizedBox(height: 16),
//               buildDiscountSection(),
//               const SizedBox(height: 16),
//               buildCodeField(),
//               const SizedBox(height: 16),
//               buildExpirationDateField(),
//               const SizedBox(height: 16),
//               buildUnitAmountField(),
//               const SizedBox(height: 16),
//               buildDescriptionField(),
//               const SizedBox(height: 16),
//               buildImageField(),
//               const SizedBox(height: 24),
//               buildAddButton(),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildPharmacyIdField() {
//     return CustomTextFormField(
//       onSaved: (value) => widget.pharmacyId = value!,
//       hintText: "اسم الصيدلية / المعرف",
//       textInputType: TextInputType.text,
//       validator: (value) =>
//           (value == null || value.isEmpty) ? "هذا الحقل مطلوب" : null,
//     );
//   }

//   Widget buildDiscountSection() {
//     return Column(
//       children: [
//         SwitchListTile(
//           title: const Text("هل يوجد خصم؟"),
//           value: widget.hasDiscount,
//           activeThumbColor: Colors.green,

//           onChanged: (val) => setState(() => widget.hasDiscount = val),
//         ),
//         if (widget.hasDiscount)
//           CustomTextFormField(
//             onSaved: (value) =>
//                 widget.discountPercentage = num.tryParse(value!) ?? 0,
//             hintText: "نسبة الخصم (%)",
//             textInputType: TextInputType.number,
//             validator: (value) {
//               if (widget.hasDiscount && (value == null || value.isEmpty)) {
//                 return "يرجى إدخال نسبة الخصم";
//               }
//               return null;
//             },
//           ),
//       ],
//     );
//   }

//   Widget buildNameField() {
//     return CustomTextFormField(
//       onSaved: (value) => widget.name = value!,
//       hintText: "اسم الدواء",
//       textInputType: TextInputType.text,
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) return "الاسم مطلوب";
//         if (value.trim().length < 3) return "الاسم قصير جداً";
//         return null;
//       },
//     );
//   }

//   Widget buildPriceField() {
//     return CustomTextFormField(
//       onSaved: (value) => widget.price = num.tryParse(value!) ?? 0,
//       hintText: "السعر الأساسي",
//       textInputType: TextInputType.number,
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) return "السعر مطلوب";
//         if (num.tryParse(value) == null || num.parse(value) <= 0)
//           return "يرجى إدخال سعر صحيح";
//         return null;
//       },
//     );
//   }

//   Widget buildCodeField() {
//     return CustomTextFormField(
//       onSaved: (value) => widget.code = value!.toLowerCase(),
//       hintText: "كود المنتج (Barcode)",
//       textInputType: TextInputType.text,
//       validator: (value) =>
//           (value == null || value.isEmpty) ? "الكود مطلوب" : null,
//     );
//   }

//   Widget buildExpirationDateField() {
//     return CustomTextFormField(
//       controller: expirationController,
//       hintText: "تاريخ انتهاء الصلاحية",
//       textInputType: TextInputType.datetime,
//       readOnly: true,
//       onTap: () async {
//         DateTime? pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime.now(),
//           lastDate: DateTime(2100),
//           locale: const Locale('ar', 'EG'), // لتغيير لغة التقويم للعربية
//         );
//         if (pickedDate != null) {
//           setState(() {
//             expirationController.text =
//                 "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
//             widget.expirationDate = int.parse(
//               "${pickedDate.year}${pickedDate.month.toString().padLeft(2, '0')}${pickedDate.day.toString().padLeft(2, '0')}",
//             );
//           });
//         }
//       },
//       onSaved: (value) {},
//     );
//   }

//   Widget buildUnitAmountField() {
//     return CustomTextFormField(
//       onSaved: (value) => widget.unitAmount = int.tryParse(value!) ?? 0,
//       hintText: "الكمية المتوفرة في المخزن",
//       textInputType: TextInputType.number,
//       validator: (value) =>
//           (value == null || value.isEmpty) ? "الكمية مطلوبة" : null,
//     );
//   }

//   Widget buildDescriptionField() {
//     return CustomTextFormField(
//       onSaved: (value) => widget.description = value!,
//       hintText: "وصف الدواء",
//       maxLines: 3,
//       textInputType: TextInputType.text,
//     );
//   }

//   Widget buildImageField() {
//     return ImagFeild(onImagePicked: (image) => widget.image = image!);
//   }

//   Widget buildAddButton() {
//     return GradientButton(
//       gradientColors: [Colors.green, Colors.lightGreen],
//       label: "تأكيد وإضافة الدواء",
//       onPressed: () {
//         if (widget.image == null) {
//           showError(context, 'يرجى اختيار صورة للمنتج');
//           return;
//         }

//         if (formKey.currentState!.validate()) {
//           formKey.currentState!.save();

//           final entite = AddProductIntety(
//             name: widget.name ?? '',
//             price: widget.price ?? 0,
//             code: widget.code ?? '',
//             description: widget.description ?? '',
//             image: widget.image!,
//             expirationDate: widget.expirationDate ?? 0,
//             unitAmount: widget.unitAmount ?? 0,
//             reviews: [],
//             hasDiscount: widget.hasDiscount,
//             discountPercentage: widget.discountPercentage ?? 0,
//             pharmacyId: widget.pharmacyId, category: '',
//           );

//           String uniqueDocId = "${widget.code}_${widget.pharmacyId}";

//           context.read<AddProductCubit>().addProduct(
//             entite,
//             documentId: uniqueDocId,
//           );
//         } else {
//           setState(() => autovalidateMode = AutovalidateMode.always);
//         }
//       },
//     );
//   }

//   void showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }
// }
// ignore_for_file: must_be_immutable
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'; // تمت إضافة المكتبة هنا
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
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
  String? selectedCategory; // متغير جديد لحفظ التصنيف

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
  });

  @override
  State<AddProductBody> createState() => _AddProductBodyState();
}

class _AddProductBodyState extends State<AddProductBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final TextEditingController expirationController = TextEditingController();

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
              buildPharmacyIdField(),
              const SizedBox(height: 16),
              buildCategoryField(), // استدعاء حقل التصنيف الديناميكي
              const SizedBox(height: 16),
              buildNameField(),
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

  // ويدجت جلب التصنيفات ديناميكياً من Firestore
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

  Widget buildPharmacyIdField() {
    return CustomTextFormField(
      onSaved: (value) => widget.pharmacyId = value!,
      hintText: "اسم الصيدلية / المعرف",
      textInputType: TextInputType.text,
      validator: (value) =>
          (value == null || value.isEmpty) ? "هذا الحقل مطلوب" : null,
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
          // locale: const Locale('ar', 'EG'),
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

        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          final entite = AddProductIntety(
            category: widget.selectedCategory!, // تمرير التصنيف المختار
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
