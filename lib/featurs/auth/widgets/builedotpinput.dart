import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

Widget buildOTPInputField(
  BuildContext context,
  TextEditingController codeController,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
    child: PinCodeTextField(
      appContext: context, //دي  لازم تتكتب
      controller: codeController,
      length: 6,
      autoFocus: true,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white, //لون الخانة اللي فيها المؤشر حاليًا.
        selectedFillColor: Colors.white, //الخانة اللي تم تحديدها.
        inactiveFillColor:
            Colors.grey.shade200, //الخانات اللي لسه ما تمشيش فيها الكتابة.
        activeColor: AppColors.lightPrimaryColor,
        selectedColor: Colors.black,
        inactiveColor: Colors.grey,
      ),
      animationDuration: const Duration(milliseconds: 200),
      enableActiveFill: true,
      onChanged: (value) {
        // يمكنك حفظ القيمة هنا
        print(value);
      },
    ),
  );
}
