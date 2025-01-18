import 'package:cloud_firestore/cloud_firestore.dart';

class Api {
  String collection;
  String? doc;

  final _firestore = FirebaseFirestore.instance;

  Api({required this.collection, this.doc});

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
      {String? sortBy}) {
    if (sortBy != null) {
      return _firestore.collection(collection).orderBy(sortBy).snapshots();
    } else {
      return _firestore.collection(collection).snapshots();
    }
  }
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection() {
    return _firestore
        .collection(collection)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getLimitedCollection(int limit) {
    return _firestore
        .collection(collection)
        .limit(limit)
        .get();
  }


  Future<QuerySnapshot<Map<String, dynamic>>> searchDocument(
      String field, Object value) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .limit(1)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument() {
    return _firestore.collection(collection).doc(doc).get();
  }

  Future<DocumentReference?> addDocument(Map<String, dynamic> data) {
    return _firestore.collection(collection).add(data);
  }

  Future<String> addDocumentWithId(Map<String, dynamic> data) async {
    final docRef = _firestore.collection(collection).doc();
    data['id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  Future<void> updateDocument(Map<String, dynamic> data) async {
    return _firestore.collection(collection).doc(doc).update(data);
  }

  Future<void> setDocument(Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(doc).set(data);
  }

  Future<void> deleteDocument() {
    return _firestore.collection(collection).doc(doc).delete();
  }
}