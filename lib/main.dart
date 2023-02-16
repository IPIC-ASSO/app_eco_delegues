import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image/image.dart' as imag;
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Forum.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({Key? key}) : super(key: key);

  static const String _title = 'App eco delegues';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays ([]);
    return const MaterialApp(
      title: _title,
      home: MonWidgetConnexion()
    );
  }
}

class MonWidgetConnexion extends StatefulWidget {
  const MonWidgetConnexion({Key? key}) : super(key: key);

  @override
  State<MonWidgetConnexion> createState() => _MonWidgetConnexionState();
}

class _MonWidgetConnexionState extends State<MonWidgetConnexion> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool mdpVisible = false;

  @override
  void initState() {
    super.initState();
    mdpVisible = true;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        Fluttertoast.showToast(
            msg: 'Bienvenue', backgroundColor: Colors.grey);
        Navigator.of(context).push(_sortieAutoroute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appli trop b1')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Groupe de discussion Eco-délégués',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'CONNEXION',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'email',
                  hintText: "adresse email",
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: mdpVisible,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mot de passe',
                  hintText: "Mot de passe",
                  /*suffixIcon: IconButton(
                      icon: Icon(mdpVisible? Icons.visibility: Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          mdpVisible = !mdpVisible;
                        });
                      }*/
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _showMyDialog();
              },
              child: const Text('Mot de passe oublié'),
            ),
            Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ElevatedButton(
                  child: const Text('Se connecter',style: TextStyle(fontSize: 18),),
                  onPressed: () {
                    connecte();
                  },
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Pas encore inscrit?'),
                TextButton(
                  child: const Text(
                    'S\'inscrire',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(_createRoute());
                  },
                )
              ],
            ),
          ],
        ))
    );
  }

  Future<void> connecte()async{
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connexion...'),
      ));
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: nameController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Utilisateur introuvable.'),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mot de passe incorrect.'),
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ah bah tant pis'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Les développeurs ont eu la flemme d\'implémenter cette fonctionnalité'),
                Text('Fallait pas perdre votre mot de passe ¯\\_(ツ)_/¯'),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text(':.('),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const MonWidgetIncription(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _sortieAutoroute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const MonWidgetPrincipal(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}




class MonWidgetIncription extends StatefulWidget {
  const MonWidgetIncription({Key? key}) : super(key: key);

  @override
  State<MonWidgetIncription> createState() => _MonWidgetIncriptionState();
}

class _MonWidgetIncriptionState extends State<MonWidgetIncription> {
  TextEditingController nameController = TextEditingController();
  TextEditingController pseudoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        Fluttertoast.showToast(
            msg: 'Bienvenue', backgroundColor: Colors.grey);
        Navigator.of(context).push(_sortieAutoroute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Appli trop b1')),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Groupe de discussion Eco-délégués',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'INSCRIPTION',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: "Adresse Email",
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: pseudoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nom d\'utilisateur',
                      hintText: "Nom d'utilisateur",
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(

                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mot de passe',
                      hintText: "Mot de passe",
                      /*suffixIcon: IconButton(
                      icon: Icon(mdpVisible? Icons.visibility: Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          mdpVisible = !mdpVisible;
                        });
                      }*/
                    ),
                  ),
                ),
                Container(
                    height: 70,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ElevatedButton(
                      child: const Text(
                        "S'inscrire", style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        nouvUti();
                      },
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Déjà inscrit?'),
                    TextButton(
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ],
            ))
    );
  }

  nouvUti()async{
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connexion...'),
      ));
      final credit = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: nameController.text,
        password: passwordController.text,
      );
      if (credit.user!=null){
        FirebaseFirestore db = FirebaseFirestore.instance;
        //String url = await dessine(pseudoController.text.characters.first) as String;
        final user = <String, dynamic>{
          "id": credit.user?.uid,
          "pseudo": pseudoController.text,
          //"photoCRI":url
        };
        db.collection("Utilisateurs").add(user).then((DocumentReference doc) =>
            print('DocumentSnapshot added with ID: ${doc.id}'));
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Le mot de passe est trop faible.'),
        ));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Un compte est déjà associé à cette adresse e-mail.'),
        ));
      }
    } catch (e) {
      print(e);
    }
  }
  Route _sortieAutoroute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const MonWidgetPrincipal(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<String> dessine(String txt) async {
    final recorder = PictureRecorder();
    final canvas = new Canvas(
        recorder,
        new Rect.fromPoints(
            new Offset(0.0, 0.0), new Offset(200.0, 200.0)));

    final paint = new Paint()
      ..color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(200, 200), 100, paint);

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 50,
    );
    final textSpan = TextSpan(
      text: txt,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    final xCenter = 100.0;
    final yCenter = 100.0;
    final offset = Offset(xCenter, yCenter);
    textPainter.layout();
    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    return(await enregistreImg(img as File));

  }

  Future<String> enregistreImg(File fichier) async {
    print('ok');
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child(DateTime.now().millisecondsSinceEpoch.toString());
    print("3");
    UploadTask uploadTask = reference.putFile(fichier);
    print("4");
    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }
}





