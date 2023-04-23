import 'dart:io';
import 'dart:math' as math;
import 'package:app_eco_delegues/laPoste.dart';
import 'package:app_eco_delegues/patrons/MesBellesCouleurs.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image/image.dart' as imag;
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      debugShowCheckedModeBanner: false,
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
  static final auth = FirebaseAuth.instance;
  bool mdpVisible = false;

  @override
  void initState() {
    super.initState();
    mdpVisible = true;
    auth.authStateChanges().listen((User? user) {
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
      appBar: AppBar(title: const Text('Demonstrateur')),
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
                      color: AppCouleur.eco,
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
                onSubmitted: (value) => connecte(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mot de passe',
                  hintText: "Mot de passe",
                  suffixIcon: IconButton(onPressed: (){setState(() {
                    mdpVisible = !mdpVisible;
                  });}, icon: Icon(mdpVisible? Icons.visibility: Icons.visibility_off)),
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
        email: nameController.text.replaceAll(' ', ''),
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

  Future<void> resetPassword({required String email}) async {
    await auth
        .sendPasswordResetEmail(email: email)
        .then((value) => Fluttertoast.showToast(
        msg: 'Envoyé!', backgroundColor: Colors.grey))
        .catchError(
            (e) => Fluttertoast.showToast(
                msg: 'Une erreur est survenue', backgroundColor: Colors.grey));

    return;
  }

  Future<void> _showMyDialog() async {
    final TextEditingController mailControl = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser le mot de passe'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10),
                child:Text('Veuillez rentrer votre adresse e-mail\nUn lien de récupération va vous être envoyé (pensez à vérifier les spams)')),
                TextField(
                  controller: mailControl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                    hintText: "adresse email",
                  ),
              ),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(onPressed: (){Navigator.of(context).pop();}, child: const Text('Annuler'),),
            OutlinedButton(
              child: const Text('Envoyer'),
              onPressed: () async{
                await resetPassword(email: mailControl.text);
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
  TextEditingController codeController = TextEditingController();

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
        appBar: AppBar(title: const Text('Demonstrateur')),
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
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Code',
                      hintText: "Code secret",
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

  nouvUti() async{
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connexion...'),
      ));
      FirebaseFirestore db = FirebaseFirestore.instance;
      FirebaseStorage sto = FirebaseStorage.instance;
      if(await new laPoste(firebaseFirestore: db, firebaseStorage: sto).verifcode(codeController.text)) {
        final credit = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: nameController.text.replaceAll(' ', ''),
          password: passwordController.text,
        );
        if (credit.user != null) {
          final user = <String, dynamic>{
            "id": credit.user?.uid,
            "pseudo": pseudoController.text
          };
          db.collection("Utilisateurs").doc(credit.user?.uid??DateTime.now().millisecondsSinceEpoch.toString()).set(user).then((value) =>
              print('Utilisateur enregistré')).onError((error, stackTrace) => print(error));
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Code incorrect :/'),
        ));
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
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('échec de l\'inscription.'),
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
}





