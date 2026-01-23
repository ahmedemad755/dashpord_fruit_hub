// ignore_for_file: must_be_immutable
import 'dart:io';

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
      appBar: AppBar(title: const Text("Add Medicine")),
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

  Widget buildPharmacyIdField() {
    return CustomTextFormField(
      onSaved: (value) => widget.pharmacyId = value!,
      hintText: "Pharmacy ID / Name",
      textInputType: TextInputType.text,
      validator: (value) =>
          (value == null || value.isEmpty) ? "Required" : null,
    );
  }

  Widget buildDiscountSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Apply Discount?"),
          value: widget.hasDiscount,
          activeThumbColor: Colors.green,
          onChanged: (val) => setState(() => widget.hasDiscount = val),
        ),
        if (widget.hasDiscount)
          CustomTextFormField(
            onSaved: (value) =>
                widget.discountPercentage = num.tryParse(value!) ?? 0,
            hintText: "Discount Percentage (%)",
            textInputType: TextInputType.number,
            validator: (value) {
              if (widget.hasDiscount && (value == null || value.isEmpty)) {
                return "Enter discount percentage";
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
      hintText: "Medicine Name",
      textInputType: TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Name is required";
        if (value.trim().length < 3) return "Too short";
        return null;
      },
    );
  }

  Widget buildPriceField() {
    return CustomTextFormField(
      onSaved: (value) => widget.price = num.tryParse(value!) ?? 0,
      hintText: "Base Price",
      textInputType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Price is required";
        if (num.tryParse(value) == null || num.parse(value) <= 0)
          return "Invalid price";
        return null;
      },
    );
  }

  Widget buildCodeField() {
    return CustomTextFormField(
      onSaved: (value) => widget.code = value!.toLowerCase(),
      hintText: "Product code",
      textInputType: TextInputType.text,
      validator: (value) =>
          (value == null || value.isEmpty) ? "Code required" : null,
    );
  }

  Widget buildExpirationDateField() {
    return CustomTextFormField(
      controller: expirationController,
      hintText: "Expiration date",
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
      hintText: "Stock Quantity",
      textInputType: TextInputType.number,
    );
  }

  Widget buildDescriptionField() {
    return CustomTextFormField(
      onSaved: (value) => widget.description = value!,
      hintText: "Description",
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
      label: "Confirm & Add Medicine",
      onPressed: () {
        if (widget.image == null) {
          showError(context);
          return;
        }

        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          final entite = AddProductIntety(
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

          // إنشاء المعرف الفريد
          String uniqueDocId = "${widget.code}_${widget.pharmacyId}";

          // تمرير الـ entite مع الـ uniqueDocId للـ Cubit
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

  void showError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Please select an image')));
  }
}
