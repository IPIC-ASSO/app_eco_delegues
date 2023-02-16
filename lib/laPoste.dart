import 'dart:io';
import 'dart:typed_data';
import 'package:app_eco_delegues/patrons/MesConstantes.dart';
import 'package:app_eco_delegues/patrons/Message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class laPoste{

  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  laPoste({
    required this.firebaseFirestore,
    required this.firebaseStorage
  });

  UploadTask chargeFichier(File fichier, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(fichier);
    return uploadTask;
  }

  UploadTask chargeDatum(Uint8List datum, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putData(datum);
    return uploadTask;
  }

  Reference verseFichier(String nomFichier){
    Reference reference = firebaseStorage.ref().child(nomFichier);
    return reference;
  }

  Future<int> getNombreMessages(){
    return firebaseFirestore.collection(FirestoreConstants.cheminMessages).snapshots().length;
  }

  Stream<QuerySnapshot> getChatMessage(int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.cheminMessages)
        .orderBy(FirestoreConstants.temps, descending: true)
        .limit(limit)
        .snapshots();
  }


  Stream<QuerySnapshot> prendNomDest(){
    return firebaseFirestore.collection(FirestoreConstants.cheminUtilisateur).snapshots();
  }

  void envoie(String corps, int type,
      String idEnvoyeur) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.cheminMessages)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());
    Message chatMessages = Message(
        envoyeur: idEnvoyeur,
        temps: DateTime.now().millisecondsSinceEpoch.toString(),
        corps: corps,
        type: type);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }
}