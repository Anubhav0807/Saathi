import 'dart:io';

import 'package:saathi/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  File? _selectedImage;
  var _isRegistered = true;
  var _isAuthenticating = false;
  var _isVisible = false;
  var _enteredUsername = '';
  var _enteredRegNo = '';
  var _selectedGender = '';
  var _enteredPhoneNo = '';
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    final String? imageURL;
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
      setState(() {
        _isAuthenticating = true;
      });
      try {
        if (_isRegistered) {
          await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );
        } else {
          final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );
          if (_selectedImage != null) {
            // If we targeting a folder or file that does not exist, it will be created
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('user_images')
                .child('${userCredential.user!.uid}.jpg');
            await storageRef.putFile(_selectedImage!);
            imageURL = await storageRef.getDownloadURL();
          } else {
            imageURL = null;
          }
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(
            {
              'email': _enteredEmail,
              'phoneNo': _enteredPhoneNo,
              'username': _enteredUsername,
              'regNo': _enteredRegNo,
              'gender': _selectedGender,
              'imageURL': imageURL, // Can be null
            },
          );
        }
      } on FirebaseAuthException catch (error) {
        // if (error.code == 'email-already-in-use') {}
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? 'Authentication failed.'),
            ),
          );
        }
      }
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  bool _isValidBranch(String str) {
    str = str.toUpperCase();
    for (String branch in ['BCE', 'BEC', 'BRS', 'BAI', 'BPS', 'BLC', 'BEE']) {
      if (str == branch) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: _isRegistered ? 20 : 0,
                  left: 20,
                  right: 20,
                ),
                width: _isRegistered ? 200 : 150,
                child: Image.asset('assets/images/team-icon.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*---------------- Profile Picture -----------------*/
                          if (!_isRegistered)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          /*------------------- Username ---------------------*/
                          if (!_isRegistered)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name can\'t be left empty.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                            ),
                          /*-------------- Registratioin Number --------------*/
                          if (!_isRegistered)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Registration Number',
                              ),
                              enableSuggestions: false,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.trim().length != 9) {
                                  return 'Registration Number is required.';
                                }
                                final yearOfJoining = int.tryParse(
                                  value.substring(0, 2),
                                );
                                final rno = int.tryParse(
                                  value.substring(5, 9),
                                );
                                if (yearOfJoining == null ||
                                    yearOfJoining < 10 ||
                                    DateTime.now().year % 100 < yearOfJoining ||
                                    !_isValidBranch(value.substring(2, 5)) ||
                                    rno == null ||
                                    rno < 0) {
                                  return 'Please enter a valid Registration Number.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredRegNo = newValue!.toUpperCase();
                              },
                            ),
                          if (!_isRegistered)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                /*-------------- Phone Number ----------------*/
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      prefix: Text('+91'),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.length != 10) {
                                        return 'Invalid phone number.';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _enteredPhoneNo = newValue!;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 32),
                                /*----------------- Gender -------------------*/
                                Expanded(
                                  child: DropdownButtonFormField(
                                    hint: const Text('Gender'),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Male',
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 64,
                                              child: Text('Male'),
                                            ),
                                            Icon(Icons.male_rounded),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Female',
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 64,
                                              child: Text('Female'),
                                            ),
                                            Icon(Icons.female_rounded),
                                          ],
                                        ),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Pls specify ur gender.';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _selectedGender = value ?? '';
                                    },
                                  ),
                                ),
                              ],
                            ),
                          /*----------------- Email Address ------------------*/
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.endsWith('@vitstudent.ac.in')) {
                                return 'Please enter a VIT student email address.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          /*------------------- Password ---------------------*/
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: _isRegistered
                                        ? 'Password'
                                        : 'New Password',
                                  ),
                                  obscureText: !_isVisible, // Hide text
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      // Firebase does not allow passwords of less than 6 characters.
                                      return 'Password must be atleast 6 chars long.';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _enteredPassword = newValue!;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                                icon: Icon(
                                  _isVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              )
                            ],
                          ),
                          /*----------------- Lon In / Sign Up ---------------*/
                          const SizedBox(height: 12),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: _isRegistered
                                  ? const Text('Log In')
                                  : const Text('Sign Up'),
                            ),
                          /*----------- Toogle b/w Log In and Sign Up --------*/
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isRegistered = !_isRegistered;
                                  _form.currentState!.reset();
                                });
                                FocusScope.of(context).requestFocus(_focusNode);
                              },
                              child: _isRegistered
                                  ? const Text('Create an account')
                                  : const Text('I already have an account'),
                            ),
                          /*---------------- Loading Spinner -----------------*/
                          if (_isAuthenticating)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
