import 'dart:convert';
import 'package:crypto/crypto.dart';

class Hasher {

  // just a bunch of hash alrgos, only sha256 is used 
  
  static String md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String sha512Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }
}
