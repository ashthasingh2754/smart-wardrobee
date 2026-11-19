
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadWardrobe();

  runApp(const SmartWardrobeApp());
}

const Color purple = Color(0xFF8E6CEF);
const Color lightPurple = Color(0xFFF9F6FF);

class SmartWardrobeApp extends StatelessWidget {
  const SmartWardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Wardrobe',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9B7EDE),
          brightness: Brightness.light,
          primary: const Color(0xFF9272D8),
          secondary: const Color(0xFFE8A6C8),
          surface: const Color(0xFFFFFBFF),
        ),

        scaffoldBackgroundColor: const Color(0xFFFAF7FF),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3ECFA),
          foregroundColor: Color(0xFF392B4A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF392B4A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFFFFFCFF),
          elevation: 2,
          shadowColor: const Color(0xFF9272D8).withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Color(0xFFEDE3FA),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFE5D8F5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
            color: Color(0xFFE5D8F5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFF9272D8),
              width: 1.8,
            ),
          ),
        ),
      ),
      home: const WardrobeHomePage(),
    );
  }
}

class ClothingItem {
  ClothingItem({
    required this.name,
    required this.category,
    required this.color,
    required this.occasion,
    this.isFavorite = false,
    this.imageData,
  });

  final String name;
  final String category;
  final String color;
  final String occasion;
  bool isFavorite;
  String? imageData;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'color': color,
      'occasion': occasion,
      'isFavorite': isFavorite,
      'imageData': imageData,
    };
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      name: json['name'] as String,
      category: json['category'] as String,
      color: json['color'] as String,
      occasion: json['occasion'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageData: json['imageData'] as String?,
    );
  }
}

final List<ClothingItem> wardrobe = [];
Future<void> saveWardrobe() async {
  final prefs = await SharedPreferences.getInstance();

  final String encodedData = jsonEncode(
    wardrobe.map((item) => item.toJson()).toList(),
  );

  await prefs.setString('wardrobe_items', encodedData);
}

Future<void> loadWardrobe() async {
  final prefs = await SharedPreferences.getInstance();

  final String? savedData = prefs.getString('wardrobe_items');

  if (savedData != null) {
    final List<dynamic> decodedData = jsonDecode(savedData);

    wardrobe
      ..clear()
      ..addAll(
        decodedData.map(
          (item) => ClothingItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        ),
      );
  }
}


class WardrobeHomePage extends StatefulWidget {
  const WardrobeHomePage({super.key});

  @override
  State<WardrobeHomePage> createState() => _WardrobeHomePageState();
}

