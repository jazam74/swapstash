import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ItemImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final Map<String, String?> _urlCache = {};

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  String _cacheKey({
    required String collectionId,
    required int itemNumber,
  }) {
    return '$collectionId/$itemNumber';
  }

  void _validateArguments({
    required String collectionId,
    required int itemNumber,
  }) {
    if (collectionId.trim().isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    if (itemNumber <= 0) {
      throw ArgumentError(
        'Številka predmeta mora biti večja od 0.',
      );
    }
  }

  Reference itemImageReference({
    required String collectionId,
    required int itemNumber,
  }) {
    _validateArguments(
      collectionId: collectionId,
      itemNumber: itemNumber,
    );

    return _storage.ref().child(
      'users/$_userId/'
      'collections/$collectionId/'
      'items/$itemNumber.jpg',
    );
  }

  Future<String?> getItemImageUrl({
    required String collectionId,
    required int itemNumber,
  }) async {
    final cacheKey = _cacheKey(
      collectionId: collectionId,
      itemNumber: itemNumber,
    );

    if (_urlCache.containsKey(cacheKey)) {
      return _urlCache[cacheKey];
    }

    try {
      final url = await itemImageReference(
        collectionId: collectionId,
        itemNumber: itemNumber,
      ).getDownloadURL();

      _urlCache[cacheKey] = url;

      return url;
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        _urlCache[cacheKey] = null;
        return null;
      }

      rethrow;
    }
  }

  Future<String?> pickAndUploadItemImage({
    required String collectionId,
    required int itemNumber,
  }) async {
    _validateArguments(
      collectionId: collectionId,
      itemNumber: itemNumber,
    );

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    // Uporabnik je zaprl galerijo brez izbire slike.
    if (pickedImage == null) {
      return null;
    }

    final imageBytes = await pickedImage.readAsBytes();

    if (imageBytes.isEmpty) {
      throw Exception('Izbrana slika je prazna.');
    }

    final reference = itemImageReference(
      collectionId: collectionId,
      itemNumber: itemNumber,
    );

    final metadata = SettableMetadata(
      contentType: pickedImage.mimeType ?? 'image/jpeg',
      customMetadata: {
        'collectionId': collectionId,
        'itemNumber': itemNumber.toString(),
        'uploadedBy': _userId,
      },
    );

    final uploadTask = await reference.putData(
      imageBytes,
      metadata,
    );

    final downloadUrl =
        await uploadTask.ref.getDownloadURL();

    final cacheKey = _cacheKey(
      collectionId: collectionId,
      itemNumber: itemNumber,
    );

    _urlCache[cacheKey] = downloadUrl;

    return downloadUrl;
  }

  Future<void> deleteItemImage({
    required String collectionId,
    required int itemNumber,
  }) async {
    try {
      await itemImageReference(
        collectionId: collectionId,
        itemNumber: itemNumber,
      ).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    } finally {
      clearCache(
        collectionId: collectionId,
        itemNumber: itemNumber,
      );
    }
  }

  void clearCache({
    required String collectionId,
    required int itemNumber,
  }) {
    _urlCache.remove(
      _cacheKey(
        collectionId: collectionId,
        itemNumber: itemNumber,
      ),
    );
  }
}