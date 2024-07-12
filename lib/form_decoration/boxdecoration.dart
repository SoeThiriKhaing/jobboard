import 'package:codehunt/auth/register.dart';
import 'package:flutter/material.dart';

InputDecoration emailInputDecoration() {
  return const InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: RegistrationForm.navyColor)),
  );
}

InputDecoration passwordInputDecoration() {
  return const InputDecoration(
    labelText: 'Password',
    hintText: 'Enter your password',
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: RegistrationForm.navyColor)),
  );
}

InputDecoration getInputDecoration() {
  return const InputDecoration(
       border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: RegistrationForm.navyColor)),

  );
}