class _WardrobeHomePageState extends State<WardrobeHomePage> {
  Future<void> openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) setState(() {});
  }

  Future<void> addClothing() async {
    final result = await Navigator.push<ClothingItem>(
      context,
      MaterialPageRoute(builder: (_) => const AddClothingPage()),
    );

    if (result != null && mounted) {
      setState(() => wardrobe.add(result));
      await saveWardrobe();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clothing item added! ♡')),
      );
    }
  }

  Widget _sectionTitle(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF352746),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _shortcut({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(icon, color: purple, size: 29),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF51445E),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentItems = wardrobe.reversed.take(6).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),

      // APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7FF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Style Diary ♡',
          style: TextStyle(
            color: Color(0xFF352746),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => openPage(const FavoritesPage()),
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: purple,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // HOME CONTENT
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // WELCOME SECTION
              const Text(
                'Hello, fashion lover! ✨',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF352746),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'What are we wearing today?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF95869F),
                ),
              ),
            
              const SizedBox(height: 24),

              // OUTFIT INSPIRATION BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF9272D8),
                      Color(0xFFB99AF0),
                      Color(0xFFEFBBD9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 5,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 95,
                        color: Colors.white.withValues(alpha: 0.17),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR DAILY STYLE INSPIRATION',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'Dress up n Feel amazing ♡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your next favorite outfit is waiting.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 19),
                        ElevatedButton(
                          onPressed: () =>
                              openPage(const GenerateOutfitPage()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: purple,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Create an outfit  →',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
              const SizedBox(height: 29),

              // QUICK ACCESS
              const Text(
                'Explore your style',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF352746),
                ),
              ),
              const SizedBox(height: 17),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shortcut(
                    icon: Icons.checkroom_rounded,
                    label: 'My Closet',
                    color: const Color(0xFFEFE3FF),
                    onTap: () => openPage(const MyClothesPage()),
                  ),
                  _shortcut(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Outfits',
                    color: const Color(0xFFFFE6F0),
                    onTap: () => openPage(const GenerateOutfitPage()),
                  ),
                  _shortcut(
                    icon: Icons.cloud_rounded,
                    label: 'Weather',
                    color: const Color(0xFFE3EFFF),
                    onTap: () => openPage(const WeatherPage()),
                  ),
                  _shortcut(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    color: const Color(0xFFFFE7E7),
                    onTap: () => openPage(const FavoritesPage()),
                  ),
                ],
              ),

              const SizedBox(height: 29),

              // RECENTLY ADDED
              _sectionTitle(
                'Recently added ♡',
                'See all',
                () => openPage(const MyClothesPage()),
              ),

              const SizedBox(height: 10),

              
              if (recentItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF3EAFE),
                        Color(0xFFFFEEF5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFFE9D9F5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.checkroom_rounded,
                          size: 42,
                          color: purple,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Your style story starts here! ♡',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF352746),
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Add your favourite pieces and create\nyour very own digital closet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF82728F),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: addClothing,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add your first clothing item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 205,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentItems.length,
                    itemBuilder: (context, index) {
                      final item = recentItems[index];

                      return GestureDetector(
                        onTap: () => openPage(const MyClothesPage()),
                        child: Container(
                          width: 145,
                          margin: const EdgeInsets.only(right: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFEDE3F7),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  color: const Color(0xFFF0EAF8),
                                  child: item.imageData != null
                                  ? Image.memory(
                                      base64Decode(item.imageData!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                      const Icon(
                                        Icons.checkroom_rounded,
                                        size: 45,
                                        color: purple,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.checkroom_rounded,
                                      size: 45,
                                      color: purple,
                                    ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF352746),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF95869F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 25),


              // WARDROBE COUNT
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.checkroom_rounded,
                      color: purple,
                      size: 28,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your little collection',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF352746),
                            ),
                          ),
                          Text(
                            '${wardrobe.length} beautiful pieces in your closet',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E7C9C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE69AC2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),  
      ),    
        
      

      // ANDROID STYLE BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: purple.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomItem(
                  Icons.home_rounded,
                  'Home',
                  true,
                  () {},
                ),
                _bottomItem(
                  Icons.checkroom_rounded,
                  'Closet',
                  false,
                  () => openPage(const MyClothesPage()),
                ),
                _bottomItem(
                  Icons.auto_awesome_rounded,
                  'Outfits',
                  false,
                  () => openPage(const GenerateOutfitPage()),
                ),
                _bottomItem(
                  Icons.cloud_rounded,
                  'Weather',
                  false,
                  () => openPage(const WeatherPage()),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addClothing,
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add_rounded, size: 29),
      ),
    );
  }

  Widget _bottomItem(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? purple : const Color(0xFFAA9BB8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? purple : const Color(0xFFAA9BB8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFCFF),
            Color(0xFFF5EEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE9DDF8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9272D8).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE9DEFF),
                        Color(0xFFFFE5F0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: const Color(0xFF9272D8),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF392B4A),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF82758D),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                    color: Color(0xFFB49ADD),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  InputDecoration _wardrobeInputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: purple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE9DFFF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: purple,
          width: 1.5,
        ),
      ),
    );
  }
}

class AddClothingPage extends StatefulWidget {
  final ClothingItem? itemToEdit;

  const AddClothingPage({
    super.key,
    this.itemToEdit,
  });
  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;

  late String category;
  late String color;
  late String occasion;
  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();

    final item = widget.itemToEdit;

