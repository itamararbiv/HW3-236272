import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './providers/firebase_notifier.dart';
import './screens/login_screen.dart';
import './classes/MyUser.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (ctx) => FirebaseNotifier(),
        child: MaterialApp(
          title: 'Startup Name Generator',
          theme: ThemeData(
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              primarySwatch: Colors.blue),
          home: const RandomWords(),
        ));
  }
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final _icons = [const Icon(Icons.login), const Icon(Icons.logout)];
  final _tooltip = ["Login", "Logout"];
  final sheetController = SnappingSheetController();
  bool isSheetEnabled = false;

  @override
  Widget build(BuildContext context) {
    bool checking = context.watch<FirebaseNotifier>().loginStatusChanged;
    context.watch<FirebaseNotifier>().localSaved.length;
    context.watch<FirebaseNotifier>().imageAmountChanges;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          IconButton(
              icon: _icons[context.watch<FirebaseNotifier>().getUserStatus()],
              tooltip:
                  _tooltip[context.watch<FirebaseNotifier>().getUserStatus()],
              onPressed: () {
                if (context.read<FirebaseNotifier>().getUserStatus() == 0) {
                  openLoginScreen();
                  context.watch<FirebaseNotifier>().loginStatusChanged =
                      !context.watch<FirebaseNotifier>().loginStatusChanged;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully logged out')));
                  context.read<FirebaseNotifier>().signOut();
                }
              }),
        ],
      ),
      body: (context.watch<FirebaseNotifier>().currentUserEmail == "")
          ? offlineMode()
          : onlineMode(),
    );
  }

  void openLoginScreen() {
    context.read<FirebaseNotifier>().setHintForLoginAfterRegister(false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  List<SnappingPosition> getSnappingPositions() {
    if (isSheetEnabled) {
      return const [
        SnappingPosition.factor(
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(seconds: 1),
          positionFactor: 0.03,
        ),
        SnappingPosition.factor(
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(seconds: 1),
          positionFactor: 1,
        )
      ];
    } else {
      return const [
        SnappingPosition.factor(
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(seconds: 1),
          positionFactor: 0.08,
        )
      ];
    }
  }

  void pickUpNewAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) {
        return;
      }

      await context.read<FirebaseNotifier>().updateImage();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Picture Is Loading... Please Wait.')));
      await context.read<FirebaseNotifier>().uploadFile(
          image.path,
          "usersAvatarImages/${context.read<FirebaseNotifier>().currentUser?.uid}",
          "1111");
      if (!mounted) {
        return;
      }
      await context.read<FirebaseNotifier>().downloadFile("usersAvatarImages",
          context.read<FirebaseNotifier>().currentUser?.uid ?? "");
      if (!mounted) {
        return;
      }
      context.read<FirebaseNotifier>().imageAmountChanges =
          1 + context.read<FirebaseNotifier>().imageAmountChanges;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changing Profile Picture Success!')));
    } else {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No image selected')));
    }
  }

  void switchSheetState() {
    setState(() {
      isSheetEnabled = !isSheetEnabled;
      sheetController.setSnappingSheetFactor(isSheetEnabled ? 0.20 : 0.03);
    });
  }

  Widget onlineMode() {
    return SnappingSheet(
      controller: sheetController,
      lockOverflowDrag: true,
      snappingPositions: getSnappingPositions(),
      grabbing: _UserGrabbingWidget(switchSheetState),
      grabbingHeight: 45,
      sheetAbove: isSheetEnabled
          ? SnappingSheetContent(
              child: const BlurredBackgroundMask(), draggable: false)
          : null,
      sheetBelow: SnappingSheetContent(
          child: Container(
            color: Colors.white,
            child: ListView(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 40,
                          backgroundImage:
                              context.watch<FirebaseNotifier>().avatarImage),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              context
                                  .watch<FirebaseNotifier>()
                                  .currentUserEmail,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.lightBlue,
                              ),
                              onPressed: () => pickUpNewAvatar(),
                              child: const Text(
                                "Change avatar",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          draggable: true),
      child: offlineMode(),
    );
  }

  Widget offlineMode() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        final alreadySaved = context
            .watch<FirebaseNotifier>()
            .localSaved
            .contains(_suggestions[index]);

        return ListTile(
          title: Text(
            _suggestions[index].asPascalCase,
            style: _biggerFont,
          ),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
            semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
          ),
          onTap: () {
            if (context.read<FirebaseNotifier>().currentUser != null) {
              if (alreadySaved) {
                context
                    .read<FirebaseNotifier>()
                    .removeSuggestion(_suggestions[index]);
              } else {
                context
                    .read<FirebaseNotifier>()
                    .addSuggestion(_suggestions[index]);
              }
            } else {
              if (alreadySaved) {
                context
                    .read<FirebaseNotifier>()
                    .removeOfflineSuggestion(_suggestions[index]);
              } else {
                context
                    .read<FirebaseNotifier>()
                    .addOfflineSuggestion(_suggestions[index]);
              }
            }
          },
        );
      },
    );
  }

  void _pushSaved() {
    int index = -1;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = context.watch<FirebaseNotifier>().localSaved.map(
            (pair) {
              index = index + 1;
              return Dismissible(
                  confirmDismiss: (DismissDirection direction) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Suggestion'),
                          content: Text(
                              'Are you sure you want to delete ${pair.asPascalCase} from your saved suggestions?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context
                                        .read<FirebaseNotifier>()
                                        .currentUser !=
                                    null) {
                                  context
                                      .read<FirebaseNotifier>()
                                      .removeSuggestion(pair);
                                } else {
                                  context
                                      .read<FirebaseNotifier>()
                                      .removeOfflineSuggestion(pair);
                                }
                                Navigator.pop(context, true);
                              },
                              child: const Text('Yes'),
                            )
                          ],
                        );
                      },
                    );
                    debugPrint('Deletion confirmed: $confirmed');
                    return confirmed;
                  },
                  background: Container(
                      color: Colors.deepPurple,
                      child: const Text.rich(TextSpan(
                        children: [
                          WidgetSpan(child: Icon(Icons.delete)),
                          TextSpan(text: 'Delete Suggestion'),
                        ],
                      ))),
                  key: Key('item $index'),
                  child: ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                  ));
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _UserGrabbingWidget extends StatelessWidget {
  Function() switchSheetStateFunc;
  String userEmail = "";

  _UserGrabbingWidget(this.switchSheetStateFunc);

  @override
  Widget build(
    BuildContext context,
  ) {
    userEmail =
        Provider.of<FirebaseNotifier>(context, listen: true).currentUserEmail;

    return GestureDetector(
        onTap: () => switchSheetStateFunc(),
        child: Container(
          alignment: Alignment.centerLeft,
          color: const Color(0xFFCFD8DC),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text("Welcome back, $userEmail",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.keyboard_arrow_up_sharp),
              ),
            ],
          ),
        ));
  }
}

class BlurredBackgroundMask extends StatelessWidget {
  const BlurredBackgroundMask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2.5,
          sigmaY: 2.5,
        ),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
