import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking_app/core/constants/constants.dart';
import 'package:movie_booking_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on(mapEventToState);
  }

  FutureOr<void> mapEventToState(
      AuthEvent event, Emitter<AuthState> emit) async {
    if (event is LoginButtonPressed) {
      emit(AuthLoading());

      try {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final response = await http.post(
          Uri.parse('$uri/api/users/login'),
          body: json.encode({
            'email': event.email,
            'password': event.password,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final Map<String, dynamic> userData = data['data']['user'];
          final String token = data['token'];
          final String id = userData['_id'];
          final String username = userData['username'];
          final String email = userData['email'];
          final String? avatar = userData['avatar'];
          final String? phoneNumber = userData['phone_number'];
          //  print(id);
          // final String email = data['email'];
          // final String password = data['password'];
          // Lưu token vào SharedPreferences
          await preferences.setString("token", token);
          // print(token);
          // print('Username: $username, Email: $email');
          // print(password);

          await Future.delayed(const Duration(milliseconds: 100), () async {
            return emit(AuthSuccess(
                user: User(
                    id: id,
                    email: email,
                    username: username,
                    token: token,
                    avatar: avatar,
                    phone_number: phoneNumber)));
          });
        } else if(response.statusCode == 400){
          return emit(const AuthFailure(
              error:
                  "Please provide email and password!"));
        }else if(response.statusCode == 401){
             return emit(const AuthFailure(
              error:
                  "Incorrect email or password"));
        }
      } catch (error) {
        return emit(AuthFailure(error: error.toString()));
      }
    }
    if (event is SignUpButtonPressed) {
      emit(AuthLoading());

      try {
        final response = await http.post(
          Uri.parse('$uri/api/users/register'),
          body: json.encode({
            'email': event.email,
            'password': event.password,
            'passwordConfirm': event.passwordConfirm,
            'username': event.username
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 201) {
          await Future.delayed(const Duration(milliseconds: 100), () async {
            return emit(AuthSignUpSuccess());
          });
        } else if(response.statusCode == 500) {
          return emit(const AuthFailure(
              error:
                  "Please provide a valid email"));
        }else if(response.statusCode == 400){
          return emit(const AuthFailure(
              error:
              "Email have been used!"));
        }
      } catch (error) {
        return emit(AuthFailure(error: error.toString()));
      }
    }

    //notice: if you dont see the email sent to inbox in gmail please check in spam or trash
    if(event is ForgotButtonPressed){
      emit(AuthLoading());

      try {
        final response = await http.post(
          Uri.parse('$uri/api/users/forget-password'),
          body: json.encode({
            'email': event.email,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          await Future.delayed(const Duration(milliseconds: 100), () async {
            return emit(AuthForgotSuccess());
          });
        } else if(response.statusCode == 500) {
          return emit(const AuthFailure(
              error:
              "There was an error sending the email. Try again later!"));
        }else if(response.statusCode == 404){
          return emit(const AuthFailure(
              error:
              "There is no user with email address!"));
        }
      } catch (error) {
        return emit(AuthFailure(error: error.toString()));
      }
    }
  }
}
