import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// Задание 2: MyApp переведён на StatefulWidget для переключения темы
// ============================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Задание 2: переменная для тёмной/светлой темы
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой профиль',
      // Задание 1: цвет — красный; Задание 2: переключение темы
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      // Задание 3: главный экран с BottomNavigationBar
      home: MainScreen(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}

// ============================================================
// Задание 3: Главный экран с тремя вкладками
// ============================================================
class MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const MainScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProfileScreen(
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      const GalleryScreen(),
      const ContactsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      // Задание 3: нижняя навигация
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Галерея',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Контакты',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Задания 1 + 2: Экран профиля
// ============================================================
class ProfileScreen extends StatefulWidget {
  // Задание 2: передача функции переключения темы через параметры конструктора
  final VoidCallback? onToggleTheme;
  final bool isDark;

  const ProfileScreen({
    super.key,
    this.onToggleTheme,
    this.isDark = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _likes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой профиль'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Задание 2: кнопка переключения темы
          IconButton(
            icon: Icon(
              widget.isDark ? Icons.brightness_7 : Icons.brightness_6,
            ),
            tooltip: 'Переключить тему',
            onPressed: widget.onToggleTheme,
          ),
          // Кнопка «О приложении»
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Задание 1: аватар с инициалами ВВ, цвет красный
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.red,
                child: Text(
                  'ВВ',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Задание 1: имя — Валерий Викторович
              const Text(
                'Валерий Викторович',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Flutter-разработчик',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Информационные карточки — Задание 1: персональные данные
              Card(
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.red),
                      title: Text('Email'),
                      subtitle: Text('valera@mail.ru'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text('Телефон'),
                      subtitle: Text('+7 (923) 777-77-77'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.red),
                      title: Text('Город'),
                      subtitle: Text('Новосибирск'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Задание 1: дополнительная карточка
              Card(
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.school, color: Colors.red),
                      title: Text('Университет'),
                      subtitle: Text('НГУЭУ'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.code, color: Colors.blueGrey),
                      title: Text('GitHub'),
                      subtitle: Text('github.com/valeraitgit'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Теги интересов
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Интересы',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(
                    avatar: Icon(Icons.code, size: 18),
                    label: Text('Flutter'),
                  ),
                  Chip(
                    avatar: Icon(Icons.phone_android, size: 18),
                    label: Text('Mobile Dev'),
                  ),
                  Chip(
                    avatar: Icon(Icons.cloud, size: 18),
                    label: Text('Cloud'),
                  ),
                  Chip(
                    avatar: Icon(Icons.sports_esports, size: 18),
                    label: Text('GameDev'),
                  ),
                  Chip(
                    avatar: Icon(Icons.music_note, size: 18),
                    label: Text('Музыка'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Кнопки лайка и сообщения
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _likes++;
                      });
                    },
                    icon: const Icon(Icons.favorite),
                    label: Text('Нравится ($_likes)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Сообщение отправлено!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Написать'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Задание 3: Экран галереи с GridView.count
// ============================================================
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static const List<String> _imageUrls = [
    'https://picsum.photos/seed/flutter1/300/300',
    'https://picsum.photos/seed/flutter2/300/300',
    'https://picsum.photos/seed/flutter3/300/300',
    'https://picsum.photos/seed/flutter4/300/300',
    'https://picsum.photos/seed/flutter5/300/300',
    'https://picsum.photos/seed/flutter6/300/300',
    'https://picsum.photos/seed/flutter7/300/300',
    'https://picsum.photos/seed/flutter8/300/300',
    'https://picsum.photos/seed/flutter9/300/300',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Галерея'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        padding: const EdgeInsets.all(4),
        children: _imageUrls.map((url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.red,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// Задание 3: Экран контактов с ListView.builder (минимум 5 контактов)
// ============================================================
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  static const List<Map<String, String>> _contacts = [
    {'name': 'Алексей Смирнов', 'phone': '+7 (999) 111-22-33', 'icon': 'А'},
    {'name': 'Мария Кузнецова', 'phone': '+7 (999) 444-55-66', 'icon': 'М'},
    {'name': 'Дмитрий Попов', 'phone': '+7 (999) 777-88-99', 'icon': 'Д'},
    {'name': 'Анна Соколова', 'phone': '+7 (999) 222-33-44', 'icon': 'А'},
    {'name': 'Иван Новиков', 'phone': '+7 (999) 555-66-77', 'icon': 'И'},
    {'name': 'Ольга Морозова', 'phone': '+7 (999) 888-99-00', 'icon': 'О'},
    {'name': 'Сергей Волков', 'phone': '+7 (999) 333-44-55', 'icon': 'С'},
  ];

  static const List<Color> _avatarColors = [
    Colors.redAccent,
    Colors.deepOrange,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.deepPurple,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакты'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _avatarColors[index % _avatarColors.length],
                child: Text(
                  contact['icon']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                contact['name']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(contact['phone']!),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Звонок: ${contact['name']}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// Экран «О приложении»
// ============================================================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile App',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Версия 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Это учебное приложение, созданное '
              'в рамках лабораторной работы по Flutter.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Использованные виджеты:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...[
              'Scaffold & AppBar',
              'Column & Row',
              'Card & ListTile',
              'CircleAvatar',
              'Chip & Wrap',
              'ElevatedButton',
              'SnackBar',
              'Navigator',
              'GridView.count',
              'ListView.builder',
              'BottomNavigationBar',
              'StatefulWidget & setState',
              'ThemeData (тёмная/светлая тема)',
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(item, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
