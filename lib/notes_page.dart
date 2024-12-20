import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'notes_detail_page.dart'; // Assurez-vous d'importer la page NoteDetailPage

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController noteController = TextEditingController();
  final CollectionReference notesCollection =
  FirebaseFirestore.instance.collection('notes');

  // Fonction pour ajouter une note
  void addNote() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    if (noteController.text.isNotEmpty) {
      notesCollection.add({
        'userId': userId,
        'note': noteController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      noteController.clear();
    }
  }

  // Fonction pour déconnecter l'utilisateur
  void logout() async {
    await FirebaseAuth.instance.signOut(); // Déconnecte l'utilisateur
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()), // Redirige vers la page de login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vos Notes'),
        backgroundColor: Colors.teal, // La couleur d'AppBar est la même que dans la page de login
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout, // Appelle la fonction de déconnexion
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Un peu plus d'espace autour des éléments
        child: Column(
          children: [
            // Zone de saisie pour les notes
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Saisissez votre note...',
                hintStyle: TextStyle(color: Colors.grey), // Style pour le texte d'indication
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Coins arrondis pour correspondre au style
                ),
                prefixIcon: Icon(Icons.note_add), // Icone d'ajout de note
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: addNote, // Appel de la fonction d'ajout de note
                ),
              ),
              style: TextStyle(fontSize: 16), // Style du texte de la note
              maxLines: 3, // Limiter la hauteur du champ de texte
            ),
            SizedBox(height: 20), // Un peu d'espace entre le champ de saisie et la liste de notes

            // Affichage des notes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: notesCollection
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Chargement en cours
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Aucune note disponible.'));
                  }

                  final notes = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final noteText = note['note'] ?? 'Pas de contenu';
                      final timestamp = note['timestamp'] != null
                          ? (note['timestamp'] as Timestamp).toDate().toString()
                          : 'Sans date';

                      return Card(
                        elevation: 3, // Légère ombre pour une meilleure hiérarchie
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Coins arrondis
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8), // Espacement entre les éléments
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16), // Espacement interne du card
                          title: Text(
                            noteText,
                            style: TextStyle(fontSize: 16), // Taille de police uniforme
                          ),
                          subtitle: Text(
                            timestamp,
                            style: TextStyle(color: Colors.grey), // Style de texte gris pour la date
                          ),
                          onTap: () {
                            // Naviguer vers la page de détail de la note
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteDetailPage(noteId: note.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
