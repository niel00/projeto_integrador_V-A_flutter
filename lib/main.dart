import 'package:flutter/material.dart';
import 'database.dart';

void main() {
  runApp(const ContactApp());
}

class ContactApp extends StatelessWidget {
  const ContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactList(),
    );
  }
}

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  ContactListState createState() => ContactListState();
}

class ContactListState extends State<ContactList> {
  final List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await ContactDatabase.instance.readAllContacts();
    setState(() {
      _contacts.addAll(
        contacts.map((contact) {
          return {
            'id': contact['id'].toString(),
            'name': contact['name'] as String,
            'email': contact['email'] as String,
            'phone': contact['phone'] as String,
          };
        }).toList(),
      );
    });
  }

  void _addContact(String name, String email, String phone) async {
    if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
      final newContact = {'name': name, 'email': email, 'phone': phone};
      await ContactDatabase.instance.createContact(newContact);
      setState(() => _contacts.add(newContact));
    }
  }

  void _editContact(int index, String name, String email, String phone) async {
    final updatedContact = {'name': name, 'email': email, 'phone': phone};
    await ContactDatabase.instance.updateContact(int.parse(_contacts[index]['id']!), updatedContact);
    setState(() {
      _contacts[index] = updatedContact;
    });
  }

  void _deleteContact(int index) async {
    await ContactDatabase.instance.deleteContact(int.parse(_contacts[index]['id']!));
    setState(() {
      _contacts.removeAt(index);
    });
  }

  void _promptAddContact() {
    String name = '';
    String email = '';
    String phone = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Novo Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (value) {
                  phone = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('ADICIONAR'),
              onPressed: () {
                _addContact(name, email, phone);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _promptEditContact(int index) {
    String name = _contacts[index]['name']!;
    String email = _contacts[index]['email']!;
    String phone = _contacts[index]['phone']!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                controller: TextEditingController(text: name),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: TextEditingController(text: email),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Telefone'),
                controller: TextEditingController(text: phone),
                onChanged: (value) {
                  phone = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('SALVAR'),
              onPressed: () {
                _editContact(index, name, email, phone);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteContact(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Contato'),
          content: const Text('Tem certeza de que deseja excluir este contato?'),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('EXCLUIR'),
              onPressed: () {
                _deleteContact(index);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Lista de Contatos',
    style: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 24,
    ),
  ),
  centerTitle: true,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Color.fromARGB(255, 154, 157, 161)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
   ),
  elevation: 10.0,
),

      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(_contacts[index]['name']!),
              subtitle: Text(
                'Email: ${_contacts[index]['email']!}\nTelefone: ${_contacts[index]['phone']!}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _promptEditContact(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDeleteContact(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddContact,
        tooltip: 'Adicionar Contato',
        child: const Icon(Icons.add),
      ),
    );
  }
}
