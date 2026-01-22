import 'package:flutter/material.dart';

/// Liste de couleurs
const Color kBackgroundColor = Color(0xFF1A1A1A);
const Color kPrimaryColor = Colors.lightBlue;
const Color kErrorColor = Colors.redAccent;
const Color kSuccessColor = Colors.greenAccent;
const Color kTextColor = Colors.white;

/// Liste de mots interdits pour chaque mot cible
const Map<String, List<String>> kTabooWords = {
  'CHIEN': ['OS', 'ABOYER', 'LAISSE'],
  'POMME': ['FRUIT', 'TARTE', 'ROUGE'],
  'SOLEIL': ['CIEL', 'JAUNE', 'CHAUD'],
  'PLAGE': ['SABLE', 'MER', 'VACANCES'],
  'FOOTBALL': ['BALLON', 'BUT', 'SPORT'],
  'AMOUR': ['COEUR', 'AILER', 'ROUGE'],
};

//Liste de thèmes + mots à faire deviner associer
const Map<String, List<String>> hotColdWords = {
  'Animaux': ['CHIEN', 'CHAT', 'POISSON', 'OISEAU', 'REQUIN', 'LION'],
  'Fruits': ['POMME', 'BANANE', 'KIWI', 'MANGUE', 'MELON', 'POIRE'],
  'Sports': ['FOOTBALL', 'BASKET', 'TENNIS', 'VOLE', 'GOLF', 'RUGBY'],
  'Voyages': ['PARIS', 'LONDRES', 'ROMA', 'TAHITI', 'NEW YORK', 'MADRID'],
  'Musique': ['GUITARE', 'PIANO', 'VIOLIN', 'TRUMPET', 'SAXOPHONE', 'BAZOOKA'],
  'Vêtements': ['CHIFFON', 'COUTURIER', 'ROUGE', 'BLEU', 'JAUNE', 'VERT'],
  'Ville': ['PARIS', 'LONDRES', 'ROMA', 'TAHITI', 'NEW YORK', 'MADRID'],
  'Aliments': ['POMME', 'BANANE', 'KIWI', 'MANGUE', 'MELON', 'POIRE'],
};
