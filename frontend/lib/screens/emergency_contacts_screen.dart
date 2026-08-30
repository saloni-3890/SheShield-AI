import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/emergency_contact_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final EmergencyContactService service =
      EmergencyContactService();

  List<dynamic> contacts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    setState(() {
      loading = true;
    });

    try {
      final data = await service.getContacts();

      if (!mounted) return;

      setState(() {
        contacts = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load contacts: $e"),
        ),
      );
    }
  }

  void showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Emergency Contact"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(
                    labelText: "Relation",
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final relation = relationController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Name and phone are required",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final success = await service.addContact(
                  name,
                  phone,
                  relation,
                );

                if (!mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Emergency contact added successfully",
                      ),
                    ),
                  );

                  loadContacts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Failed to add emergency contact",
                      ),
                    ),
                  );
                }
              },
              child: const Text("ADD"),
            ),
          ],
        );
      },
    );
  }
void showEditContactDialog(dynamic contact) {
  final nameController =
      TextEditingController(text: contact["name"] ?? "");

  final phoneController =
      TextEditingController(text: contact["phone"] ?? "");

  final relationController =
      TextEditingController(text: contact["relation"] ?? "");

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Edit Emergency Contact"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationController,
                decoration: const InputDecoration(
                  labelText: "Relation",
                  prefixIcon: Icon(Icons.people),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final relation = relationController.text.trim();

              if (name.isEmpty || phone.isEmpty) {
                return;
              }

              Navigator.pop(dialogContext);

              final success = await service.updateContact(
                contact["id"],
                name,
                phone,
                relation,
              );

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Contact updated successfully",
                    ),
                  ),
                );

                loadContacts();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Failed to update contact",
                    ),
                  ),
                );
              }
            },
            child: const Text("UPDATE"),
          ),
        ],
      );
    },
  );
}
Future<void> registerTestFcmToken(dynamic contact) async {
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      debugPrint("FCM token not available");
      return;
    }

    debugPrint("TEST FCM TOKEN: $fcmToken");

    final success = await service.saveContactFcmToken(
      contact["id"],
      fcmToken,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "FCM token saved for ${contact["name"]}"
              : "Failed to save FCM token",
        ),
      ),
    );

    if (success) {
      loadContacts();
    }
  } catch (e) {
    debugPrint("FCM token registration error: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("FCM error: $e"),
      ),
    );
  }
}
Future<void> linkContactUser(dynamic contact) async {
  final controller = TextEditingController();

  final userId = await showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Link SheShield User"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "User ID",
            hintText: "Example: 2",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(controller.text.trim());

              if (id != null) {
                Navigator.pop(dialogContext, id);
              }
            },
            child: const Text("LINK"),
          ),
        ],
      );
    },
  );

  controller.dispose();

  if (userId == null) return;

  final success = await service.linkContactUser(
    contact["id"],
    userId,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? "Contact linked successfully"
            : "Failed to link contact",
      ),
    ),
  );

  if (success) {
    loadContacts();
  }
}
  Future<void> deleteContact(int id) async {
    final success = await service.deleteContact(id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contact deleted"),
        ),
      );

      loadContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete contact"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddContactDialog,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : contacts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contact_phone,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No emergency contacts added",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap + to add a trusted contact",
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadContacts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            contact["name"] ?? "Unknown",
                          ),
                          subtitle: Text(
                            "${contact["phone"] ?? ""}\n"
                            "${contact["relation"] ?? ""}",
                          ),
                          isThreeLine: true,
                          trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        showEditContactDialog(contact);
      },
    ),
    IconButton(
  icon: const Icon(Icons.link),
  tooltip: "Link SheShield User",
  onPressed: () {
    linkContactUser(contact);
  },
),
    IconButton(
  icon: const Icon(Icons.notifications_active),
  tooltip: "Register FCM Token",
  onPressed: () {
    registerTestFcmToken(contact);
  },
),
  ],
),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}