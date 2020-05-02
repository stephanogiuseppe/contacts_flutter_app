import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";
final String registerColumn = "registerColumn";
final String cardColumn = "cardColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db == null) {
       print("EXEC");
      _db = await initDb();
    }
    return _db;
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, newerVersion) async {
      await db.execute("CREATE TABLE $contactTable("
          "$idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
          "$phoneColumn TEXT, $imgColumn TEXT, $registerColumn TEXT, $cardColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    if (contact.id == null) {
      contact.id = await dbContact.insert(contactTable, contact.toMap());
      return contact;
    }

    await _updateContact(contact);
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn, registerColumn, cardColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    );

    if (maps.length > 0) {
       return Contact.fromMap(maps.first);
    }

    return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> _updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
        contactTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]
    );
  }

  Future<List<Contact>> getContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");

    List<Contact> contacts = List();

    for (Map m in listMap) {
      contacts.add(Contact.fromMap(m));
    }

    return contacts;
  }

  Future<int> getCount() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;
  String register;
  String card;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
    register = map[registerColumn];
    card = map[cardColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
      registerColumn: register,
      cardColumn: card
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contact("
      "id: $id,"
      "name: $name,"
      "email: $email,"
      "phone: $phone,"
      "register: $register,"
      "card: $card"
    ")";
  }
}
