import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_state.dart';
import 'package:fruitesdashboard/featurs/auth/widgets/builedotpinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String? phoneNumber;

  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController codeController = TextEditingController();
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // إلغاء أي تايمر قديم

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel(); // إيقاف التايمر
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // مهم جدًا عشان ميعملش setState بعد dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: BlocConsumer<OTPCubit, OTPState>(
        listener: (context, state) async {
          if (state is OTPLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else {
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }

          if (state is OTPVerified) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isOTPVerified', true);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم التحقق بنجاح ✅')));

            Navigator.pushNamed(context, AppRoutes.sendResetPassword);
          } else if (state is OTPError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 40,
                vertical: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BackButton(),
                  const SizedBox(height: 20),

                  // Icon Circle
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6FBFF),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.phone_android_outlined,
                        size: 40,
                        color: Color(0xFF007BBB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      'التحقق من الرمز',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Center(
                    child: Text(
                      'أدخل الرمز الذي أرسلناه إلى رقم الهاتف التالي:\n${widget.phoneNumber ?? 'رقم غير متوفر'}',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input
                  buildOTPInputField(context, codeController),
                  const SizedBox(height: 32),

                  // Timer / Resend
                  Center(
                    child: _remainingSeconds > 0
                        ? Text(
                            'إعادة إرسال الرمز خلال $_remainingSeconds ثانية',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              final phone = widget.phoneNumber!;
                              context.read<OTPCubit>().sendOTP(phone);
                              setState(() => _remainingSeconds = 60);
                              _startTimer();
                            },
                            child: const Text(
                              'إعادة إرسال الرمز',
                              style: TextStyle(
                                color: Color(0xFF007BBB),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final code = codeController.text.trim();
                        if (code.length == 6) {
                          context.read<OTPCubit>().verifyCode(code);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('من فضلك أدخل رمز مكون من 6 أرقام'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BBB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تحقق من الرمز',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
