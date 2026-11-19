import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_config.dart';

class WeatherService {
  static const Map<String, List<String>> cityAliases = {
    // Uttar Pradesh
    'prayagraj': [
      'prayagraj', 'prayagrajj', 'praygraj', 'pryagraj',
      'allahabad', 'allhabad', 'allahbad',
    ],
    'lucknow': ['lucknow', 'lucknoww', 'luknow'],
    'kanpur': ['kanpur', 'kanpoor', 'kampur'],
    'varanasi': ['varanasi', 'varansi', 'banaras', 'benaras'],
    'agra': ['agra', 'aagra'],
    'mathura': ['mathura', 'mathura'],
    'vrindavan': ['vrindavan', 'brindavan'],
    'ayodhya': ['ayodhya', 'ayodhyaa'],
    'bareilly': ['bareilly', 'bareli'],
    'meerut': ['meerut', 'merut'],
    'ghaziabad': ['ghaziabad', 'gaziabad'],
    'noida': ['noida', 'noida city'],
    'gorakhpur': ['gorakhpur', 'gorakpur'],
    'jhansi': ['jhansi', 'jhaansi'],

    // Rajasthan
    'jaipur': ['jaipur', 'jaipurr', 'jaypur', 'jaipor'],
    'jodhpur': ['jodhpur', 'jodhpurr'],
    'udaipur': ['udaipur', 'oodaypur'],
    'jaisalmer': ['jaisalmer', 'jaisalmerr'],
    'ajmer': ['ajmer', 'ajmeer'],
    'pushkar': ['pushkar', 'pushker'],
    'bikaner': ['bikaner', 'bikanerr'],
    'mount abu': ['mount abu', 'mt abu'],

    // Delhi and North India
    'delhi': ['delhi', 'dilli', 'new delhi'],
    'chandigarh': ['chandigarh', 'chandigadh'],
    'amritsar': ['amritsar', 'amritsarh'],
    'ludhiana': ['ludhiana', 'ludhyana'],
    'shimla': ['shimla', 'simla'],
    'manali': ['manali', 'manalli'],
    'dharamshala': ['dharamshala', 'dharamsala'],
    'srinagar': ['srinagar', 'shrinagar'],
    'leh': ['leh'],
    'dehradun': ['dehradun', 'dehradoon'],
    'mussoorie': ['mussoorie', 'masoori'],
    'nainital': ['nainital', 'naini tal'],
    'rishikesh': ['rishikesh', 'hrishikesh'],
    'haridwar': ['haridwar', 'hardwar'],
    'jim corbett': ['jim corbett', 'corbett'],

    // Gujarat
    'ahmedabad': ['ahmedabad', 'amdavad', 'ahemdabad'],
    'surat': ['surat', 'surrat'],
    'vadodara': ['vadodara', 'baroda'],
    'rajkot': ['rajkot', 'rajkote'],
    'dwarka': ['dwarka', 'dwaraka'],
    'somnath': ['somnath', 'somanath'],
    'statue of unity': ['statue of unity', 'ekta nagar'],

    // Maharashtra
    'mumbai': ['mumbai', 'bombay', 'mumbay'],
    'pune': ['pune', 'poona'],
    'nashik': ['nashik', 'nasik'],
    'nagpur': ['nagpur', 'nagpurr'],
    'aurangabad': ['aurangabad', 'sambhajinagar'],
    'mahabaleshwar': ['mahabaleshwar', 'mahabaleshvar'],
    'shirdi': ['shirdi', 'shirdhi'],
    'lonavala': ['lonavala', 'lonawala'],

    // Madhya Pradesh
    'bhopal': ['bhopal', 'bhopaal'],
    'indore': ['indore', 'indor'],
    'gwalior': ['gwalior', 'gwaliar'],
    'ujjain': ['ujjain', 'ujjayini'],
    'khajuraho': ['khajuraho', 'khajuraho'],
    'orchha': ['orchha', 'orcha'],
    'jabalpur': ['jabalpur', 'jubbulpore'],

    // Bihar and Jharkhand
    'patna': ['patna', 'patana'],
    'gaya': ['gaya', 'gayaa'],
    'ranchi': ['ranchi', 'ranchhi'],
    'deoghar': ['deoghar', 'deoghur'],

    // West Bengal and Northeast
    'kolkata': ['kolkata', 'kolkatta', 'calcutta'],
    'darjeeling': ['darjeeling', 'darjiling'],
    'siliguri': ['siliguri', 'siligoree'],
    'gangtok': ['gangtok', 'gangtokk'],
    'guwahati': ['guwahati', 'gowahati'],
    'shillong': ['shillong', 'shilong'],
    'cherrapunji': ['cherrapunji', 'sohra'],
    'kaziranga': ['kaziranga', 'kaziranga national park'],

    // Odisha and Chhattisgarh
    'bhubaneswar': ['bhubaneswar', 'bhuvaneshwar'],
    'puri': ['puri', 'jagannath puri'],
    'konark': ['konark', 'konarka'],
    'raipur': ['raipur', 'raipoor'],
    'jagdalpur': ['jagdalpur', 'jagadalpur'],

    // Karnataka
    'bengaluru': ['bengaluru', 'bangalore', 'banglore'],
    'mysuru': ['mysuru', 'mysore'],
    'hampi': ['hampi', 'hampee'],
    'coorg': ['coorg', 'kodagu'],
    'madikeri': ['madikeri', 'madikeri'],
    'mangaluru': ['mangaluru', 'mangalore'],
    'hubballi': ['hubballi', 'hubli'],

    // Kerala
    'kochi': ['kochi', 'cochin'],
    'thiruvananthapuram': ['thiruvananthapuram', 'trivandrum'],
    'alappuzha': ['alappuzha', 'alleppey'],
    'munnar': ['munnar', 'munaar'],
    'wayanad': ['wayanad', 'waynad'],
    'kollam': ['kollam', 'quilon'],
    'thrissur': ['thrissur', 'trichur'],

    // Tamil Nadu
    'chennai': ['chennai', 'chenai', 'chenn ai', 'madras'],
    'coimbatore': ['coimbatore', 'coimbatur'],
    'madurai': ['madurai', 'madhurai'],
    'ooty': ['ooty', 'udhagamandalam'],
    'kodaikanal': ['kodaikanal', 'kodai kanal'],
    'rameswaram': ['rameswaram', 'rameshwaram'],
    'kanyakumari': ['kanyakumari', 'cape comorin'],
    'thanjavur': ['thanjavur', 'tanjore'],

    // Andhra Pradesh and Telangana
    'hyderabad': ['hyderabad', 'hydrabad', 'haidrabad', 'hyderbad'],
    'visakhapatnam': ['visakhapatnam', 'vizag'],
    'vijayawada': ['vijayawada', 'vijaywada'],
    'tirupati': ['tirupati', 'thirupathi'],
    'amaravati': ['amaravati', 'amaravathi'],
    'warangal': ['warangal', 'warangall'],

    // Punjab and Haryana
    'jalandhar': ['jalandhar', 'jullundur'],
    'patiala': ['patiala', 'patialaa'],
    'gurugram': ['gurugram', 'gurgaon'],
    'faridabad': ['faridabad', 'faridabadd'],
    'panipat': ['panipat', 'panipatt'],
    'kurukshetra': ['kurukshetra', 'kurukshetra'],

    // Himachal Pradesh
    'kullu': ['kullu', 'kooloo'],
    'dalhousie': ['dalhousie', 'dalhousi'],
    'spiti': ['spiti', 'spiti valley'],
    'kasol': ['kasol', 'kasoll'],

    // Assam and Arunachal Pradesh
    'tawang': ['tawang', 'tawwang'],
    'tezpur': ['tezpur', 'tezpore'],
    'dibrugarh': ['dibrugarh', 'dibru garh'],
    'ziro': ['ziro', 'zero'],

    // Goa
    'panaji': ['panaji', 'panjim'],
    'margao': ['margao', 'madgaon'],
    'vasco da gama': ['vasco da gama', 'vasco'],

    // Andaman and Nicobar Islands
    'port blair': ['port blair', 'sri vijaya puram'],
    'havelock island': ['havelock island', 'swaraj dweep'],

    // Jammu and Kashmir
    'gulmarg': ['gulmarg', 'gul marg'],
    'pahalgam': ['pahalgam', 'pahal gam'],
    'sonamarg': ['sonamarg', 'sona marg'],

    // Uttarakhand
    'auli': ['auli', 'auli hill station'],
    'chopta': ['chopta', 'chopta valley'],

    // Lakshadweep
    'kavaratti': ['kavaratti', 'kavaratti island'],
  };
  static String correctCityName(String city) {
    final input = city
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    for (final entry in cityAliases.entries) {
      if (entry.value.contains(input)) {
        return entry.key;
      }
    }

    return city.trim();
  }

