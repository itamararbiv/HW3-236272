import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/widgets.dart';

class MyUser
{
  late String? email;
  late List<String>? userSuggestions;

  MyUser({
    this.email,
    this.userSuggestions,
  });

  factory MyUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return MyUser(
      email: data?['Email'],
      userSuggestions: data?['Suggestions'] is Iterable ? List.from(data?['Suggestions']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "Email": email,
      if (userSuggestions != null) "Suggestions": userSuggestions,
    };
  }
}