    nameController = TextEditingController(
      text: item?.name ?? '',
    );

    category = item?.category ?? 'Top';
    color = item?.color ?? 'Black';
    occasion = item?.occasion ?? 'Casual';

    if (item?.imageData != null) {
      selectedImageBytes = base64Decode(item!.imageData!);
    }
  }

  Future<void> pickClothingImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      selectedImageBytes = bytes;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.itemToEdit == null ? 'Add to my closet' : 'Edit my outfit',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF352746),
          ),
        ),
      ),

      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
          // HEADER
            const Text(
              'A little more style, ♡',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF352746),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add a favourite piece to your wardrobe.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A7D98),
              ),
            ),

            const SizedBox(height: 26),

            // PHOTO UPLOAD CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF0E5FF),
                    Color(0xFFFFEAF4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFE8D8FF),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.photo_camera_rounded,
                        color: purple,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'YOUR STYLE SNAPSHOT',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7454B5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 190,
                          height: 210,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFD8C2FF),
                              width: 1.5,
                            ),
                          ),
                          child: selectedImageBytes == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      size: 54,
                                      color: Color(0xFF9A79E8),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Your outfit goes here',
                                      style: TextStyle(
                                        color: Color(0xFF8A7D98),
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Show us your style ✨',
                                      style: TextStyle(
                                        color: Color(0xFFB28BC9),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Image.memory(
                                    selectedImageBytes!,
                                    width: 190,
                                    height: 210,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: pickClothingImage,
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 19,
                          ),
                          label: const Text('Choose from gallery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7454B5),
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFD8C2FF),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // DETAILS HEADING
            const Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE99BC5),
                  size: 21,
                ),
                SizedBox(width: 8),
                Text(
                  'The little details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF352746),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // CLOTHING NAME
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Clothing name',
                hintText: 'e.g. White cotton shirt',
                prefixIcon: const Icon(
                  Icons.checkroom_rounded,
                  color: purple,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9DFFF),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: purple,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter a clothing name'
                      : null,
            ),

            const SizedBox(height: 16),

            // CATEGORY
            DropdownButtonFormField<String>(
              value: category,
              decoration: _wardrobeInputDecoration(
                'Category',
                Icons.category_rounded,
              ),
              items: [
                'Top',
                'Bottom',
                'Dress',
                'Shoes',
                'Outerwear',
                'Other',
              ].map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              )).toList(),
              onChanged: (v) {
                if (v != null) setState(() => category = v);
              },
            ),

            const SizedBox(height: 16),

            // COLOR
            DropdownButtonFormField<String>(
              value: color,
              decoration: _wardrobeInputDecoration(
                'Color',
                Icons.palette_rounded,
              ),
              items: [
                'Black',
                'White',
                'Blue',
                'Red',
                'Pink',
                'Purple',
                'Green',
                'Yellow',
                'Brown',
                'Other',
              ].map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              )).toList(),
              onChanged: (v) {
                if (v != null) setState(() => color = v);
              },
            ),
  
            const SizedBox(height: 16),

          // OCCASION
            DropdownButtonFormField<String>(
              value: occasion,
              decoration: _wardrobeInputDecoration(
                'Occasion',
                Icons.event_available_rounded,
              ),
              items: [
                'Casual',
                'Formal',
                'Party',
                'Sports',
                'Traditional',
              ].map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              )).toList(),
              onChanged: (v) {
                if (v != null) setState(() => occasion = v);
              },
            ),
 
            const SizedBox(height: 28),

          // SAVE BUTTON
            SizedBox(
              height: 58,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8E6CEF),
                      Color(0xFFB58BEF),
                      Color(0xFFE8A8D0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final oldItem = widget.itemToEdit;
  
                      Navigator.pop(
                        context,
                        ClothingItem(
                          name: nameController.text.trim(),
                          category: category,
                          color: color,
                          occasion: occasion,
                          imageData: selectedImageBytes == null
                              ? oldItem?.imageData
                              : base64Encode(selectedImageBytes!),
                        )..isFavorite = oldItem?.isFavorite ?? false,
                      );
                    }
                  },
                  icon: const Icon(Icons.favorite_rounded),
                  label: Text(
                    widget.itemToEdit == null
                        ? 'Add to My Wardrobe'
                        : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),  

            const SizedBox(height: 16),
  
            const Center(
              child: Text(
                'MADE WITH LOVE FOR YOUR STYLE ♡',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: Color(0xFFA497B5),
                  fontWeight: FontWeight.w600,
                ),  
              ),
            ),
          ],  
        ),
      ),  
    );
  }
  InputDecoration _wardrobeInputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: purple,
      ),
      filled: true,
      fillColor: const Color(0xFFFFFAFE),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8DDF8),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8DDF8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: purple,
          width: 1.8,
        ),
      ),
    );
  }
}

