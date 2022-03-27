
import 'package:flutter/material.dart';
import 'package:oner/database/db_helper.dart';
import 'package:oner/model/contact.dart';
import 'package:image_picker/image_picker.dart';

class AddContactPage extends StatelessWidget {
  final Contact contact;

  const AddContactPage({Key key, this.contact}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var addContactForm = AddContactForm();
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.id == null ? "Yeni Kişi Ekle" : contact.name),
      ),
      body: SingleChildScrollView( child:ContactForm(contact: contact,  child: addContactForm)),
    );
  }
}

class ContactForm extends InheritedWidget //Yapılan değişiklikleri kaydeder .Id değişimine göre kayıt yapılır ,bir dinleyivi methoddur
{
  final Contact contact;

  ContactForm({Key key, @required Widget child, @required this.contact}) : super(key: key, child: child);

  static ContactForm of(BuildContext context) 
  {
    return context.inheritFromWidgetOfExactType(ContactForm);
  }

  @override
  bool updateShouldNotify(ContactForm oldWidget) {
    return contact.id != oldWidget.contact.id;
  }
}
  
  class AddContactForm extends StatefulWidget {
    @override
    _AddContactFormState createState() => _AddContactFormState();
  }
  
  class _AddContactFormState extends State<AddContactForm> {
    final _formKey = GlobalKey<FormState>();
    DbHelper _dbHelper;
  
   @override
      void initState()
      {
        _dbHelper=DbHelper();
        super.initState();
      }
  
    @override
    Widget build(BuildContext context) {
      Contact contact = ContactForm.of(context).contact;
    return Column(
      children: <Widget>[
        Stack(children: [
          Image.asset(contact.avatar == null ? "assets/img/person.jpg" : contact.avatar,fit: BoxFit.cover,width: double.infinity,height: 250,),
          Positioned(bottom: 8,right: 8,
          child: IconButton(
            onPressed: () {
                  getFile();
                },
            icon: Icon(Icons.camera_alt,size: 120,),
            color: Colors.white,
            
          ))
        ]),
        Padding(
          padding: EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    initialValue: contact.name,
                     decoration: InputDecoration(
                      hintText: "Ad",
                      icon: Icon(Icons.person),
                    ), 
                    validator:(value) {
                      if (value.isEmpty) {
                        return "Bu alan boş geçilemez";
                      }
                    },
                    onSaved: (value) {
                      contact.name = value;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                     keyboardType: TextInputType.phone,
                     initialValue: contact.phoneNumber,
                     decoration: InputDecoration(
                       hintText:"Telefon",
                       icon: Icon(Icons.phone),
                     ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Bu alan boş geçilemez";
                      }
                    },
                    onSaved: (value) {
                      contact.phoneNumber = value;
                    },
                  ),
                ),
                 Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50,vertical:50),
                child: RaisedButton(
                  

                onPressed: () async{
                 if (_formKey.currentState.validate()) 
                 {
                   _formKey.currentState.save();
                    var snackBar;
                   if (contact.id==null) 
                   {
                    await  _dbHelper.insertContact(contact);  
                    snackBar= Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds:500),content: Text("${contact.name} kişisi eklenmiştir"),));
                   } 
                   else
                    {
                     await  _dbHelper.updateContact(contact);
                     snackBar= Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds:500),content: Text("Bilgiler güncellendi"),));
                   }
                    snackBar.closed.then((onValue)//Uyarı göründükten sonra işlem yapılır
                    {
                      Navigator.pop(context);//Geldiğimiz sayfaya geri gider
                    });
                 } 
                },
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: <Color>[
                  Color(0xFF0D47A1),Color(0xFF1976D2),Color(0xFF42A5F5), 
                  ],
                  ),
                ),
                padding: const EdgeInsets.all(10.0),child: const Text('Kaydet',style: TextStyle(fontSize: 20)
                ),
                ),
                ),
              ),
              ),
              ],
            ),
          ),
        ),
      ],
    );


   

  }
 Future<void> getFile() async{
     return showDialog(

      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
     
        return Padding(
          padding: const EdgeInsets.fromLTRB(0,500, 0,0) ,   
          child: AlertDialog(
            // Başlık Kısmı
          shape: RoundedRectangleBorder(borderRadius:
              BorderRadius.circular(20.0)),
            title: Text(" Resim seçim",textAlign:TextAlign.center,),
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize:16,),
            backgroundColor: Colors.grey[200],
            contentPadding: EdgeInsets.all(5),
            content: new SingleChildScrollView(
              child: new ListBody(
               children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    
                    child: GestureDetector(

                      child: Icon(Icons.photo_camera,size: 45,),
                      onTap:(){imageSelection(1);} ,
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Icon(Icons.photo_size_select_actual,size: 45,),
                    onTap:(){imageSelection(0);} ,
                      ),
                  ),
                  ],
                ),
              ),
            actions: <Widget>[
              FlatButton(
                child: Text("Kapat",style: TextStyle(color: Colors.black,fontSize: 18),),
                // Tıklandığında AlertDialog kapanması için
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
      },
    );
 }

     

  void imageSelection(int imageSelection) async {  
    var image;
     
      Contact contact = ContactForm.of(context).contact;
     if (imageSelection==0) 
     {
       image = await ImagePicker.pickImage(source: ImageSource.gallery);
     } else 
     {
       image = await ImagePicker.pickImage(source: ImageSource.camera);
     }  
     
    setState(() {
      contact.avatar =image.path;
    });     
    Navigator.pop(context);
  }

}