import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;

  NoteDetailPage({required this.noteId});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController taskController = TextEditingController();
  bool isToDoList = false;
  List<String> todoItems = [];
  List<bool> todoStatus = [];
  late DocumentSnapshot noteSnapshot;

  // Fonction pour charger la note
  void loadNote() async {
    DocumentSnapshot noteDoc = await FirebaseFirestore.instance.collection('notes').doc(widget.noteId).get();
    setState(() {
      noteSnapshot = noteDoc;
      noteController.text = noteDoc['note'];
      if (noteDoc['todoItems'] != null) {
        isToDoList = true;
        todoItems = List<String>.from(noteDoc['todoItems']);
        todoStatus = List<bool>.from(noteDoc['todoStatus']);
      }
    });
  }

  // Fonction pour mettre à jour la note dans Firebase
  void updateNote() async {
    await FirebaseFirestore.instance.collection('notes').doc(widget.noteId).update({
      'note': noteController.text,
      'todoItems': todoItems,
      'todoStatus': todoStatus,
    });
    Navigator.pop(context); // Retour à la page précédente après mise à jour
  }

  // Fonction pour supprimer la note entière
  void deleteNote() async {
    // Supprime la note entière, y compris les tâches associées
    await FirebaseFirestore.instance.collection('notes').doc(widget.noteId).delete();
    Navigator.pop(context); // Retour à la page précédente après suppression
  }

  // Fonction pour supprimer une tâche spécifique
  void deleteTask(int index) {
    setState(() {
      todoItems.removeAt(index);
      todoStatus.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    loadNote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Note'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteNoteDialog(context), // Supprimer la note
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ de texte pour modifier la note avec un style
            TextFormField(
              controller: noteController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Modifier la note...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            SizedBox(height: 20),

            // Option pour convertir la note en To-do list avec un style amélioré
            SwitchListTile(
              title: Text('Transformer en To-Do List', style: TextStyle(fontSize: 16)),
              value: isToDoList,
              onChanged: (value) {
                setState(() {
                  isToDoList = value;
                  if (!isToDoList) {
                    todoItems.clear();
                    todoStatus.clear();
                  }
                });
              },
              activeColor: Colors.blueAccent,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
            if (isToDoList) ...[
              // Nouveau champ de texte pour entrer un titre de tâche
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  hintText: 'Entrez le titre de la tâche',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              // Affichage des tâches à faire (checkboxes) avec un meilleur style
              Expanded(
                child: ListView.builder(
                  itemCount: todoItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(todoItems[index], style: TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTask(index), // Supprimer la tâche spécifique
                        ),
                        leading: Checkbox(
                          value: todoStatus[index],
                          onChanged: (bool? value) {
                            setState(() {
                              todoStatus[index] = value ?? false;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    setState(() {
                      todoItems.add(taskController.text);  // Ajouter la tâche avec le titre entré
                      todoStatus.add(false);
                    });
                    taskController.clear();  // Effacer le champ après ajout
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,  // Correct parameter for background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text('Ajouter une tâche', style: TextStyle(fontSize: 16)),
              ),
            ],
            SizedBox(height: 20),

            // Bouton pour enregistrer les modifications
            ElevatedButton(
              onPressed: updateNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,  // Correct parameter for background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text('Sauvegarder les modifications', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher une boîte de dialogue de confirmation avant la suppression de la note
  Future<void> _showDeleteNoteDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer la Note'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                deleteNote();
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
