import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/build_overlay_bar.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/login_state.dart';
import 'package:fruitesdashboard/featurs/auth/widgets/cusstom_textfield.dart';
import 'package:fruitesdashboard/featurs/auth/widgets/customProgressLoading.dart';

// ----------------- LoginView -----------------
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  late String email, password;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ لتجنب overflow مع الكيبورد
      appBar: AppBar(title: Text('تسجيل دخول')),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // تحميل بيانات السلة الخاصة بالمستخدم بعد تسجيل الدخول
            // getIt<CartCubit>().loadCartFromRepository();
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
          if (state is LoginFailure) {
            showBar(context, state.message);
          }
        },
        builder: (context, state) {
          return CustomProgresIndecatorHUD(
            isLoading: state is LoginLoading,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 40,
                  vertical: 32,
                ),
                child: SingleChildScrollView(
                  reverse: true, // ✅ يحافظ على Scroll عند الكيبورد
                  child: Form(
                    key: formKey,
                    autovalidateMode: autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'مرحباً بعودتك',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'سجل دخولك للمتابعة',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: AppColors.darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Email Field مع validator
                        CustomTextFormField(
                          hintText: 'البريد الإلكتروني',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) => email = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'البريد الإلكتروني غير صالح';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field مع validator
                        CustomTextFormField(
                          hintText: 'كلمة المرور',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          onSaved: (value) => password = value!,
                          toggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.forgotPassword);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        GradientButton(
                          label: 'تسجيل دخول',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              context
                                  .read<LoginCubit>()
                                  .signInWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                            } else {
                              setState(() {
                                autovalidateMode = AutovalidateMode.always;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'لا تمتلك حساب؟ ',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'قم بإنشاء حساب',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed(AppRoutes.signup);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        // Row(
                        //   children: const [
                        //     Expanded(child: Divider()),
                        //     Padding(
                        //       padding: EdgeInsets.symmetric(horizontal: 18.0),
                        //       child: Text('أو', style: TextStyle(fontSize: 16)),
                        //     ),
                        //     Expanded(child: Divider()),
                        //   ],
                        // ),
                        // const SizedBox(height: 16),
                        // SocialButton(
                        //   onPressed: () {
                        //     context.read<LoginCubit>().signInWithGoogle();
                        //   },
                        //   icon: SvgPicture.asset(Assets.socialIconsGoogle),
                        //   text: 'تسجيل بواسطة جوجل',
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
