import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<List<String>> getGroqRecommendations(String userInput) async {
  final apiKey = dotenv.env['GROQ_API_KEY'];
  final endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  final prompt = '''
    Kullanıcı şunu arıyor: "$userInput".
    En fazla 22 film öner. Sadece film isimlerini virgülle ayırarak yaz.
    Örnek: Inception, The Dark Knight, Interstellar
  ''';
  /*
  final prompt = '''
    Kullanıcı şunu arıyor: "$userInput".
    Bu aradığı kriterlere göre hangi filmi arıyor olabilir. Aradığı film olabilecek filmlerin isimlerini virgülle ayırarak yaz.
    Örnek: Inception, The Dark Knight, Interstellar
  ''';
  */

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
    
    return movieList.take(22).toList();
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