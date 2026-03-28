import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ──────────────────────────────────────────────
// Конфигурация API
// Для запуска локально: http://localhost:8000
// В Kubernetes:        http://<LoadBalancer-IP>:8000
// ──────────────────────────────────────────────
const String kBaseUrl = 'http://localhost:8000';

void main() {
  runApp(const EventHubApp());
}

// ──────────────────────────────────────────────
// МОДЕЛИ
// ──────────────────────────────────────────────
class EventCategory {
  final String name;
  final IconData icon;
  final Color color;
  const EventCategory(
      {required this.name, required this.icon, required this.color});
}

const categories = [
  EventCategory(name: 'Учёба',       icon: Icons.school,        color: Colors.blue),
  EventCategory(name: 'Спорт',       icon: Icons.sports_soccer, color: Colors.green),
  EventCategory(name: 'Развлечения', icon: Icons.celebration,   color: Colors.orange),
  EventCategory(name: 'Работа',      icon: Icons.work,          color: Colors.red),
  EventCategory(name: 'Личное',      icon: Icons.favorite,      color: Colors.pink),
];

EventCategory _catByName(String name) =>
    categories.firstWhere((c) => c.name == name,
        orElse: () => const EventCategory(
            name: 'Другое', icon: Icons.event, color: Colors.grey));

class Event {
  final String id;
  String title;
  String description;
  String location;
  String category;
  String date;   // "YYYY-MM-DD"
  String time;   // "HH:MM"
  String emoji;
  List<String> participants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.date,
    required this.time,
    required this.emoji,
    required this.participants,
  });

  factory Event.fromJson(Map<String, dynamic> j) => Event(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        location: j['location'] as String,
        category: j['category'] as String,
        date: j['date'] as String,
        time: j['time'] as String,
        emoji: j['emoji'] as String,
        participants: List<String>.from(j['participants'] as List),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'location': location,
        'category': category,
        'date': date,
        'time': time,
        'emoji': emoji,
        'participants': participants,
      };
}

// ──────────────────────────────────────────────
// API-СЕРВИС
// ──────────────────────────────────────────────
class ApiService {
  static const _base = kBaseUrl;

  static Future<List<Event>> fetchEvents({String? category}) async {
    final uri = Uri.parse('$_base/events')
        .replace(queryParameters: category != null ? {'category': category} : null);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((j) => Event.fromJson(j)).toList();
    }
    throw Exception('Ошибка загрузки событий: ${res.statusCode}');
  }

  static Future<Event> createEvent(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$_base/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 201) {
      return Event.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception('Ошибка создания: ${res.statusCode}');
  }

  static Future<Event> updateEvent(String id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$_base/events/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return Event.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception('Ошибка обновления: ${res.statusCode}');
  }

  static Future<void> deleteEvent(String id) async {
    final res = await http.delete(Uri.parse('$_base/events/$id'));
    if (res.statusCode != 204) {
      throw Exception('Ошибка удаления: ${res.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchStats() async {
    final res = await http.get(Uri.parse('$_base/stats'));
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw Exception('Ошибка загрузки статистики');
  }
}

// ──────────────────────────────────────────────
// ПРИЛОЖЕНИЕ
// ──────────────────────────────────────────────
class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EventListScreen(),
    );
  }
}

