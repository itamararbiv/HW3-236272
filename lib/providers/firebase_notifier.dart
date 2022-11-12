import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_me/classes/MyUser.dart';
import '../enums/app_enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class FirebaseNotifier extends ChangeNotifier
{
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _firestorage = FirebaseStorage.instance;
  AuthState _authStatus =  AuthState.UnAuthenticated;
  User? _currentUser;
  String _currentUserEmail = "";
  bool _signInStatus = false;
  MyUser? userDetails;
  String? currentUserDocId;
  Set<WordPair> localSaved = <WordPair>{};
  bool hintForLoginAfterRegister = false;
  var _avatarImage;
  final defaultImage = "https://media.istockphoto.com/id/1223671392/vector/default-profile-picture-avatar-photo-placeholder-vector-illustration.jpg?s=612x612&w=0&k=20&c=s0aTdmT5aU6b8ot7VKm11DeID6NctRCpB755rA1BIP0=";
  bool _loginStatusChanged = false;
  int _imageAmountChanges = 0;


  FirebaseNotifier();

  bool get loginStatusChanged => _loginStatusChanged;
  int get imageAmountChanges => _imageAmountChanges;
  User? get currentUser => _currentUser;
  bool get signInStatus => _signInStatus;
  AuthState get authStatus =>  _authStatus;
  String get currentUserEmail => _currentUserEmail;
  FirebaseStorage get firestorage => _firestorage;
  dynamic get avatarImage => _avatarImage;


  set loginStatusChanged(bool newValue)
  {
    _loginStatusChanged = newValue;
    notifyListeners();
  }

  set imageAmountChanges(int newVal)
  {
    _imageAmountChanges = newVal;
    notifyListeners();
  }


  set signInStatus(bool newStats)
  {
    _signInStatus = newStats;
    notifyListeners();
  }

  set authStatus(AuthState state) {
    _authStatus = state;
    notifyListeners();
  }

  set currentUserEmail(String email) {
    _currentUserEmail = email;
    notifyListeners();
  }

  set avatarImage(var image) {
    _avatarImage = image;
    notifyListeners();
  }

  void setHintForLoginAfterRegister(bool newValue)
  {
    hintForLoginAfterRegister = newValue;
    notifyListeners();
  }

  void addOfflineSuggestion(WordPair word)
  {
    debugPrint("Function addOfflineSuggestion");
    localSaved.add(word);
    notifyListeners();
  }


  void removeOfflineSuggestion(WordPair word)
  {
    debugPrint("Function removeOfflineSuggestion");
    localSaved.remove(word);
    notifyListeners();
  }

  Future<void> removeSuggestion(WordPair word) async
  {
    WordPair wordToDelete = WordPair(word.first[0].toUpperCase() + word.first.substring(1,word.first.length),  word.second[0].toUpperCase() + word.second.substring(1,word.second.length));
    debugPrint(wordToDelete.first);
    debugPrint(wordToDelete.second);
    debugPrint("Function removeSuggestion");
    localSaved.remove(word);
    debugPrint("Size ${localSaved.length}");
    for (var x in localSaved)
      {
        debugPrint(x.first);
        debugPrint(x.second);

      }
    List<String> newList = [];
    for (var element in localSaved) {
      newList.add(element.first[0].toUpperCase() + element.first.substring(1,element.first.length)  + element.second[0].toUpperCase() + element.second.substring(1,element.second.length) );
    }
    newList.toSet().toList();
    await _firestore.collection('users').doc(currentUserDocId).update({"Suggestions":newList});
    notifyListeners();
  }

  Future<void> addSuggestion(WordPair word) async
  {
    debugPrint("Function addSuggestion");
    localSaved.add(word);
    List<String> newList = [];
    for (var element in localSaved) {
      newList.add(element.first[0].toUpperCase() + element.first.substring(1,element.first.length)  + element.second[0].toUpperCase() + element.second.substring(1,element.second.length) );
    }
    newList.toSet().toList();
    await _firestore.collection('users').doc(currentUserDocId).update({"Suggestions":newList});
    notifyListeners();
  }

  WordPair convertToWordPair(String s) {
    String newS = s.toLowerCase();
    int count = 0;
    int index = 0;
    while (count != 2)
    {
      if (s[index] != newS[index])
      {
        count++;
      }
      index++;
    }
    return WordPair(newS.substring(0, index - 1), newS.substring(index - 1, s.length));
  }


  Future<void> updateImage() async
  {
    await _firestore
        .collection('users')
        .doc(currentUserDocId)
        .update({'ImagePath': currentUser?.uid});
    notifyListeners();

  }

  void beginAuthStateChanges()
  {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _authStatus = AuthState.UnAuthenticated;
      }
      else {
        _currentUser = firebaseUser;
        _authStatus = AuthState.Authenticating;
      }
      notifyListeners();
    } );
  }

  Future<DocumentSnapshot> getUser() async {
    var result = await _firestore
        .collection('users')
        .doc(currentUserDocId)
        .get();
    return result;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _signInStatus = true;
      authStatus = AuthState.Authenticating;
      notifyListeners();
      debugPrint("Itamar debuging check");

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint("Itamar debuging check");
      currentUserEmail = email;
      _currentUser = _auth.currentUser;
      await _firestore.collection("users").where("Email", isEqualTo: currentUserEmail).get().then(
            (res) => currentUserDocId = res.docs[0].id,
        onError: (e) => debugPrint("Error completing: $e"),
      );
      debugPrint("DocId: $currentUserDocId");
      final ref = _firestore.collection("users").doc(currentUserDocId).withConverter(
        fromFirestore: MyUser.fromFirestore,
        toFirestore: (MyUser currUserF, _) => currUserF.toFirestore(),
      );
      final docSnap = await ref.get();
      final currUserData = docSnap.data();
      int length = 0;
      if (currUserData != null) {
          var snap = await _firestore
              .collection('users')
              .doc(currentUserDocId).get();
          var dat = snap.data();
          var existData= dat?["ImagePath"];
          if (existData == null)
            {
              _firestore
                  .collection('users')
                  .doc(currentUserDocId)
                  .update({'ImagePath': "blanck.jpg"});
              existData = "blank.jpg";
            }

          downloadFile("usersAvatarImages", existData);




        bool exist = true;



        // debugPrint(avatarImage);
        length = currUserData.userSuggestions!.length;
        if (length > 0) {
          debugPrint("First Word Value: ${currUserData.userSuggestions![0]} ");
        }
        else {
          debugPrint("The user has not have currently any favorites...");
        }
        var updateList = [];
        for (int i = 0; i < length; i++)
          {
            localSaved.add(convertToWordPair(currUserData.userSuggestions![i]));
          }
          for (var element in localSaved) {
            updateList.add(element.first[0].toUpperCase() + element.first.substring(1,element.first.length)  + element.second[0].toUpperCase() + element.second.substring(1,element.second.length) );
          }
          updateList = updateList.toSet().toList();
          await _firestore.collection('users').doc(currentUserDocId).update({"Suggestions":updateList});
          for (int i = 0; i < updateList.length; i++)
          {
                debugPrint("List i : ${updateList[i]}" );

          }

      }

      return true;
    }
    catch (e) {
      debugPrint("Error occurs at sign in!");
      authStatus = AuthState.UnAuthenticated;
      notifyListeners();
      currentUserEmail = "";
      _signInStatus = false;
      return false;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      _signInStatus = true;
      authStatus = AuthState.Authenticating;
      notifyListeners();
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = userCredential.user;
      await _firestore.collection('users')
          .add({
        'Email': email,
        'Suggestions': [],
        'ImagePath': "blanck.jpg"
      });
      return user;
    }
    catch (e) {
      _signInStatus = false;
      authStatus = AuthState.UnAuthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async
  {
    try {
      _currentUser = null;
      currentUserEmail = "";
      notifyListeners();
      await _auth.signOut();
      _signInStatus = false;

    }
    catch (e) {
      notifyListeners();
    }
  }


  void addItemDataToFirebase(dynamic value)
  {
    _firestore.collection('users').doc(currentUserDocId).update({"ImagePath":value});
  }

  // return 0 if the player is logout, and 1 if the player is login.
  int getUserStatus() {
    if (_currentUser == null)
    {
      return 0;
    }
    return 1;
  }

  Future<void> uploadFile(String localPath, String cloudPath, String filename) async {
    var fileRef = _firestorage.ref(cloudPath); // cloudPath = “images/profile.jpg”
    var file = File(localPath);
    try {
      await fileRef.putFile(file);

    }
    catch (e) { debugPrint("Error On Upload this file..."); }
  }

  Future<String> downloadFile(String cloudPath, String filename) async {
    try {
      var avatarURL = await _firestorage
          .ref(cloudPath)
          .child(filename)
          .getDownloadURL();
      debugPrint("download url is: k${avatarURL}k");
       avatarImage = NetworkImage(avatarURL);
       notifyListeners();
      return avatarURL;
    }
    catch (e)
    {
      avatarImage = defaultImage;
      return "";
    }
  }

  Future<NetworkImage> getUserUpdatePicture(String cloudPath, String? filename) async
  {
    var fileURL = await  downloadFile(cloudPath, filename!);
    debugPrint("DEBUGINGG,,");
    return NetworkImage(fileURL);
  }
}

