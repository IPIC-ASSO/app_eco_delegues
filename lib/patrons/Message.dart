import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'MesConstantes.dart';


class Message {

  String envoyeur;
  String corps;
  String temps;
  int type;

  Message(
      {required this.envoyeur,
        required this.temps,
        required this.corps,
        required this.type});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.envoyeur: envoyeur,
      FirestoreConstants.temps: temps,
      FirestoreConstants.message: corps,
      FirestoreConstants.type: type,
    };
  }

  factory Message.fromDocument(DocumentSnapshot documentSnapshot) {
    String envoyeur = documentSnapshot.get(FirestoreConstants.envoyeur);
    String temps = documentSnapshot.get(FirestoreConstants.temps);
    String corps = documentSnapshot.get(FirestoreConstants.message);
    int type = documentSnapshot.get(FirestoreConstants.type);

    return Message(
      envoyeur: envoyeur,
      temps:temps,
      corps:corps,
      type: type);
  }
}

class MessageType {
  static const texte = 0;
  static const image = 1;
  static const datum = 2;
  static const autre = 3;
}