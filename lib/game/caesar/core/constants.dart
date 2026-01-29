

const int kMaxRounds = 2;
const int kCaesarWaitMillisecondAfterResponse = 1500;
const int kCaesarPointPerGoodAnswer = 10;

// Contient les questions pour le jeu de césar, 
// Chaque question contient "question", "questionWord", "answerWord"
// aussi, les questions doivent pouvoir être répondu en un seul mot (s'inspirer de ce qui existe déjà).
const List<Map<String, String>> kCaesarQuestions = [
  // Pays (capitales)
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "france",
    "answerWord": "paris"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "usa",
    "answerWord": "washington"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "italie",
    "answerWord": "rome"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "allemagne",
    "answerWord": "berlin"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "espagne",
    "answerWord": "madrid"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "canada",
    "answerWord": "ottawa"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "japon",
    "answerWord": "tokyo"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "chine",
    "answerWord": "pekin"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "angleterre",
    "answerWord": "londres"
  },
  {
    "question": "Donne la capitale du pays suivant :",
    "questionWord": "bresil",
    "answerWord": "brasilia"
  },

  // Prénoms d'acteur(rices)
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "hanks",
    "answerWord": "tom"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "watson",
    "answerWord": "emma"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "dicaprio",
    "answerWord": "leonardo"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "johansson",
    "answerWord": "scarlett"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "freeman",
    "answerWord": "morgan"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "sy",
    "answerWord": "omar"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "cotillard",
    "answerWord": "marion"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "dujardin",
    "answerWord": "jean"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "marceau",
    "answerWord": "sophie"
  },
  {
    "question": "Donne le prénom de cet(te) acteur(ice) connu.",
    "questionWord": "elmaleh",
    "answerWord": "gad"
  },

  // Bruits d'animaux
  {
    "question": "Quel animal fait ce bruit ?",
    "questionWord": "miauler",
    "answerWord": "chat"
  },
  {
    "question": "Quel animal fait ce bruit ?",
    "questionWord": "aboyer",
    "answerWord": "chien"
  },
  {
    "question": "Quel animal fait ce bruit ?",
    "questionWord": "meugler",
    "answerWord": "vache"
  },
  {
    "question": "Quel animal fait ce bruit ?",
    "questionWord": "braire",
    "answerWord": "âne"
  },
  {
    "question": "Quel animal fait ce bruit ?",
    "questionWord": "cocotte",
    "answerWord": "poule"
  },
  {
    "question": "Quel animal fait ce bruit ?",
    "questionWord": "croasser",
    "answerWord": "grenouille"
  },

  // contraires
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "nord",
    "answerWord": "sud"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "ouest",
    "answerWord": "est"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "court",
    "answerWord": "long"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "grand",
    "answerWord": "petit"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "blanc",
    "answerWord": "noir"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "jour",
    "answerWord": "nuit"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "haut",
    "answerWord": "bas"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "chaud",
    "answerWord": "froid"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "ouvrir",
    "answerWord": "fermer"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "jeune",
    "answerWord": "vieux"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "facile",
    "answerWord": "difficile"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "rapide",
    "answerWord": "lent"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "avant",
    "answerWord": "après"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "fort",
    "answerWord": "faible"
  },
  {
    "question": "Quelle est le contraire de ce mot ?",
    "questionWord": "riche",
    "answerWord": "pauvre"
  },
];
