import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? uid;
  final String? username;
  final String? email;
  final String? passwordPaiement;
  final String? profilePhotoUrl;


  const UserModel({
    this.uid,
    this.username,
    this.email,
    this.passwordPaiement,
    this.profilePhotoUrl,
  });

  // Factory constructor pour fromMap
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      passwordPaiement: map['passwordPaiement'],
      profilePhotoUrl: map['profilePhotoUrl'],
    );
  }

  // Méthode toMap
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'passwordPaiement': passwordPaiement ?? '123',
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() => toMap();

  // Désérialisation JSON (corrigée)
  static UserModel fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  // Méthode de copie avec modification
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? passwordPaiement,
    String? profilePhotoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordPaiement: passwordPaiement ?? this.passwordPaiement,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'uid: $uid, '
        'username: $username, '
        'email: $email, '
        'passwordPaiement: $passwordPaiement, ' // Include in toString
        'profilePhotoUrl: $profilePhotoUrl)';
  }

  // Override des props pour Equatable
  @override
  List<Object?> get props => [
    uid,
    username,
    email,
    passwordPaiement, // Include in props
    profilePhotoUrl,
  ];
}