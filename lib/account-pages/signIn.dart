
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sham_parts/api_util/user.dart';
import 'package:sham_parts/constants.dart';



class SignInWidget extends StatefulWidget {

  var setUser;

  SignInWidget({super.key, required this.setUser});

  @override
  State<SignInWidget> createState() => SignInState();
}

class SignInState extends State<SignInWidget> {

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dupePasswordController = TextEditingController();

  bool passwordVisible = false;
  bool creatingAccount = false;
  bool verifying = false;

  @override
  void initState() {
    passwordVisible = false;
    creatingAccount = false;
    verifying = false;
  }

  void authenticate() async {
    User? user = await User.authenticate(emailController.text, passwordController.text, context);

    widget.setUser(user);
  }

  void createUser() async {

    if(passwordController.text != dupePasswordController.text) {
      APIConstants.showErrorToast("Passwords do not match!", context);
      return;
    }

    bool success = await User.create(emailController.text, passwordController.text, nameController.text, context);

    if(success) {
      setState(() {
        creatingAccount = false;
        verifying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Text("Sign In to ShamParts", style: StyleConstants.titleStyle,),
            Container(
              width: 500,
              child:
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email'
                  ),
                ),
            ),
            creatingAccount ? Container(
                width: 500,
                child:
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Username'
                  ),
                ),
              ) : Container(),
            SizedBox (
              width: 500,
              child:
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).colorScheme.inverseSurface,

                        )
                    )
                  ),
                ),
            ),
              creatingAccount ? SizedBox (
                width: 500,
                child:
                TextField(
                  controller: dupePasswordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Repeat Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).colorScheme.inverseSurface,

                          )
                      )
                  ),
                ),
              ) : Container(),
              !verifying ? Container(
                width: 500,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.inversePrimary
                  ),
                  child: Text(!creatingAccount ? "Sign In" : "Create Account",
                    style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),),
                  onPressed: () {
                    if(!creatingAccount) {
                      authenticate();
                    } else {
                      createUser();
                    }
                  },
                ),
              ) : Container(),
              verifying ? Container(
                width: 500,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary
                  ),
                  child: Text("I verified my email!",
                    style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),),
                  onPressed: () {
                    setState(() {
                      verifying = false;
                    });
                    authenticate();
                  },
                ),
              ) : Container(),
              TextButton(
                  onPressed: () {
                    setState(() {
                      creatingAccount = !creatingAccount;
                    });
                  },
                  child: Text(!creatingAccount ? "Create Account" : "Sign in")),
              TextButton(
                  onPressed: () {

                  },
                  child: const Text("Forgot Password?")),
          ],
        ),
        ),
      )
    );
  }
}