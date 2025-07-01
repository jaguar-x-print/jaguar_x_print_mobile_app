import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// États possibles
abstract class CardState {}

class CardInitial extends CardState {
  final List<Color> cardColors;
  CardInitial(this.cardColors);
}

// Événements possibles
abstract class CardEvent {}

class AddCardEvent extends CardEvent {}

// Bloc pour la gestion des cartes
class CardBloc extends Bloc<CardEvent, CardState> {
  CardBloc() : super(CardInitial([])) {
    on<AddCardEvent>((event, emit) {
      final random = Random();
      final newColor = Color.fromRGBO(
        random.nextInt(256), // Rouge (0-255)
        random.nextInt(256), // Vert (0-255)
        random.nextInt(256), // Bleu (0-255)
        1.0, // Opacité
      );
      final currentState = state as CardInitial;
      final updatedList = List<Color>.from(currentState.cardColors)..add(newColor);
      emit(CardInitial(updatedList));
    });
  }
}
