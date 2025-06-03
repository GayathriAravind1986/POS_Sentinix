import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/customTextfield.dart';
import 'package:simple/Reusable/responsive.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: const LoginScreenView(),
    );
  }
}

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({
    super.key,
  });

  @override
  LoginScreenViewState createState() => LoginScreenViewState();
}

class LoginScreenViewState extends State<LoginScreenView> {
  // PostLoginModel postLoginModel = PostLoginModel();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  RegExp emailRegex = RegExp(r'\S+@\S+\.\S+');
  String? errorMessage;
  var showPassword = true;
  bool loginLoad = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return ResponsiveBuilder(desktopBuilder: (context, constraints) {
        return Form(
          key: _formKey,
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/login_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Centered login box
              Center(
                child: Container(
                  width: 380,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: blueColor),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'POS',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: pinkColor,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Subtitle
                      Text('Sign in to start your session'),
                      SizedBox(height: 12),

                      // Email field
                      CustomTextField(
                          hint: "Email Address",
                          readOnly: false,
                          controller: email,
                          baseColor: appPrimaryColor,
                          borderColor: appGreyColor,
                          errorColor: redColor,
                          inputType: TextInputType.text,
                          showSuffixIcon: false,
                          FTextInputFormatter:
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z0-9.@]")),
                          obscureText: false,
                          maxLength: 30,
                          onChanged: (val) {
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value != null) {
                              if (value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!emailRegex.hasMatch(value)) {
                                return 'Please enter valid email';
                              } else {
                                return null;
                              }
                            }
                            return null;
                          }),
                      SizedBox(height: 12),

                      // Password field
                      CustomTextField(
                          hint: "Password",
                          readOnly: false,
                          controller: password,
                          baseColor: appPrimaryColor,
                          borderColor: appGreyColor,
                          errorColor: redColor,
                          inputType: TextInputType.text,
                          obscureText: showPassword,
                          showSuffixIcon: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: appGreyColor,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          maxLength: 80,
                          onChanged: (val) {
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value != null) {
                              if (value.isEmpty) {
                                return 'Please enter your password';
                              } else {
                                return null;
                              }
                            }
                            return null;
                          }),
                      SizedBox(height: 12),

                      // Remember me + button
                      // Row(
                      //   children: [
                      //     Checkbox(value: false, onChanged: (_) {}),
                      //     Text('Remember Me'),
                      //   ],
                      // ),
                      // SizedBox(height: 8),

                      // Login button
                      // loginLoad
                      //     ? const SpinKitCircle(color: appPrimaryColor, size: 30)
                      //     :
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) => false);
                            //   setState(() {
                            //     loginLoad = true;
                            //   });
                            //   context.read<LoginInBloc>().add(LoginIn(
                            //     email.text,
                            //     password.text,
                            //   ));
                          }
                        },
                        child: appButton(
                            height: 50,
                            width: size.width * 0.85,
                            buttonText: "Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }, tabletBuilder: (context, constraints) {
        debugPrint("welcomeTab");
        return Form(
          key: _formKey,
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/login_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Centered login box
              Center(
                child: Container(
                  width: 380,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: blueColor),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'POS',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: pinkColor,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Subtitle
                      Text('Sign in to start your session'),
                      SizedBox(height: 12),

                      // Email field
                      CustomTextField(
                          hint: "Email Address",
                          readOnly: false,
                          controller: email,
                          baseColor: appPrimaryColor,
                          borderColor: appGreyColor,
                          errorColor: redColor,
                          inputType: TextInputType.text,
                          showSuffixIcon: false,
                          FTextInputFormatter:
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z0-9.@]")),
                          obscureText: false,
                          maxLength: 30,
                          onChanged: (val) {
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value != null) {
                              if (value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!emailRegex.hasMatch(value)) {
                                return 'Please enter valid email';
                              } else {
                                return null;
                              }
                            }
                            return null;
                          }),
                      SizedBox(height: 12),

                      // Password field
                      CustomTextField(
                          hint: "Password",
                          readOnly: false,
                          controller: password,
                          baseColor: appPrimaryColor,
                          borderColor: appGreyColor,
                          errorColor: redColor,
                          inputType: TextInputType.text,
                          obscureText: showPassword,
                          showSuffixIcon: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: appGreyColor,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          maxLength: 80,
                          onChanged: (val) {
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value != null) {
                              if (value.isEmpty) {
                                return 'Please enter your password';
                              } else {
                                return null;
                              }
                            }
                            return null;
                          }),
                      SizedBox(height: 12),

                      // Remember me + button
                      // Row(
                      //   children: [
                      //     Checkbox(value: false, onChanged: (_) {}),
                      //     Text('Remember Me'),
                      //   ],
                      // ),
                      // SizedBox(height: 8),

                      // Login button
                      // loginLoad
                      //     ? const SpinKitCircle(color: appPrimaryColor, size: 30)
                      //     :
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) => false);
                            //   setState(() {
                            //     loginLoad = true;
                            //   });
                            //   context.read<LoginInBloc>().add(LoginIn(
                            //     email.text,
                            //     password.text,
                            //   ));
                          }
                        },
                        child: appButton(
                            height: 50,
                            width: size.width * 0.85,
                            buttonText: "Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
        backgroundColor: whiteColor,
        body: BlocBuilder<DemoBloc, dynamic>(
          buildWhen: ((previous, current) {
            // if (current is PostLoginModel) {
            //   postLoginModel = current;
            //
            //   if (postLoginModel.success == true) {
            //     debugPrint("LoginIn success: ${postLoginModel.data?.errorMsg}");
            //     if (postLoginModel.data?.status == true) {
            //       debugPrint("Login: ${postLoginModel.success}");
            //
            //       setState(() {
            //         loginLoad = false;
            //       });
            //       Navigator.of(context).pushAndRemoveUntil(
            //         MaterialPageRoute(
            //             builder: (context) => const DashboardScreen()),
            //         (Route<dynamic> route) => false,
            //       );
            //     } else if (postLoginModel.data?.status == false) {
            //       debugPrint("LoginError: ${postLoginModel.data?.errorMsg}");
            //       setState(() {
            //         loginLoad = false;
            //         showToast('${postLoginModel.data?.errorMsg}', context,
            //             color: false);
            //       });
            //     }
            //   }
            //   return true;
            // }
            return false;
          }),
          builder: (context, dynamic) {
            return mainContainer();
          },
        ));
  }
}
