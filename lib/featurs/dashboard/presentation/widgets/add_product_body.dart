// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/review_entite.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/cusstom_textfield.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/imag_feild.dart';

class AddProductbody extends StatefulWidget {
  late File? image;
  late String? name, code, description;
  late num? price, numberOfcalories;
  late bool? isOrganic;
  late int? expirationDate;
  late int? unitAmount;
  AddProductbody({
    super.key,
    this.image,
    this.name,
    this.price,
    this.code,
    this.description,
    this.numberOfcalories,
    this.isOrganic,
    this.expirationDate,
    this.unitAmount,
  });

  @override
  State<AddProductbody> createState() => _AddProductbodyState();
}

class _AddProductbodyState extends State<AddProductbody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Form(
        key: formKey,

        autovalidateMode: autovalidateMode,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CustomTextFormField(
                  onSaved: (value) {
                    widget.name = value!;
                  },
                  hintText: "Product Name",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  onSaved: (value) {
                    widget.price = num.parse(value!);
                  },
                  hintText: "Product Price",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  onSaved: (value) {
                    widget.code = value!.toLowerCase();
                  },
                  hintText: "Product code",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  onSaved: (value) {
                    widget.numberOfcalories = num.parse(value!);
                  },
                  hintText: "Product number of calories",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  onSaved: (value) {
                    widget.expirationDate = int.parse(value!);
                  },
                  hintText: "Product expiration date",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  onSaved: (value) {
                    widget.unitAmount = int.parse(value!);
                  },
                  hintText: "Product unit amount",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                CustomTextFormField(
                  onSaved: (value) {
                    widget.description = value!;
                  },
                  hintText: "Product description",
                  textInputType: TextInputType.text,

                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                ImagFeild(
                  onImagePicked: (image) {
                    widget.image = image!;
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: () {
                    if (widget.image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select an image first"),
                        ),
                      );
                      return;
                    }

                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final entite = AddProductIntety(
                        name: widget.name ?? '',
                        price: widget.price ?? 0,
                        code: widget.code ?? '',
                        description: widget.description ?? '',
                        image: widget.image!, // هنا متأكد إنها مش null
                        expirationDate: widget.expirationDate ?? 0,
                        unitAmount: widget.unitAmount ?? 0,
                        isOrganic: widget.isOrganic ?? false,
                        numberOfcalories: widget.numberOfcalories ?? 0,
                        averageRating: 0,
                        ratingcount: 0,
                        reviews: [
                          ReviewEntite(
                            name: 'tharwat',
                            image:
                                'https://img.freepik.com/free-photo/green-striped-ripe-watermelon-with-slice-cross-section-isolated-white-background-with-copy-space-text-images-special-kind-berry-sweet-pink-flesh-with-black-seeds-side-view_639032-1254.jpg',
                            rating: 5,
                            date: DateTime.now().toIso8601String(),
                            comment: 'Nice product',
                          ),
                        ],
                      );

                      context.read<AddProductCubit>().addProduct(entite);
                    } else {
                      autovalidateMode = AutovalidateMode.always;
                      setState(() {});
                    }
                  },

                  text: "Add ",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Please select an image')));
  }
}
