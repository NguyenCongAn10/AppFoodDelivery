import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<User?> createUser(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email,
          password: password);
      User? user = userCredential.user;
      if(user != null){
        await _firebaseFirestore.collection("user").doc(user.uid).set({
          "uid" : user.uid,
          "email"  : email,
          "name" : name,
          "creatAt": FieldValue.serverTimestamp(),

        });
      }
    } catch(e) {
      throw Exception('Error creating user: $e');

    }
  }

  Future<String> getCategories( )async{
    try{
      QuerySnapshot querySnapshot = await _firebaseFirestore.collection("categories").get();
          return querySnapshot.docs.map((doc)=>{
            "id": doc.id,
            ...doc.data() as Map<String,dynamic>,
          }).toString();
    }catch(e){
      throw Exception('Error fetching categories: $e');
    }
  }

}