// ──────────────────────────────────────────────
// ГЛАВНЫЙ ЭКРАН
// ──────────────────────────────────────────────
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Event> _events = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = 'Все';

  // Поиск (задание 2)
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cat =
          _selectedCategory == 'Все' ? null : _selectedCategory;
      final evs = await ApiService.fetchEvents(category: cat);
      setState(() {
        _events = evs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Event> get _filtered {
    if (_searchQuery.isEmpty) return _events;
    return _events
        .where((e) =>
            e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String _displayDate(String iso) {
    // "2025-06-01" → "1 июн"
    const months = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    try {
      final parts = iso.split('-');
      return '${int.parse(parts[2])} ${months[int.parse(parts[1])]}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Поиск...', border: InputBorder.none),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('EventHub'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchCtrl.clear();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Статистика',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Все', Icons.apps),
                  ...categories.map((c) => _chip(c.name, c.icon)),
                ],
              ),
            ),
          ),

          // Строка статистики
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              Icon(Icons.event_note, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _selectedCategory == 'Все'
                    ? 'Всего: ${_events.length}'
                    : '$_selectedCategory: ${_filtered.length} из ${_events.length}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ]),
          ),

          // Тело
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Событие'),
      ),
    );
  }

  Widget _chip(String name, IconData icon) {
    final selected = _selectedCategory == name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(name),
        avatar: Icon(icon, size: 16),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedCategory = name);
          _load();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Не удалось подключиться к серверу',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ]),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text('Нет событий',
            style: TextStyle(fontSize: 18, color: Colors.grey[400])),
      ]));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: _filtered.map((e) => _card(e)).toList(),
      ),
    );
  }

  Widget _card(Event event) {
    final cat = _catByName(event.category);
    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      onDismissed: (_) async {
        try {
          await ApiService.deleteEvent(event.id);
          setState(() => _events.remove(event));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${event.title} удалено'),
            action: SnackBarAction(
                label: 'Отменить',
                onPressed: () async {
                  await ApiService.createEvent(event.toJson());
                  _load();
                }),
          ));
        } catch (e) {
          _load();
        }
      },
      child: GestureDetector(
        onTap: () async {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event)),
          );
          if (updated == true) _load();
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    cat.color.withOpacity(0.7),
                    cat.color.withOpacity(0.4),
                  ]),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.emoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.calendar_today,
                            size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(_displayDate(event.date),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                        const SizedBox(width: 6),
                        Icon(Icons.access_time,
                            size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(event.time,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on,
                            size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600])),
                        ),
                      ]),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BottomSheet создания
  void _showSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String selCat = categories[0].name;
    DateTime selDate = DateTime.now();
    TimeOfDay selTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.add_circle, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text('Новое событие',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Название',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Описание',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Место',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selCat,
                decoration: const InputDecoration(
                    labelText: 'Категория',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder()),
                items: categories
                    .map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Row(children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ])))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheet(() => selCat = v);
                },
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                          context: ctx,
                          initialDate: selDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (d != null) setSheet(() => selDate = d);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                        '${selDate.day}.${selDate.month}.${selDate.year}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: selTime);
                      if (t != null) setSheet(() => selTime = t);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                        '${selTime.hour.toString().padLeft(2, '0')}:${selTime.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty) return;
                  final dateStr =
                      '${selDate.year}-${selDate.month.toString().padLeft(2, '0')}-${selDate.day.toString().padLeft(2, '0')}';
                  final timeStr =
                      '${selTime.hour.toString().padLeft(2, '0')}:${selTime.minute.toString().padLeft(2, '0')}';
                  try {
                    await ApiService.createEvent({
                      'title': titleCtrl.text,
                      'description': descCtrl.text.isNotEmpty
                          ? descCtrl.text
                          : 'Без описания',
                      'location': locationCtrl.text.isNotEmpty
                          ? locationCtrl.text
                          : 'Не указано',
                      'category': selCat,
                      'date': dateStr,
                      'time': timeStr,
                      'emoji': '📌',
                      'participants': [],
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: $e')));
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Создать событие'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ЭКРАН ДЕТАЛЕЙ
// ──────────────────────────────────────────────
class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _wasEdited = false;

  void _openEdit() {
    final e = widget.event;
    final titleCtrl = TextEditingController(text: e.title);
    final descCtrl = TextEditingController(text: e.description);
    final locationCtrl = TextEditingController(text: e.location);
    String selCat = e.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.edit, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text('Редактировать',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Название',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Место',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selCat,
                decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder()),
                items: categories
                    .map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Row(children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ])))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheet(() => selCat = v);
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await ApiService.updateEvent(e.id, {
                      'title': titleCtrl.text,
                      'description': descCtrl.text,
                      'location': locationCtrl.text,
                      'category': selCat,
                    });
                    setState(() {
                      e.title = titleCtrl.text;
                      e.description = descCtrl.text;
                      e.location = locationCtrl.text;
                      e.category = selCat;
                      _wasEdited = true;
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  } catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: $err')));
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final cat = _catByName(event.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: cat.color.withOpacity(0.3),
        leading: BackButton(
            onPressed: () => Navigator.pop(context, _wasEdited)),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _openEdit),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  cat.color.withOpacity(0.6),
                  cat.color.withOpacity(0.2),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Stack(children: [
                Positioned(
                  right: 20, bottom: 10,
                  child: Text(event.emoji,
                      style: TextStyle(
                          fontSize: 90,
                          color: Colors.white.withOpacity(0.25))),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(cat.icon, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(event.category,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ]),
                      ),
                      const SizedBox(height: 6),
                      Text(event.title,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _row(Icons.calendar_today, 'Дата', event.date, cat.color),
                    const Divider(),
                    _row(Icons.access_time, 'Время', event.time, cat.color),
                    const Divider(),
                    _row(Icons.location_on, 'Место', event.location, cat.color),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: Icon(Icons.description, color: cat.color),
                  title: const Text('Описание',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(event.description,
                            style: const TextStyle(fontSize: 15, height: 1.5))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: Icon(Icons.people, color: cat.color),
                  title: Text(
                      'Участники (${event.participants.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    ...event.participants.map((n) => ListTile(
                          leading: CircleAvatar(
                              backgroundColor: cat.color.withOpacity(0.2),
                              child: Text(n[0],
                                  style: TextStyle(
                                      color: cat.color,
                                      fontWeight: FontWeight.bold))),
                          title: Text(n),
                        )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500)),
      ]),
    ]);
  }
}

// ──────────────────────────────────────────────
// ЭКРАН СТАТИСТИКИ
// ──────────────────────────────────────────────
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final s = await ApiService.fetchStats();
      setState(() { _stats = s; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildStats(),
    );
  }

  Widget _buildStats() {
    final total = _stats!['total'] as int;
    final bycat = Map<String, dynamic>.from(_stats!['by_category']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text('$total',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Всего событий',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          const Text('По категориям',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...categories.map((cat) {
            final count = (bycat[cat.name] ?? 0) as int;
            final frac = total > 0 ? count / total : 0.0;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                          value: frac,
                          strokeWidth: 5,
                          color: cat.color,
                          backgroundColor: Colors.grey[200]),
                    ),
                    Text('$count',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(cat.icon, size: 16, color: cat.color),
                            const SizedBox(width: 6),
                            Text(cat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const Spacer(),
                            Text('${(frac * 100).toInt()}%',
                                style: TextStyle(
                                    color: cat.color,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                                value: frac,
                                minHeight: 7,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation(cat.color)),
                          ),
                        ]),
                  ),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}
