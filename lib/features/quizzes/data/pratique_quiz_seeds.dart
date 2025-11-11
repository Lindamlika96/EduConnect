final Map<int, List<Map<String, dynamic>>> pratiqueQuizSeeds = {
  1: [
    // 🧮 Algo
    {
      'text': 'Écris une fonction qui retourne le carré d’un nombre',
      'code_snippet': 'def carre(n):\n    return n * n\nprint(carre(4))',
      'expected_output': '16\n',
      'language_id': 71,
    },
    {
      'text': 'Affiche les nombres de 1 à 5',
      'code_snippet': 'for i in range(1, 6):\n    print(i)',
      'expected_output': '1\n2\n3\n4\n5\n',
      'language_id': 71,
    },
    {
      'text': 'Vérifie si un nombre est pair',
      'code_snippet': 'n = 6\nprint(n % 2 == 0)',
      'expected_output': 'True\n',
      'language_id': 71,
    },
  ],
  2: [
    // 🎯 Flutter (Dart)
    {
      'text': 'Affiche "Bienvenue sur Flutter"',
      'code_snippet': 'void main() {\n  print("Bienvenue sur Flutter");\n}',
      'expected_output': 'Bienvenue sur Flutter\n',
      'language_id': 63,
    },
    {
      'text': 'Additionne 3 + 4 en Dart',
      'code_snippet': 'void main() {\n  print(3 + 4);\n}',
      'expected_output': '7\n',
      'language_id': 63,
    },
    {
      'text': 'Crée une variable nom = "Wissal"',
      'code_snippet':
          'void main() {\n  String nom = "Wissal";\n  print(nom);\n}',
      'expected_output': 'Wissal\n',
      'language_id': 63,
    },
  ],
  3: [
    // 🗃️ SQL
    {
      'text': 'Sélectionne tous les utilisateurs',
      'code_snippet': 'SELECT * FROM users;',
      'expected_output': 'Résultat simulé\n',
      'language_id': 82,
    },
    {
      'text': 'Compte le nombre de lignes dans orders',
      'code_snippet': 'SELECT COUNT(*) FROM orders;',
      'expected_output': 'Résultat simulé\n',
      'language_id': 82,
    },
  ],
  4: [
    // 🌐 Réseaux
    {
      'text': 'Affiche l’adresse IP locale',
      'code_snippet':
          'import socket\nprint(socket.gethostbyname(socket.gethostname()))',
      'expected_output': '192.168.x.x\n',
      'language_id': 71,
    },
    {
      'text': 'Affiche "HTTP est un protocole"',
      'code_snippet': 'print("HTTP est un protocole")',
      'expected_output': 'HTTP est un protocole\n',
      'language_id': 71,
    },
  ],
  5: [
    // 🤖 IA
    {
      'text': 'Calcule la moyenne d’une liste',
      'code_snippet': 'notes = [12, 15, 18]\nprint(sum(notes)/len(notes))',
      'expected_output': '15.0\n',
      'language_id': 71,
    },
    {
      'text': 'Affiche "Machine Learning"',
      'code_snippet': 'print("Machine Learning")',
      'expected_output': 'Machine Learning\n',
      'language_id': 71,
    },
    {
      'text': 'Crée une liste de prédictions',
      'code_snippet': 'predictions = [0, 1, 1, 0]\nprint(predictions)',
      'expected_output': '[0, 1, 1, 0]\n',
      'language_id': 71,
    },
  ],
};
