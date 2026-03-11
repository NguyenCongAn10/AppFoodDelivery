import 'dart:convert';
import 'dart:io';

void main() async {
  var url = Uri.parse('http://localhost:3000/api/foods');
  var request = await HttpClient().getUrl(url);
  var response = await request.close();
  var resBody = await response.transform(utf8.decoder).join();
  List<dynamic> list = jsonDecode(resBody);
  
  for (var item in list) {
    var rawItem = item as Map<String, dynamic>;
    var restName = rawItem['restaurants']?['restaurant_name'];
    print("Food: ${rawItem['name']} -> Rest: $restName");
  }
}
