import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AccountForm extends StatelessWidget {
  const AccountForm(
      {Key key,
      this.emailController,
      this.passwordController,
      this.nameController,
      this.formKey})
      : super(key: key);

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
        child: Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            controller: emailController,
            autofillHints: const <String>[AutofillHints.email],
            validator: MultiValidator([
              RequiredValidator(errorText: 'Please enter an email address.'),
              EmailValidator(errorText: 'Please enter a valid email address.')
            ]),
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            controller: passwordController,
            obscureText: true,
            validator: MultiValidator([
              RequiredValidator(errorText: 'Please enter a password.'),
              MinLengthValidator(8, errorText: 'Password must be 8 characters long.')
            ]),
            autofillHints: const <String>[AutofillHints.password],
          ),
          if (nameController != null)
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              controller: nameController,
              autofillHints: const <String>[AutofillHints.name],
              validator: RequiredValidator(errorText: 'Please enter your name.'),
            ),
        ],
      ),
    ));
  }
}
