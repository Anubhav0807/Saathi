import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final List<Map<String, dynamic>> data = [];
  final format = DateFormat("M/d/yyyy h:mm a");

  var isLoading = true;

  void _submit() async {
    await FirebaseFirestore.instance
        .collection('travel')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(widget.data);
  }

  void _search() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String currentUserGender = 'N/A';
    final currentUserTime =
        format.parse('${widget.data['date']} ${widget.data['time']}');
    var users =
        (await FirebaseFirestore.instance.collection('users').get()).docs;
    var travel =
        (await FirebaseFirestore.instance.collection('travel').get()).docs;

    for (var user in users) {
      if (user.id == currentUserId) {
        currentUserGender = user.data()['gender'];
        break;
      }
    }

    for (var travelDetails in travel) {
      if (travelDetails.id != currentUserId) {
        for (var user in users) {
          if (user.id == travelDetails.id) {
            final otherUserTime = format.parse(
                '${travelDetails.data()['date']} ${travelDetails.data()['time']}');
            final difference = currentUserTime.difference(otherUserTime).abs();
            final sameTransport = widget.data['transportNo'] ==
                travelDetails.data()['transportNo'];
            if (difference.inMinutes <= 120 &&
                travelDetails.data()['source'] == widget.data['source'] &&
                travelDetails.data()['destination'] ==
                    widget.data['destination'] &&
                user.data()['gender'] == currentUserGender) {
              data.add({
                'username': user.data()['username'],
                'regNo': user.data()['regNo'],
                'imageURL': user.data()['imageURL'],
                'transportNo': travelDetails.data()['transportNo'],
                'diff': difference,
                'sameTransport': sameTransport,
              });
            }
            break;
          }
        }
      }
    }
    data.sort(
      (a, b) => (a['diff'] as Duration).compareTo(b['diff'] as Duration),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _submit();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data.isEmpty
                ? const Center(
                    child: Text(
                      'No travel partner available :(\nPlease check after sometime...',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) => Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: data[index]['sameTransport']
                              ? const Color.fromARGB(255, 255, 215, 0)
                              : Colors.transparent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage: const AssetImage(
                                  'assets/images/default-pfp.png',
                                ),
                                foregroundImage: data[index]['imageURL'] == null
                                    ? const AssetImage(
                                        'assets/images/default-pfp.png',
                                      )
                                    : NetworkImage(
                                        data[index]['imageURL'],
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                data[index]['username'],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                data[index]['regNo'],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