class MyClothesPage extends StatefulWidget {
  const MyClothesPage({super.key});

  @override
  State<MyClothesPage> createState() => _MyClothesPageState();
}

class _MyClothesPageState extends State<MyClothesPage> {
  String selectedCategory = 'All';
  String searchQuery = '';
  String sortOption = 'Newest First';

  final List<String> categories = [
    'All',
    'Top',
    'Bottom',
    'Dress',
    'Shoes',
    'Outerwear',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final items = wardrobe.where((item) {
      final matchesCategory = selectedCategory == 'All' ||
          item.category == selectedCategory;

      final matchesSearch =
          item.name.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    if (sortOption == 'Name A-Z') {
      items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else if (sortOption == 'Name Z-A') {
      items.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7FF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Closet ♡',
          style: TextStyle(
            color: Color(0xFF352746),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sort clothes',
            icon: const Icon(Icons.sort_rounded, color: purple),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                builder: (sheetContext) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sort your closet',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF352746),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...[
                            'Newest First',
                            'Name A-Z',
                            'Name Z-A',
                          ].map(
                            (option) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(option),
                              trailing: sortOption == option
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: purple,
                                    )
                                  : null,
                              onTap: () {
                                setState(() => sortOption = option);
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onPressed: () async {
          final newItem = await Navigator.push<ClothingItem>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddClothingPage(),
            ),
          );

          if (newItem != null && mounted) {
            setState(() => wardrobe.add(newItem));
            await saveWardrobe();

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your new style is in the closet! ♡'),
              ),
            );
          }
        },
        child: const Icon(Icons.add_rounded, size: 30),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your personal style diary',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E7C9C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SEARCH BAR
                  TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search your clothes...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAA9BB8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: purple,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SECTION TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'The collection ✨',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF352746),
                        ),
                      ),
                      Text(
                        '${items.length} pieces',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E7C9C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // CATEGORY FILTERS
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: categories.map((categoryName) {
                        final isSelected =
                            selectedCategory == categoryName;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(categoryName),
                            selected: isSelected,
                            showCheckmark: false,
                            selectedColor: purple,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF65566F),
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? purple
                                  : const Color(0xFFE9DFF5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = categoryName;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // CLOTHING GALLERY
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0E6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.checkroom_rounded,
                                size: 52,
                                color: purple,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Your closet is waiting ♡',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF352746),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your favorite pieces to start\nbuilding your personal style diary.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF8E7C9C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.64,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFEFE5F8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: purple.withValues(alpha: 0.07),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CLOTHING PHOTO
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: const Color(0xFFF2ECF8),
                                      child: item.imageData != null
                                          ? Image.memory(
                                              base64Decode(item.imageData!),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      const Icon(
                                                Icons.checkroom_rounded,
                                                size: 55,
                                                color: purple,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.checkroom_rounded,
                                              size: 55,
                                              color: purple,
                                            ),
                                    ),

                                    // FAVORITE BUTTON
                                    Positioned(
                                      top: 9,
                                      right: 9,
                                      child: Material(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        shape: const CircleBorder(),
                                        child: IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: Icon(
                                            item.isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            color: item.isFavorite
                                                ? Colors.pink
                                                : purple,
                                            size: 21,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              item.isFavorite =
                                                  !item.isFavorite;
                                            });
                                            await saveWardrobe();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // CLOTHING DETAILS
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  11,
                                  12,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF352746),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${item.color} • ${item.category}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF8E7C9C),
                                      ),
                                    ),
                                    const SizedBox(height: 9),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2EAFF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item.occasion,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: purple,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),

                                        // MORE OPTIONS
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.more_horiz_rounded,
                                            color: Color(0xFF8E7C9C),
                                          ),
                                          onSelected: (action) async {
                                            if (action == 'edit') {
                                              final updatedItem =
                                                  await Navigator.push<
                                                      ClothingItem>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AddClothingPage(
                                                    itemToEdit: item,
                                                  ),
                                                ),
                                              );

                                              if (updatedItem != null &&
                                                  mounted) {
                                                setState(() {
                                                  final oldIndex =
                                                      wardrobe.indexOf(item);
                                                  if (oldIndex != -1) {
                                                    wardrobe[oldIndex] =
                                                        updatedItem;
                                                  }
                                                });
                                                await saveWardrobe();
                                              }
                                            } else if (action == 'delete') {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                    'Remove this piece?',
                                                  ),
                                                  content: Text(
                                                    'Delete "${item.name}" from your closet?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        dialogContext,
                                                        false,
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        dialogContext,
                                                        true,
                                                      ),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true && mounted) {
                                                setState(() {
                                                  wardrobe.remove(item);
                                                });
                                                await saveWardrobe();
                                              }
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    color: purple,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final favorites = wardrobe.where((item) => item.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Clothes')),
      body: favorites.isEmpty
          ? const Center(
              child: Text('No favorites yet. Tap the heart on a clothing item.'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text(item.name),
                    subtitle: Text('${item.color} • ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: item.isFavorite
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                          icon: Icon(
                            item.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: item.isFavorite ? Colors.red : purple,
                          ),
                          onPressed: () async {
                            setState(() {
                              item.isFavorite = !item.isFavorite;
                            });
                            await saveWardrobe();
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete clothing',
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete clothing?'),
                                content: Text(
                                  'Are you sure you want to delete "${item.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              setState(() {
                                wardrobe.remove(item);
                              });
                              await saveWardrobe();
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Clothing deleted successfully'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class GenerateOutfitPage extends StatefulWidget {
  const GenerateOutfitPage({super.key});

  @override
  State<GenerateOutfitPage> createState() => _GenerateOutfitPageState();
}

class _GenerateOutfitPageState extends State<GenerateOutfitPage> {
  String occasion = 'Casual';
  List<ClothingItem> suggestions = [];

  void generateOutfit() {
    setState(() {
      suggestions = wardrobe
          .where((item) => item.occasion == occasion)
          .toList();

      if (suggestions.isEmpty) {
        suggestions = wardrobe.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Outfit')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.auto_awesome, size: 70, color: purple),
          const SizedBox(height: 12),
          const Text(
            'Find your look',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose an occasion and get suggestions from your wardrobe.',
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: occasion,
            decoration: const InputDecoration(
              labelText: 'Occasion',
              border: OutlineInputBorder(),
            ),
            items: ['Casual', 'Formal', 'Party', 'Sports', 'Traditional']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => occasion = v!),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              padding: const EdgeInsets.all(15),
            ),
            onPressed: generateOutfit,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate My Outfit'),
          ),
          const SizedBox(height: 24),
          if (suggestions.isNotEmpty) ...[
            const Text(
              'Your outfit suggestions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...suggestions.map(
              (item) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.checkroom, color: purple),
                  title: Text(item.name),
                  subtitle: Text('${item.color} • ${item.category}'),
                ),
              ),
            ),
          ] else if (wardrobe.isEmpty)
            const Text(
              'Add some clothes first to generate outfit suggestions.',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController cityController =
      TextEditingController(text: 'Prayagraj');
      List<String> citySuggestions = [];

  Map<String, dynamic>? weather;
  bool isLoading = false;
  String? errorMessage;
  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Please enable location services and try again.',
        );
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission was denied. Please allow location access in Chrome.',
        );
      } 

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final result = await WeatherService.getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        weather = result;
        cityController.text =
            result['name']?.toString() ?? 'Current Location';
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeather() async {
    final city = cityController.text.trim();

    if (city.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name.';
        weather = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await WeatherService.getWeather(city);

      if (!mounted) return;

      setState(() {
        weather = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        weather = null;
        isLoading = false;
      });
    }
  }

  String getClothingSuggestion(double temperature, String condition) {
    final description = condition.toLowerCase();

    if (description.contains('rain') ||
        description.contains('drizzle') ||
        description.contains('thunderstorm')) {
      return 'Carry an umbrella or raincoat and choose quick-drying clothes.';
    }

    if (temperature >= 30) {
      return 'Choose lightweight, breathable clothes such as cotton T-shirts.';
    }

    if (temperature >= 20) {
      return 'Light shirts, T-shirts and comfortable trousers are good choices.';
    }

    if (temperature >= 10) {
      return 'Consider a long-sleeved shirt, trousers and a light jacket.';
    }

    return 'Wear warm layers, a sweater and a jacket.';
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temperature =
        (weather?['main']?['temp'] as num?)?.toDouble();

    final feelsLike =
        (weather?['main']?['feels_like'] as num?)?.toDouble();

    final humidity = weather?['main']?['humidity'];

    final condition =
        weather?['weather']?[0]?['description']?.toString() ?? '';

    final iconCode =
        weather?['weather']?[0]?['icon']?.toString();

    final cityName = weather == null
        ? ''
        : (cityController.text.trim().toLowerCase().contains('pray')
            || cityController.text.trim().toLowerCase().contains('allah')
            ? 'Prayagraj'
            : weather?['name']?.toString() ?? '');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Style'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dress for the weather ☁️',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check the weather and discover what to wear.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: cityController,
              onChanged: (value) {
                setState(() {
                  citySuggestions = WeatherService.getCitySuggestions(value);
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter city name',
                hintText: 'e.g. Prayagraj',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onSubmitted: (_) => fetchWeather(),
            ),
            if (citySuggestions.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: purple.withValues(alpha: 0.3)),
                ),
              child: Column(
                children: citySuggestions.map((city) {
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: purple),
                    title: Text(city),
                    onTap: () {
                      setState(() {
                        cityController.text = city;
                        citySuggestions = [];
                      });
                    fetchWeather();
                    },
                  );
                }).toList(),
              ),
            ),
          
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use My Current Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: purple,
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: purple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : fetchWeather,
                icon: const Icon(Icons.cloud),
                label: const Text('Check Weather'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),

            if (weather != null && temperature != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [purple, Color(0xFFB79BFF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (iconCode != null)
                      Image.network(
                        'https://openweathermap.org/img/wn/$iconCode@2x.png',
                        width: 90,
                        height: 90,
                        errorBuilder: (_, __, ___) =>
                            const Icon(
                              Icons.cloud,
                              color: Colors.white,
                              size: 60,
                            ),
                      ),
                    Text(
                      '${temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      condition.isEmpty
                          ? 'Weather information'
                          : condition[0].toUpperCase() +
                              condition.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.thermostat,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feelsLike == null
                                  ? 'N/A'
                                  : '${feelsLike.round()}°C',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Feels like',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              humidity == null ? 'N/A' : '$humidity%',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Humidity',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF4ECFF),
                    Color(0xFFFFEEF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE5D5FF),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.checkroom_rounded,
                          color: Color(0xFF8E6CEF),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR STYLE GUIDE ✨',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Color(0xFF8E6CEF),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'What should you wear?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF352746),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFEAA4CB),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF8E6CEF),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            getClothingSuggestion(
                              temperature ?? 0.0,
                              condition,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF51445E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'DRESS CUTE, FEEL CONFIDENT ♡',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFF9A79C8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
