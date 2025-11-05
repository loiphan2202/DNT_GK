// ========================
// API SERVICE
// ========================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class ApiService {
  // ⚠️ THAY ĐỔI IP NÀY THEO MÁY CỦA BẠN
  // Nếu chạy trên thiết bị thật: dùng IP máy tính (ví dụ: 192.168.1.100)
  // Nếu chạy trên Android Emulator: dùng 10.0.2.2
  // Nếu chạy trên iOS Simulator: dùng localhost
  static const String baseUrl = 'http://localhost:3000/api';

  // Helper method để xử lý file upload
  static Future<void> _addFileToRequest(
    http.MultipartRequest request,
    String fieldName,
    dynamic file,
  ) async {
    if (file == null) return;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final filename = file.name ?? 'image.jpg';

      // Xác định mime type dựa trên phần mở rộng
      String mimeType = 'image/jpeg';
      final ext = filename.toLowerCase();
      if (ext.endsWith('.png'))
        mimeType = 'image/png';
      else if (ext.endsWith('.gif')) mimeType = 'image/gif';

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          (file as File).path,
        ),
      );
    }
  }

  // Lưu token vào SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Xóa token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Get headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========================
  // 1. ĐĂNG KÝ
  // ========================
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    dynamic imageFile,
  }) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/register'));

      // Thêm các trường text
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;

      // Thêm ảnh nếu có
      if (imageFile != null) {
        await _addFileToRequest(request, 'image', imageFile);
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================
  // 2. ĐĂNG NHẬP
  // ========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Lưu token
        await saveToken(data['token']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================
  // 3. LẤY DANH SÁCH USER
  // ========================
  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/users').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
      });

      final response = await http.get(uri, headers: headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final users =
            (data['users'] as List).map((user) => User.fromJson(user)).toList();
        return {
          'success': true,
          'users': users,
          'totalPages': data['totalPages'],
          'currentPage': data['currentPage'],
          'totalUsers': data['totalUsers'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get users'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================
  // 4. LẤY CHI TIẾT USER
  // ========================
  static Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': User.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'User not found'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================
  // 5. CẬP NHẬT USER
  // ========================
  static Future<Map<String, dynamic>> updateUser({
    required String id,
    String? username,
    String? email,
    String? password,
    dynamic imageFile,
  }) async {
    try {
      final token = await getToken();
      var request =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/$id'));

      // Thêm token vào header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Thêm các trường cần update
      if (username != null) request.fields['username'] = username;
      if (email != null) request.fields['email'] = email;
      if (password != null) request.fields['password'] = password;

      // Thêm ảnh mới nếu có
      if (imageFile != null) {
        await _addFileToRequest(request, 'image', imageFile);
      }

      try {
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        print('Server response: $data'); // Thêm log để debug

        if (response.statusCode == 200) {
          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Update failed'
          };
        }
      } catch (e) {
        print('Error during request: $e'); // Thêm log để debug
        return {'success': false, 'message': 'Network error: ${e.toString()}'};
      }
    } catch (e) {
      print('Error in updateUser: $e'); // Thêm log để debug
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================
  // 6. XÓA USER
  // ========================
  static Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Delete failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================
  // 7. GET IMAGE URL
  // ========================
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    // Nếu imagePath đã là URL đầy đủ thì return luôn
    if (imagePath.startsWith('http')) return imagePath;
    // Nếu không thì ghép với baseUrl
    final urlBase = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    return urlBase + imagePath;
  }
}
