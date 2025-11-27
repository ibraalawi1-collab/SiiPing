import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  /// Generate a simple AES key from user ID
  /// NOTE: In production, use proper key exchange (Diffie-Hellman, Signal Protocol, etc.)
  encrypt.Key _generateKeyFromUserId(String userId) {
    // Hash the user ID to create a 32-byte key
    final bytes = utf8.encode(userId);
    final hash = sha256.convert(bytes);
    return encrypt.Key.fromBase64(base64.encode(hash.bytes));
  }

  /// Encrypt a message
  String encryptMessage(String plaintext, String receiverId) {
    try {
      final key = _generateKeyFromUserId(receiverId);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      final encrypted = encrypter.encrypt(plaintext, iv: iv);
      
      // Return encrypted text + IV (needed for decryption)
      return '${encrypted.base64}:${iv.base64}';
    } catch (e) {
      print('Encryption error: $e');
      return plaintext; // Fallback to plaintext on error
    }
  }

  /// Decrypt a message
  String decryptMessage(String ciphertext, String senderId) {
    try {
      final parts = ciphertext.split(':');
      if (parts.length != 2) return ciphertext;

      final key = _generateKeyFromUserId(senderId);
      final encrypted = encrypt.Encrypted.fromBase64(parts[0]);
      final iv = encrypt.IV.fromBase64(parts[1]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Decryption error: $e');
      return ciphertext; // Fallback to showing ciphertext on error
    }
  }
}