  static List<String> getCitySuggestions(String input) {
    final query = input.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    final suggestions = <String>[];

    for (final entry in cityAliases.entries) {
      final matches = entry.value.any(
        (alias) => alias.contains(query) || query.contains(alias),
      );

      if (matches) {
        final displayName = switch (entry.key) {
          'prayagraj' => 'Prayagraj',
          'lucknow' => 'Lucknow',
          'kanpur' => 'Kanpur',
          'varanasi' => 'Varanasi',
          'delhi' => 'Delhi',
          'mumbai' => 'Mumbai',
          _ => entry.key,
        };

        suggestions.add(displayName);
      }
    }

    return suggestions.toSet().toList();
  }

  static Future<Map<String, dynamic>> getWeather(String city) async {
    final cleanedCity = city.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (cleanedCity.isEmpty) {
      throw Exception('Please enter a city name.');
    }

    final correctedCity = correctCityName(cleanedCity);

    // Keep the working lookup for Prayagraj.
    final searchCity = correctedCity == 'prayagraj'
        ? 'Allahabad,IN'
        : correctedCity;

    final url = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'q': searchCity,
        'appid': WeatherConfig.apiKey,
        'units': 'metric',
      },
    );

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        print('Requested city: $searchCity');
        print('Returned city: ${data['name']}');
        print('Country: ${data['sys']?['country']}');
        print('Coordinates: ${data['coord']}');

        return data;
      }

      if (response.statusCode == 404) {
        throw Exception(
          'City not found. Check the spelling or choose a suggestion.',
        );
      }

      if (response.statusCode == 401) {
        throw Exception(
          'Weather API key is invalid or not activated yet.',
        );
      }

      throw Exception(
        data['message']?.toString() ??
            'Weather service error (${response.statusCode}).',
      );
    } on http.ClientException {
      throw Exception(
        'Could not connect to the weather service. Check your internet.',
      );
    } on FormatException {
      throw Exception(
        'The weather service returned an invalid response.',
      );
    }
  }

  static Future<Map<String, dynamic>> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
      final url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'appid': WeatherConfig.apiKey,
          'units': 'metric',
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      }

      if (response.statusCode == 401) {
        throw Exception('Weather API key is invalid or not activated yet.');
      }

      throw Exception(
        data['message']?.toString() ??
          'Could not retrieve weather for your current location.',
      );
  }
}
