import 'package:equatable/equatable.dart';

class Utilisateur extends Equatable{

  final String id;
  final String pseudo;
  final String photoCRI;

  const Utilisateur(this.id, this.pseudo, this.photoCRI);

  @override
  List<Object?> get props => [id,pseudo,photoCRI];
}