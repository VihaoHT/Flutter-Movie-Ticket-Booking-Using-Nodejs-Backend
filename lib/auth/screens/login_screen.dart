import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_booking_app/admin_main.dart';
import 'package:movie_booking_app/auth/bloc/auth_bloc.dart';
import 'package:movie_booking_app/auth/screens/forgot_password_screen.dart';
import 'package:movie_booking_app/auth/screens/signup_screen.dart';
import 'package:movie_booking_app/auth/widgets/custom_textfield.dart';
import 'package:movie_booking_app/bottom_navigation.dart';
import 'package:get/get.dart' as Getx;
import 'package:movie_booking_app/core/constants/ultis.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = const LinearGradient(
      colors: <Color>[Color(0xffFA6900), Color(0xffDA004E)],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200, 70.0));

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showToastFailed(context, state.error);

            }

            if (state is AuthSuccess) {
              showToastSuccess(context,"Login successful");
              state.user.role == "user" ?
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavigation(),
                ),
                (route) => false,
              ) :
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminMain(),
                ),
                    (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
              children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 45),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Beenema',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 26),
                          child: const Text(
                            "Enter your data",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 33, left: 42),
                        child: const Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      CustomTextField(
                          controller: emailController,
                          hintText: "Enter your email")
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 33, left: 42),
                        child: const Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      CustomTextField(
                          controller: passwordController,
                          hintText: "Enter your password"),
                      GestureDetector(
                        onTap: () {
                          Getx.Get.to(()=>const ForgotPasswordScreen(),
                              transition: Getx.Transition.circularReveal,
                              duration: const Duration(milliseconds: 2000));
                        },
                        child: Container(
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.only(right: 34),
                          child: const Text(
                            "Forgot password",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xffDA004E)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 160),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LoginButtonPressed(
                              email: emailController.text,
                              password: passwordController.text));
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xffF34C30), Color(0xffDA004E)]),
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            width: 335,
                            height: 60,
                            alignment: Alignment.center,
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 57),
                      GestureDetector(
                        onTap: () {
                          Getx.Get.to(const SignUpScreen(),
                              transition: Getx.Transition.circularReveal,
                              duration: const Duration(milliseconds: 2000));
                        },
                        child: const Text.rich(TextSpan(
                            text: 'Dont Have Account Yet? ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffDA004E),
                                ),
                              )
                            ])),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
