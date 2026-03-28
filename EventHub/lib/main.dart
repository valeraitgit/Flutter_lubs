import 'package:flutter/material.dart';

void main() {
  runApp(const EventHubApp());
}

// ==============================
// МОДЕЛЬ ДАННЫХ
// ==============================
class EventCategory {
  final String name;
  final IconData icon;
  final Color color;

  const EventCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Event {
  String title;
  String description;
  String location;
  EventCategory category;
  DateTime date;
  TimeOfDay time;
  List<String> participants;
  String emoji;

  Event({
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.date,
    required this.time,
    required this.participants,
    required this.emoji,
  });
}

// ==============================
// КАТЕГОРИИ
// ==============================
const categories = [
  EventCategory(name: 'Учёба', icon: Icons.school, color: Colors.blue),
  EventCategory(name: 'Спорт', icon: Icons.sports_soccer, color: Colors.green),
  EventCategory(
      name: 'Развлечения', icon: Icons.celebration, color: Colors.orange),
  EventCategory(name: 'Работа', icon: Icons.work, color: Colors.red),
  EventCategory(name: 'Личное', icon: Icons.favorite, color: Colors.pink),
];

// ==============================
// НАЧАЛЬНЫЕ ДАННЫЕ
// ==============================
List<Event> events = [
  Event(
    title: 'Лекция по Flutter',
    description: 'Лабораторная работа №5. Создание приложения EventHub '
        'с использованием GridView, BottomSheet и других виджетов.',
    location: 'Аудитория 305',
    category: categories[0],
    date: DateTime.now(),
    time: const TimeOfDay(hour: 9, minute: 0),
    participants: ['Иванов А.', 'Петрова Б.', 'Сидоров В.'],
    emoji: '📚',
  ),
  Event(
    title: 'Футбол с друзьями',
    description: 'Товарищеский матч 5 на 5. Не забудь форму и воду!',
    location: 'Стадион «Спартак»',
    category: categories[1],
    date: DateTime.now().add(const Duration(days: 1)),
    time: const TimeOfDay(hour: 18, minute: 30),
    participants: ['Команда А', 'Команда Б'],
    emoji: '⚽',
  ),
  Event(
    title: 'Кинопремьера',
    description: 'Новый фильм в IMAX. Билеты уже куплены, ряд 7.',
    location: 'Кинотеатр «Синема Парк»',
    category: categories[2],
    date: DateTime.now().add(const Duration(days: 2)),
    time: const TimeOfDay(hour: 20, minute: 0),
    participants: ['Аня', 'Максим', 'Даша'],
    emoji: '🎬',
  ),
  Event(
    title: 'Митап по мобильной разработке',
    description:
        'Доклады: Compose vs Flutter, архитектура чистого кода, CI/CD.',
    location: 'Коворкинг «Точка кипения»',
    category: categories[3],
    date: DateTime.now().add(const Duration(days: 3)),
    time: const TimeOfDay(hour: 19, minute: 0),
    participants: ['Спикер 1', 'Спикер 2', '~50 участников'],
    emoji: '💻',
  ),
  Event(
    title: 'День рождения Маши',
    description: 'Собираемся у Маши дома. Подарок: книга по Dart.',
    location: 'ул. Ленина, 42',
    category: categories[4],
    date: DateTime.now().add(const Duration(days: 5)),
    time: const TimeOfDay(hour: 17, minute: 0),
    participants: ['Маша', 'Ваня', 'Катя', 'Олег', 'Лиза'],
    emoji: '🎂',
  ),
  Event(
    title: 'Защита курсовой',
    description:
        'Финальная защита курсовой работы по дисциплине «Мобильная разработка».',
    location: 'Аудитория 112',
    category: categories[0],
    date: DateTime.now().add(const Duration(days: 7)),
    time: const TimeOfDay(hour: 10, minute: 0),
    participants: ['Группа ИСТ-21', 'Преподаватель'],
    emoji: '🎓',
  ),
];

// ==============================
// ПРИЛОЖЕНИЕ
// ==============================
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

// ==============================
// ГЛАВНЫЙ ЭКРАН
// ==============================
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String _selectedCategory = 'Все';

