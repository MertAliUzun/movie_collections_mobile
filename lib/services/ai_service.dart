import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<String>> getGeminiRecommendations(String userInput, String promptType) async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  final endpoint = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent';

  if (apiKey == null) {
    throw Exception('GEMINI_API_KEY bulunamadı.');
  }

  var prompt = '''
    Kullanıcı şunu arıyor: "$userInput".
    En fazla 10 film öner. Sadece film isimlerini virgülle ayırarak yaz.
    Örnek: Inception, Interstellar
  ''';

  if (promptType == 'find') {
    prompt = '''
      Kullanıcı şunu arıyor: "$userInput".
      Bu aradığı konu ve kriterlere göre arıyor olabileceği filmlerin adlarını virgülle ayırarak yaz.
      Örnek: Inception, Interstellar
    ''';
  }

  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );
    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;

      final movieList = content
          .split(',')
          .map((movie) => movie.trim())
          .where((movie) => movie.isNotEmpty)
          .toList();

      return movieList.take(10).toList();
    } else {
      print('Gemini API hatası: ${response.statusCode}, ${response.body}');
      throw Exception('Gemini isteği başarısız: ${response.statusCode}');
    }
  } catch (e) {
    print('Gemini isteği sırasında hata oluştu: $e');
    throw Exception('Gemini isteği sırasında hata oluştu: $e');
  }
}

Future<List<String>> getGroqRecommendations(String userInput, String promptType) async {
  final apiKey = dotenv.env['GROQ_API_KEY'];
  final endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  var prompt = '''
    Kullanıcı şunu arıyor: "$userInput".
    En fazla 9 film öner. Sadece film isimlerini virgülle ayırarak yaz.
    Örnek: Inception, Interstellar
  ''';
  if(promptType == 'find') {
    prompt = '''
    Kullanıcı şunu arıyor: "$userInput".
    Bu aradığı konu ve kriterlere göre arıyor olabileceği filmlerin adlarını virgülle ayırarak yaz.
    Örnek: Inception, Interstellar
  ''';
  }
  

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'llama3-70b-8192',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 1000,
    }),
  );

  print(jsonDecode(response.body));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;
    
    // Virgülle ayrılmış filmleri listeye dönüştür ve boşlukları temizle
    final movieList = content
        .split(',')
        .map((movie) => movie.trim())
        .where((movie) => movie.isNotEmpty)
        .toList();
    
    return movieList.take(9).toList();
  } else {
    throw Exception('Groq isteği başarısız: ${response.statusCode}');
  }
}

Future<List<String>> getDeepSeekRecommendations(String userInput) async {
  final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
  final endpoint = 'https://api.deepseek.com/v1/chat/completions'; // DeepSeek endpoint'i

  final prompt = '''
    Kullanıcı şunu arıyor: "$userInput".
    En fazla 20 film öner. Sadece film isimlerini virgülle ayırarak yaz.
    Örnek: Inception, The Dark Knight, Interstellar
  ''';

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'deepseek-chat', // DeepSeek model adı (dokümantasyondan kontrol edin)
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 1000,
    }),
  );
  print(jsonDecode(response.body));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
    final movieList = data['choices'][0]['message']['content'].split(', ');
    return movieList.take(20).toList();
  } else {
    throw Exception('DeepSeek isteği başarısız: ${response.statusCode}');
  }
}

Future<List<String>> getOpenAIRecommendations(String userInput) async {
  final openaiApiKey = dotenv.env['OPENAI_API_KEY'];
  final endpoint = 'https://api.openai.com/v1/chat/completions';

  // OpenAI'ye özel prompt
  final prompt = '''
    Kullanıcı şu filmleri arıyor: "$userInput".
    En fazla 50 film öner. Sadece film isimlerini virgülle ayırarak yaz.
    Örnek: Inception, The Dark Knight, Interstellar
  ''';

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openaiApiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 1000,
    }),
  );
  print(jsonDecode(response.body));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final movieList = data['choices'][0]['message']['content'].split(', ');
    return movieList.take(50).toList(); // Max 50 film
  } else {
    throw Exception('AI isteği başarısız: ${response.statusCode}');
  }
}