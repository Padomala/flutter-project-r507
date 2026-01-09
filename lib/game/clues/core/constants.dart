import 'package:flutter/material.dart';

const Color kBackgroundColor = Color(0xFF1A1A1A);
const Color kPrimaryColor = Colors.lightBlue; 
const Color kErrorColor = Colors.redAccent;
const Color kSuccessColor = Colors.greenAccent;
const Color kTextColor = Colors.white;


// Map (dictionnaire) contenant le mot cible comme clé et une liste d'indices comme valeur
const Map<String, List<String>> kGuessingGameClues = {
  'CHIEN': [
    "Aime les os",
    "Jappe/aboie",
    "Est un meilleur ami",
    "A une queue qui remue",
  ],
  'POMME': [
    "Est rouge ou verte",
    "Pousse dans les arbres",
    "Fait partie du cidre",
    "Peut tomber sur la tête",
  ],
  'SOLEIL': [
    "Est chaud et lumineux",
    "Se lève à l'est",
    "Est au centre du système",
    "Fait pousser les plantes",
  ],
  'PLAGE': [
    "On y trouve du sable",
    "On peut y faire des châteaux",
    "Est près de la mer",
    "On y va en vacances",
  ],
};