import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:path/path.dart' as p;
import 'package:app_eco_delegues/laPoste.dart';
import 'package:app_eco_delegues/patrons/MesBellesCouleurs.dart';
import 'package:app_eco_delegues/patrons/MesConstantes.dart';
import 'package:app_eco_delegues/patrons/Message.dart';
import 'package:app_eco_delegues/patrons/Outils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import 'GrosPlan.dart';

class MonWidgetPrincipal extends StatefulWidget{
  const MonWidgetPrincipal({Key? key}) : super(key: key);

  @override
  State<MonWidgetPrincipal> createState() => _MonWidgetPrincipal();
}

class _MonWidgetPrincipal extends State<MonWidgetPrincipal> {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseStorage grosseDB = FirebaseStorage.instance;
  late String idUtilisateur;
  late String urlAvatarUti;
  late laPoste monPostier;
  List<QueryDocumentSnapshot> listMessages = [];
  List<QueryDocumentSnapshot> listeUti = [];
  final int _ajoutLimite = 20;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  int _limite = 20;
  int nbMessages = 0;
  bool modif = false;
  int indiceMessageModif=0;
  File? monFichier;
  File? imageFile;
  String imageUrl = '';
  String URLmonFichier = '';
  bool caCharge = false;

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: db, firebaseStorage: grosseDB);
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pop(context);
      }else{
        idUtilisateur = user.uid;
      }
    });
    initializeDateFormatting('fr_FR');
  }

  // message posté!
  bool unMessagePoste(int index) {
    if ((index > 0 && listMessages[index - 1].get(FirestoreConstants.envoyeur) !=
            idUtilisateur) ||  index == 0) {
      return true;
    } else {
      return false;
    }
  }



  // message posté!
  bool unAncienMessagePoste(int index) {
    if ((index < listMessages.length-1 && listMessages[index + 1].get(FirestoreConstants.envoyeur) !=
        idUtilisateur) ||  index == listMessages.length-1) {
      return true;
    } else {
      return false;
    }
  }

  bool unAncienMessageRecu(int index) {
    if ((index < listMessages.length-1 && listMessages[index + 1].get(FirestoreConstants.envoyeur) !=
        listMessages[index].get(FirestoreConstants.envoyeur)) ||  index == listMessages.length-1) {
      return true;
    } else {
      return false;
    }
  }

  //facteur qui passe
  bool unMessageRecu(int index) {
    if ((index > 0 && listMessages[index - 1].get(FirestoreConstants.envoyeur) !=
        listMessages[index].get(FirestoreConstants.envoyeur)) ||  index == 0) {
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Forum'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: ()=>montreInfos(), icon: const Icon(Icons.info_outline)),
            IconButton(
              onPressed: ()=>deco(),
              icon: const Icon(Icons.logout),
            )
          ],
      ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                buildListMessage(),
                buildMessageInput(),
              ],
            ),
          ),
        ),
    );
  }


  Widget buildMessageInput() {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: modif?AppCouleur.banni:AppCouleur.principal,
                borderRadius: BorderRadius.circular(30),
              ),
              child: modif?
              IconButton(onPressed: ()=>suprMessage(indiceMessageModif),
                  icon: Icon(Icons.delete_forever, size: 28,)):
              IconButton(
                onPressed:()=>{
                  _pickFile()},
                icon: const Icon(
                  Icons.file_present_outlined,
                  size: 28,
                ),
              ),
            ),
            Flexible(
              child:Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                textInputAction:TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Votre message'
                ),
                onSubmitted: (value) {
                  //versLaPoste(textEditingController.text, MessageType.texte);
                },
              ))),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppCouleur.principal
              ),
              child: modif?
              IconButton(
                  onPressed: ()=>verslaPosteModif(textEditingController.text,indiceMessageModif),
                  icon: Icon(Icons.save_as)):
              IconButton(
                onPressed: () {
                  versLaPoste(textEditingController.text, MessageType.texte);
                },
                icon: const Icon(Icons.send_rounded),

              ),
            ),
          ],
      ),
      )
    );
  }


  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: monPostier.prendNomDest(),
        builder: (BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listeUti = snapshot.data!.docs;
            return StreamBuilder<QuerySnapshot>(
                stream: monPostier.getChatMessage(_limite+2),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    listMessages = snapshot.data!.docs;
                    if (listMessages.isNotEmpty) {
                      return GestureDetector(
                        onDoubleTap: ()=>annuleModif(),
                          child:ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            reverse: true,
                            controller: scrollController,
                            itemBuilder: (context, index) =>
                                construitChat(index, snapshot.data?.docs[index])));
                    } else {
                      return const Center(
                        child: Text('Pas de messages...'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppCouleur.charge,
                      ),
                    );
                  }
                });
          }
          else{
            return const Center(
              child: CircularProgressIndicator(
                color: AppCouleur.charge,
              ),
            );
          }
        }
    ));
  }


  Widget construitChat (int index, DocumentSnapshot? documentSnapshot)  {
    if (documentSnapshot != null) {
      Message chaton = Message.fromDocument(documentSnapshot);
      if(index >_limite){
        return const SizedBox.shrink();
      }
      if (index == _limite && _limite<listMessages.length){
        return Visibility(
          visible: _limite<listMessages.length,
            child: Container(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
              width: 20,
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed:(){setState(() {
                  _limite+= _ajoutLimite;
                });},
                child: const Text("Charger plus de messages"),
              )
            )
        );
      }
      else if (chaton.envoyeur == idUtilisateur) {  //c'est moi qui envoie--> droite
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chaton.type == MessageType.texte ? GestureDetector(
                  onLongPress: ()=>modifMessage(index),
                  onDoubleTap: ()=>modifMessage(index),
                  child:messageBubble(
                    corps: chaton.corps,
                    color: AppCouleur.droitier,
                    textColor: AppCouleur.white,
                    margin: const EdgeInsets.fromLTRB(0,1,3,1),
                    bords:BorderRadius.only(
                      bottomLeft:  unMessagePoste(index)?const Radius.circular(10.0):const Radius.circular(0),
                      topLeft: unAncienMessagePoste(index)?const Radius.circular(10.0):const Radius.circular(0),
                      topRight:unAncienMessagePoste(index)? const Radius.circular(10.0):const Radius.circular(0),)))
                 : chaton.type == MessageType.image ? Container(
                  margin: const EdgeInsets.only(right: 10, top: 10),
                  child: chatImage(
                      imageSrc: chaton.corps,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return GrosPlan(url:chaton.corps);
                  }));},))
                    : chaton.type == MessageType.datum ?Container(
                  margin: const EdgeInsets.only(right: 10, top: 10),
                  child: imageDatum(datum: recupDatum(chaton.corps), onTap: () {})):Container(
                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                  margin: const EdgeInsets.only(right: 10, top: 10),
                  child:OutlinedButton.icon( // <-- OutlinedButton
                    onPressed: ()=> telechargeFichier(chaton.corps),
                    icon: const Icon(
                      Icons.file_present_sharp,
                      size: 24.0,
                    ),
                    label: RichText(
                    overflow: TextOverflow.ellipsis,text:TextSpan(style:
                    const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    ),text:p.basename(chaton.corps))),
                  ),
                ),
              ],
            ),
            unMessagePoste(index)
                ? Container(
              margin: const EdgeInsets.only(
                  right: 50,
                  top: 6,
                  bottom: 8),
              child: Text(
                DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chaton.temps),
                  ),
                ),
                style: const TextStyle(
                    color: AppCouleur.grisClair,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      } else {//c'est les autres
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            unAncienMessageRecu(index)? Container(
              margin: const EdgeInsets.only(left: 3, top: 3, bottom: 1),
              child: Text(litNomUti(index),
                  style: const TextStyle(color: AppCouleur.gaucher,
                      fontSize: 16))): const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                chaton.type == MessageType.texte
                    ? messageBubble(
                  color: AppCouleur.gaucher,
                  textColor: AppCouleur.white,
                  corps: chaton.corps,
                  bords:BorderRadius.only(
                  bottomLeft:  unMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),
                  bottomRight: unMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),
                  topRight:unAncienMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),),
                  margin: const EdgeInsets.fromLTRB(3,1,0,1),
                )
                    : chaton.type == MessageType.image
                    ? Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  child: chatImage(imageSrc: chaton.corps, onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return GrosPlan(url:chaton.corps);
                  }));}),//
                )
                :chaton.type == MessageType.datum ?Container(
                    margin: const EdgeInsets.only(right: 10, top: 10),
                    child: imageDatum(datum: recupDatum(chaton.corps), onTap: () {})): Container(
                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                  margin: const EdgeInsets.only(right: 10, top: 10),
                  child:OutlinedButton.icon( // <-- OutlinedButton
                    onPressed: ()=> telechargeFichier(chaton.corps),
                    icon: const Icon(
                      Icons.file_present_sharp,
                      size: 24.0,
                    ),
                    label: RichText(
                        overflow: TextOverflow.ellipsis,text:TextSpan(style:
                    const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),text:p.basename(chaton.corps))),
                  ),
                ),
              ],
            ),
            unMessageRecu(index) ? Container(
              margin: const EdgeInsets.only(left: 50, top: 6, bottom: 8),
              child: Text(
                DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chaton.temps),
                  ),
                ),
                style: const TextStyle(
                    color: AppCouleur.grisClair,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  montreInfos() {
    return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
      return AlertDialog(
          title: const Text('Informations'),
          content: SingleChildScrollView(
              child: Text("Application développée et maintenue par IPIC-ASSO.\nPour toute question, problème, réclamation ou suggestion, contactez nous à l'adresse ipic.assistance@protonmail.com")));});}

  modifMessage(int index){
    setState(() {
      modif = true;
    });
    indiceMessageModif = index;
    textEditingController.text = Message.fromDocument(listMessages[index]).corps;
  }

  suprMessage(int index){
    setState(() {
      modif = false;
    });
    textEditingController.clear();
    monPostier.supprime(listMessages[index].reference.path);
  }

  verslaPosteModif(String corps, int index){
    setState(() {
      modif = false;
    });
    textEditingController.clear();
    print(listMessages[index].reference.path);
    monPostier.modifie(listMessages[index].reference.path, corps);
  }

  annuleModif(){
    if(modif){
      setState(() {
        modif = false;
      });
      textEditingController.clear();
    }
  }

  Uint8List recupDatum(String fausseDatum){
    List<int> list = utf8.encode(fausseDatum);
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;//base64Decode(fausseDatum);
  }

  void versLaPoste(String corps, int type) {
    if (corps.trim().isNotEmpty) {
      textEditingController.clear();
      monPostier.envoie(corps, type, idUtilisateur);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Votre message est vide', backgroundColor: Colors.grey);
    }
  }

  String litNomUti(int index) {
    final String id = listMessages[index].get(FirestoreConstants.envoyeur);
    for(DocumentSnapshot doc in listeUti){
      if (id == doc.get("id")) return doc.get("pseudo")??"inconnu au bataillon";
    }
    return 'inconnu au bataillon';
  }

  void _pickFile() async {
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          final fileBytes = result.files.first.bytes;
          final fileName = result.files.first.name;
          televerseDatum(fileName, fileBytes!);

        }else{
          monFichier = File(result.files.first.path??"");
          televerseFichier();
        }
      }else{
        Fluttertoast.showToast(msg:"Echec du chargement");
      }
    }catch(e){
      print(e);
    }
    return;
  }




  telechargeFichier(String nomFichier) async{
    final Reference ref = monPostier.verseFichier(nomFichier);
    if (kIsWeb){
      String url = await ref.getDownloadURL();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw Exception('Could not launch $url');
      }
        Fluttertoast.showToast(msg: "impossible de récupérer le lien de téléchargement");
      return;
    }
    var dir = await DownloadsPathProvider.downloadsDirectory;

    if(dir != null){
      String downloadfolder = dir.path;
      //String downloadfolder2 = docdir.path;
      String fichierChemin = "$downloadfolder/$nomFichier";
      final fichier = File(fichierChemin);
      final vers = ref.writeToFile(fichier);
      vers.snapshotEvents.listen((taskSnapshot){
        switch (taskSnapshot.state) {
          case TaskState.running:
            Fluttertoast.showToast(msg:"Enregistrement...");
            break;
          case TaskState.paused:
            Fluttertoast.showToast(msg:"Mis en pause...");
            break;
          case TaskState.success:
            Fluttertoast.showToast(msg:"Fichier enregistré dans les téléchargements");
            break;
          case TaskState.canceled:
            Fluttertoast.showToast(msg:"Téléchargement interrompu.");
            break;
          case TaskState.error:
            Fluttertoast.showToast(msg:"Erreur lors du téléchargement.");
            break;
        }
      });

    }else{
      Fluttertoast.showToast(msg:"Repertoire de destination introuvable.");
    }
  }

  void deco() async{
    await FirebaseAuth.instance.signOut();
  }


  void televerseFichier() async {
    String nomFichier = p.basename(monFichier?.path??"document inconnu");
    UploadTask uploadTask = monPostier.chargeFichier(monFichier!, nomFichier);
    try {
      TaskSnapshot snapshot = await uploadTask;
      URLmonFichier = await snapshot.ref.getDownloadURL();
      setState(() {
        caCharge = false;
        var mesExtension = ['.png','.jpeg','.jpg'];
        String fileExtension = p.extension(monFichier!.path);
        Fluttertoast.showToast(msg: "Envoi");
        if (mesExtension.contains(fileExtension)){
          versLaPoste(URLmonFichier, MessageType.image);
        }else{
          versLaPoste(nomFichier, MessageType.autre);
        }

      });
    } on FirebaseException catch (e) {
      setState(() {
        caCharge = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }


  void televerseDatum(String nomFichier, Uint8List datum) async {
    UploadTask uploadTask = monPostier.chargeDatum(datum, nomFichier);
    try {
      TaskSnapshot snapshot = await uploadTask;
      URLmonFichier = await snapshot.ref.getDownloadURL();
      setState(() {
        caCharge = false;
        versLaPoste(nomFichier, MessageType.autre);
        /*var mesExtension = ['.png','.jpeg','.jpg'];
        String fileExtension = p.extension(nomFichier);
        if (mesExtension.contains(fileExtension)){
          versLaPoste(URLmonFichier, MessageType.datum);
        }else{
          versLaPoste(nomFichier, MessageType.autre);
        }*/

      });
    } on FirebaseException catch (e) {
      setState(() {
        caCharge = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }
}