  // Задание 2: поиск
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // Задание 2: сортировка
  String _sortMode = 'date';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Event> get _filteredEvents {
    List<Event> result = List.from(events);

    if (_selectedCategory != 'Все') {
      result =
          result.where((e) => e.category.name == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
              (e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_sortMode) {
      case 'date':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'title':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'category':
        result.sort((a, b) => a.category.name.compareTo(b.category.name));
        break;
    }

    return result;
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    return '${d.day} ${months[d.month]}';
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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
                  hintText: 'Поиск по названию...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('EventHub'),
        actions: [
          // Задание 2: поиск
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
          // Задание 2: сортировка
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: (v) => setState(() => _sortMode = v),
            itemBuilder: (ctx) => [
              _sortItem('date', Icons.calendar_today, 'По дате'),
              _sortItem('title', Icons.sort_by_alpha, 'По названию'),
              _sortItem('category', Icons.category, 'По категории'),
            ],
          ),
          // Задание 3: статистика
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Статистика',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по категориям
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Все'),
                      avatar: const Icon(Icons.apps, size: 18),
                      selected: _selectedCategory == 'Все',
                      onSelected: (_) =>
                          setState(() => _selectedCategory = 'Все'),
                    ),
                  ),
                  ...categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.name),
                          avatar: Icon(cat.icon, size: 18),
                          selected: _selectedCategory == cat.name,
                          onSelected: (sel) => setState(
                              () => _selectedCategory = sel ? cat.name : 'Все'),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Строка статистики
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Icon(Icons.event_note, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedCategory == 'Все'
                      ? 'Всего событий: ${events.length}'
                      : '$_selectedCategory: ${_filteredEvents.length} из ${events.length}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  '· Найдено: ${_filteredEvents.length}',
                  style: TextStyle(
                      color: Colors.deepPurple[400],
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
            ]),
          ),

          // Сетка событий
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Нет событий',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 18)),
                      ],
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(12),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children:
                        _filteredEvents.map((e) => _buildEventCard(e)).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Событие'),
      ),
    );
  }

  PopupMenuItem<String> _sortItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon,
            size: 18,
            color: _sortMode == value ? Colors.deepPurple : Colors.grey),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontWeight:
                    _sortMode == value ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  // Карточка события с Dismissible
  Widget _buildEventCard(Event event) {
    return Dismissible(
      key: ValueKey(event),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      onDismissed: (_) {
        setState(() => events.remove(event));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${event.title} удалено'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () => setState(() => events.add(event)),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () async {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          );
          if (updated == true) setState(() {});
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    event.category.color.withOpacity(0.7),
                    event.category.color.withOpacity(0.4),
                  ]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(_formatDate(event.date),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(_formatTime(event.time),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Универсальный BottomSheet (добавление и редактирование)
  void _showEventSheet(BuildContext context, {Event? editEvent}) {
    final titleCtrl = TextEditingController(text: editEvent?.title ?? '');
    final descCtrl = TextEditingController(text: editEvent?.description ?? '');
    final locationCtrl = TextEditingController(text: editEvent?.location ?? '');
    EventCategory selectedCat = editEvent?.category ?? categories[0];
    DateTime selectedDate = editEvent?.date ?? DateTime.now();
    TimeOfDay selectedTime = editEvent?.time ?? TimeOfDay.now();

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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(
                  editEvent != null ? Icons.edit : Icons.add_circle,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                Text(
                  editEvent != null ? 'Редактировать событие' : 'Новое событие',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Место',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(children: [
                            Icon(cat.icon, size: 20, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ]),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setSheet(() => selectedCat = val);
                },
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setSheet(() => selectedDate = d);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                        '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: selectedTime);
                      if (t != null) setSheet(() => selectedTime = t);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      if (editEvent != null) {
                        // Задание 1: редактируем поля напрямую
                        editEvent.title = titleCtrl.text;
                        editEvent.description = descCtrl.text.isNotEmpty
                            ? descCtrl.text
                            : 'Без описания';
                        editEvent.location = locationCtrl.text.isNotEmpty
                            ? locationCtrl.text
                            : 'Не указано';
                        editEvent.category = selectedCat;
                        editEvent.date = selectedDate;
                        editEvent.time = selectedTime;
                      } else {
                        events.add(Event(
                          title: titleCtrl.text,
                          description: descCtrl.text.isNotEmpty
                              ? descCtrl.text
                              : 'Без описания',
                          location: locationCtrl.text.isNotEmpty
                              ? locationCtrl.text
                              : 'Не указано',
                          category: selectedCat,
                          date: selectedDate,
                          time: selectedTime,
                          participants: [],
                          emoji: '📌',
                        ));
                      }
                    });
                    Navigator.pop(ctx);
                  }
                },
                icon: const Icon(Icons.check),
                label: Text(editEvent != null
                    ? 'Сохранить изменения'
                    : 'Создать событие'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================
// ЭКРАН ДЕТАЛЕЙ СОБЫТИЯ
// ==============================
class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _wasEdited = false;

  void _openEdit() async {
    final e = widget.event;
    final titleCtrl = TextEditingController(text: e.title);
    final descCtrl = TextEditingController(text: e.description);
    final locationCtrl = TextEditingController(text: e.location);
    EventCategory selectedCat = e.category;
    DateTime selectedDate = e.date;
    TimeOfDay selectedTime = e.time;

    await showModalBottomSheet(
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.edit, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text('Редактировать событие',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Описание',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                    labelText: 'Место',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                value: selectedCat,
                decoration: const InputDecoration(
                    labelText: 'Категория',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder()),
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(children: [
                            Icon(cat.icon, size: 20, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ]),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setSheet(() => selectedCat = val);
                },
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setSheet(() => selectedDate = d);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                        '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: selectedTime);
                      if (t != null) setSheet(() => selectedTime = t);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    // Задание 1: обновляем данные события
                    setState(() {
                      e.title = titleCtrl.text;
                      e.description = descCtrl.text.isNotEmpty
                          ? descCtrl.text
                          : 'Без описания';
                      e.location = locationCtrl.text.isNotEmpty
                          ? locationCtrl.text
                          : 'Не указано';
                      e.category = selectedCat;
                      e.date = selectedDate;
                      e.time = selectedTime;
                      _wasEdited = true;
                    });
                    Navigator.pop(ctx);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Сохранить изменения'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: event.category.color.withOpacity(0.3),
        leading: BackButton(
          onPressed: () => Navigator.pop(context, _wasEdited),
        ),
        actions: [
          // Задание 1: кнопка редактирования в AppBar
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать',
            onPressed: _openEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Баннер
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.category.color.withOpacity(0.6),
                    event.category.color.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(children: [
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: Text(event.emoji,
                      style: TextStyle(
                          fontSize: 100, color: Colors.white.withOpacity(0.3))),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(event.category.icon,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(event.category.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      Text(event.title,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ]),
            ),

            // Дата, время, место
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _infoRow(
                        Icons.calendar_today,
                        'Дата',
                        '${event.date.day}.${event.date.month}.${event.date.year}',
                        event.category.color),
                    const Divider(),
                    _infoRow(
                        Icons.access_time,
                        'Время',
                        '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}',
                        event.category.color),
                    const Divider(),
                    _infoRow(Icons.location_on, 'Место', event.location,
                        event.category.color),
                  ]),
                ),
              ),
            ),

            // Описание (ExpansionTile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: Icon(Icons.description, color: event.category.color),
                  title: const Text('Описание',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(event.description,
                          style: const TextStyle(fontSize: 15, height: 1.5)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Участники (ExpansionTile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: Icon(Icons.people, color: event.category.color),
                  title: Text('Участники (${event.participants.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    ...event.participants.map((name) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                event.category.color.withOpacity(0.2),
                            child: Text(name[0],
                                style: TextStyle(
                                    color: event.category.color,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(name),
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

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ]),
    ]);
  }
}

// ==============================
// Задание 3: ЭКРАН СТАТИСТИКИ
// ==============================
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = events.length;
    final sorted = [...events]..sort((a, b) => a.date.compareTo(b.date));
    final nearest = sorted.isNotEmpty ? sorted.first : null;
    final nearest3 = sorted.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Общая сводка
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$total',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Всего событий',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        if (nearest != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ближайшее: ${nearest.emoji} ${nearest.title}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${nearest.date.day}.${nearest.date.month}.${nearest.date.year}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 16),
            const Text('По категориям',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Карточки по каждой категории с CircularProgressIndicator
            ...categories.map((cat) {
              final count =
                  events.where((e) => e.category.name == cat.name).length;
              final fraction = total > 0 ? count / total : 0.0;
              final percent = (fraction * 100).toInt();

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    // Задание 3: CircularProgressIndicator с числом
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: fraction,
                            strokeWidth: 6,
                            color: cat.color,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Text('$count',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(cat.icon, size: 18, color: cat.color),
                            const SizedBox(width: 6),
                            Text(cat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const Spacer(),
                            Text('$percent%',
                                style: TextStyle(
                                    color: cat.color,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(cat.color),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('$count из $total событий',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }),

            const SizedBox(height: 16),
            const Text('Ближайшие 3 события',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (nearest3.isEmpty)
              Center(
                child: Text('Нет событий',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              )
            else
              ...nearest3.map((event) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      leading: Text(event.emoji,
                          style: const TextStyle(fontSize: 28)),
                      title: Text(event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${event.date.day}.${event.date.month}.${event.date.year} · ${event.category.name}',
                        style: TextStyle(
                            fontSize: 12, color: event.category.color),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Row(children: [
                                Icon(Icons.location_on,
                                    size: 15, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(event.location,
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                Icon(Icons.people,
                                    size: 15, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Text('${event.participants.length} участников',
                                    style: TextStyle(color: Colors.grey[600])),
                              ]),
                              const SizedBox(height: 6),
                              Text(
                                event.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
