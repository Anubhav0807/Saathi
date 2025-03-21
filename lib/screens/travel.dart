import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saathi/widgets/location_picker.dart';
import 'package:saathi/widgets/search_result.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final _form = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final dateFormatter = DateFormat.yMd();
  final timeFormatter = DateFormat('hh:mm a');

  var searching = false;
  var _source = '';
  var _destination = '';
  var _transportNo = '';
  DateTime? _travelDate;
  DateTime? _travelTime;

  void _search() {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
      if (_source == _destination) {
        showMessageBox(
          title: '-_-',
          message: 'You have reached your destination.',
        );
      } else if (_source != 'VIT Chennai' && _destination != 'VIT Chennai') {
        showMessageBox(
          title: 'Invalid Input',
          message:
              'VIT Chennai must be selected either as starting point or as ending point.',
        );
      } else if (_travelDate == null) {
        showMessageBox(
          title: 'Insufficient Input',
          message: 'Please pick a date for traveling.',
        );
      } else if (_travelTime == null) {
        showMessageBox(
          title: 'Insufficient Input',
          message: 'Please pick a time for traveling.',
        );
      } else if ((_source == 'Airport' || _destination == 'Airport') &&
          _transportNo == '') {
        showMessageBox(
          title: 'Insufficient Input',
          message: 'Please specify your Flight Number.',
        );
      } else if ((_source == 'Railway' || _destination == 'Railway') &&
          _transportNo == '') {
        showMessageBox(
          title: 'Insufficient Input',
          message: 'Please specify your Train Number.',
        );
      } else {
        final data = {
          'source': _source,
          'destination': _destination,
          'transportNo': _transportNo,
          'date': dateFormatter.format(_travelDate!),
          'time': timeFormatter.format(_travelTime!),
        };
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SearchResult(data: data),
        );
      }
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void showMessageBox({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'))
        ],
      ),
    );
  }

  void _pickTravelDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (pickedDate != null) {
      setState(() {
        _travelDate = pickedDate;
      });
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void _pickTravelTime() async {
    DateTime now = DateTime.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _travelTime == null ? now.hour : _travelTime!.hour,
        minute: _travelTime == null ? now.minute : _travelTime!.minute,
      ),
    );
    if (pickedTime != null) {
      setState(() {
        _travelTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Travel Partner'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 10, bottom: 8),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: LocationPicker(
                        hint: const Text('Source'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a starting point.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _source = value ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 10, bottom: 8),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: LocationPicker(
                        hint: const Text('Destination'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an ending point.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _destination = value ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_source == 'Railway' || _destination == 'Railway') ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Train No.',
                    ),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      _transportNo = (value ?? '').toUpperCase();
                    },
                  ),
                ],
                if (_source == "Airport" || _destination == 'Airport') ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Flight No.',
                    ),
                    enableSuggestions: false,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      _transportNo = (value ?? '').toUpperCase();
                    },
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            const Text('Travel Date:'),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 86,
                              child: Text(
                                _travelDate == null
                                    ? 'Not Set'
                                    : dateFormatter.format(_travelDate!),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            IconButton(
                              onPressed: _pickTravelDate,
                              icon: const Icon(Icons.calendar_month),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Travel Time:'),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 86,
                              child: Text(
                                _travelTime == null
                                    ? 'Not Set'
                                    : timeFormatter.format(_travelTime!),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            IconButton(
                              onPressed: _pickTravelTime,
                              icon: const Icon(Icons.access_time),
                            )
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: CircleAvatar(
                        radius: 32,
                        child: IconButton(
                          onPressed: _search,
                          iconSize: 50,
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
