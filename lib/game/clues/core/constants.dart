import 'package:flutter/material.dart';

/// Liste de couleurs
const Color kBackgroundColor = Color(0xFF1A1A1A);
const Color kPrimaryColor = Colors.lightBlue;
const Color kErrorColor = Colors.redAccent;
const Color kSuccessColor = Colors.greenAccent;
const Color kTextColor = Colors.white;

/// Liste de mots interdits pour chaque mot cible
const Map<String, List<String>> kTabooWords = {
  // Objets du quotidien & Technologie
  'TÉLÉPHONE': ['APPELER', 'PORTABLE', 'MOBILE', 'ÉCRAN', 'ALLÔ'],
  'LUNETTES': ['YEUX', 'VOIR', 'VUE', 'SOLEIL', 'NEZ'],
  'LIT': ['DORMIR', 'CHAMBRE', 'MATELAS', 'DRAP', 'NUIT'],
  'MIROIR': ['REFLET', 'GLACE', 'REGARDER', 'IMAGE', 'SALLE DE BAIN'],

  // Nourriture
  'PIZZA': ['ITALIE', 'PÂTE', 'RONDE', 'FROMAGE', 'LIVRAISON'],
  'CAFÉ': ['NOIR', 'MATIN', 'TASSE', 'BOIRE', 'RÉVEIL'],
  'CHOCOLAT': ['CACAO', 'NOIR', 'LAIT', 'SUCRE', 'PÂQUES'],
  'EAU': ['BOIRE', 'LIQUIDE', 'SOIF', 'BOUTEILLE', 'TRANSPARENT'],
  'PAIN': ['BOULANGERIE', 'BAGUETTE', 'SANDWICH', 'FARINE', 'CROÛTE'],

  // Lieux
  'AVION': ['VOLER', 'CIEL', 'AÉROPORT', 'VACANCES', 'AILE'],
  'ASCENSEUR': ['ESCALIER', 'MONTER', 'DESCENDRE', 'ÉTAGE', 'BOUTON'],
  'PARIS': ['FRANCE', 'CAPITALE', 'TOUR EIFFEL', 'VILLE', 'AMOUR'],
  'PLAGE': ['SABLE', 'MER', 'VACANCES', 'SOLEIL', 'SERVIETTE'],

  // Santé
  'DENTISTE': ['DENT', 'BOUCHE', 'MAL', 'FRAISE', 'SOURIRE'],
  'SANG': ['ROUGE', 'VEINE', 'CŒUR', 'BLESSURE', 'VAMPIRE'],
  'MAIN': ['DOIGT', 'BRAS', 'TENIR', 'TOUCHER', 'GAUCHE'],
  'MÉDECIN': ['DOCTEUR', 'MALADE', 'SANTÉ', 'HÔPITAL', 'ORDONNANCE'],

  // Concepts, Émotions & Société
  'ARGENT': ['PAYER', 'ACHETER', 'EURO', 'BANQUE', 'PIÈCE'],
  'MARIAGE': ['HOMME', 'FEMME', 'ROBE', 'BAGUE', 'OUI'],
  'AMOUR': ['AIME', 'CŒUR', 'COUPLE', 'SENTIMENT', 'PASSION'],
  'RETARD': ['HEURE', 'TEMPS', 'MONTRE', 'ATTENDRE', 'VITE'],
  'MENSONGE': ['VÉRITÉ', 'FAUX', 'CROIRE', 'PINOCCHIO', 'NEZ'],
  'TRAVAIL': ['ARGENT', 'BUREAU', 'MÉTIER', 'CHEF', 'SALAIRE'],

  // Animaux
  'CHIEN': ['ANIMAL', 'CHAT', 'ABOYER', 'OS', 'LAISSE'],
  'SOLEIL': ['ASTRE', 'LUNE', 'CIEL', 'JAUNE', 'CHAUD'],
  'VACHE': ['LAIT', 'FERME', 'ANIMAL', 'PRÉ', 'TAUREAU'],
  'MOUSTIQUE': ['PIQUER', 'INSECTE', 'SANG', 'GRATTER', 'ÉTÉ'],

  // Loisirs
  'FOOTBALL': ['BALLON', 'BUT', 'SPORT', 'JOUEUR', 'TERRAIN'],
  'MUSIQUE': ['CHANTER', 'DANSER', 'ÉCOUTER', 'RADIO', 'SON'],
  'CINÉMA': ['FILM', 'ACTEUR', 'ÉCRAN', 'SALLE', 'POPCORN'],
  'INTERNET': ['WIFI', 'RÉSEAU', 'ORDINATEUR', 'SITE', 'WEB'],
};

//Liste de thèmes + mots à faire deviner associer
const Map<String, List<String>> hotColdWords = {
  //animaux
  'Animaux': [
    'ÉLÉPHANT',
    'PINGOUIN',
    'GIRAFE',
    'DAUPHIN',
    'AIGLE',
    'LAMA',
    'REQUIN',
    'PANDA',
  ],

  //nourriture
  'Nourriture': [
    'SUSHI',
    'RACLETTE',
    'BURGER',
    'AVOCAT',
    'CHOCOLAT',
    'CROISSANT',
    'PIZZA',
    'SPAGHETTI',
  ],

  //sports
  'Sports': [
    'ESCALADE',
    'BOXE',
    'SURF',
    'RUGBY',
    'PÉTANQUE',
    'YOGA',
    'TENNIS',
    'NATATION',
  ],

  //vêtements
  'Vêtements': [
    'PYJAMA',
    'BASKETS',
    'JEAN',
    'CASQUETTE',
    'ROBE',
    'MAILLOT',
    'ÉCHARPE',
    'CHEMISE',
  ],

  //voyages
  'Voyages': [
    'TOKYO',
    'DÉSERT',
    'NEW YORK',
    'JUNGLE',
    'VOLCAN',
    'PYRAMIDES',
    'PÔLE NORD',
    'VENISE',
  ],

  //cinéma
  'Cinéma': [
    'BATMAN',
    'HARRY POTTER',
    'ZOMBIE',
    'TITANIC',
    'STAR WARS',
    'JAMES BOND',
    'DISNEY',
    'PIRATE',
  ],
  'Musique': [
    // Instruments et genres
    'BATTERIE', 'MICRO', 'OPÉRA', 'GUITARE',
    'DJ', 'SAXOPHONE', 'RAP', 'PIANO',
  ],

  // Maison
  'Maison': [
    'FRIGO',
    'CANAPÉ',
    'DOUCHE',
    'TÉLÉVISION',
    'OREILLER',
    'MIROIR',
    'FOUR',
    'POUBELLE',
  ],

  //Objets
  'Objets': [
    'SMARTPHONE',
    'CLÉS',
    'LUNETTES',
    'VALISE',
    'PARAPLUIE',
    'MONTRE',
    'BRIQUET',
    'CAMÉRA',
  ],

  // Métiers
  'Métiers': [
    'ASTRONAUTE',
    'POMPIER',
    'ESPION',
    'ENSEIGNANT JAVA',
    'PRÉSIDENT',
    'CHEF CUISTO',
    'DENTISTE',
    'JUGE',
    'INFLUENCEUR',
  ],
};
