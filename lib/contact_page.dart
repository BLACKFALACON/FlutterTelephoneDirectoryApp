import 'package:flutter/material.dart';
import 'package:oner/add_contact_page.dart';
import 'package:oner/database/db_helper.dart';
import 'package:oner/model/contact.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts;
  DbHelper _dbHelper;  

  @override
  void initState() {
    contacts = Contact.contacts;
    _dbHelper= DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text("Kişiler"),),

       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddContactPage(contact: Contact(),)));
        },
        child: Icon(Icons.add),
       ),

       body:FutureBuilder(
       future: _dbHelper.getContacts(),
       builder:( BuildContext context,AsyncSnapshot<List<Contact>> snapshot)
       {
       if(!snapshot.hasData) return Padding(
         padding: const EdgeInsets.all(100),
         child: Center(child: CircularProgressIndicator()),
       );
       if(snapshot.data.isEmpty) return Padding(
         padding: const EdgeInsets.all(100),
         child: Center(child: Text("Kayıt bulunamadı")),
       );    
          return ListView.builder(
           itemCount: snapshot.data.length,
           itemBuilder: (BuildContext context, int index)
           {
            Contact contact = snapshot.data[index];

            return GestureDetector(
               onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddContactPage(contact: contact,)));
                  },
              child: Dismissible(
                direction: DismissDirection.endToStart,
                key: UniqueKey(),
                background: Container(color: Colors.red,child: Icon(Icons.restore_from_trash,color: Colors.white,size: 50,),),
                onDismissed: (direction) async { 
                _dbHelper.removeContact(contact.id);
                setState((){});   

               Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("${contact.name} kişisi silindi"),
                    action: SnackBarAction(
                      label: "Geri al",
                      onPressed: () async{
                        await _dbHelper.insertContact(contact);
                        setState(() {});
                      },
                    ),
                ));
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage( contact.avatar == null ? "assets/img/person.jpg" : contact.avatar,),
                  child: Text(
                    contact.name[0].toUpperCase(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.phoneNumber),
              ),  
          ),
            );
         });
      },),
    );
  }
} 