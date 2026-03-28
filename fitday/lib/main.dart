import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const FitDayApp());
}

// ==============================
// МОДЕЛЬ ДАННЫХ
// ==============================
class Exercise {
  String name;
  String emoji;
  int sets;
  int reps;
  int calories;
  bool isDone;

  Exercise({
    required this.name,
    required this.emoji,
    required this.sets,
    required this.reps,
    required this.calories,
    this.isDone = false,
  });
}

// ==============================
// ДАННЫЕ ТРЕНИРОВКИ
// ==============================
List<Exercise> todayWorkout = _initialWorkout();

List<Exercise> _initialWorkout() => [
      Exercise(name: 'Отжимания', emoji: '💪', sets: 3, reps: 15, calories: 50),
      Exercise(
          name: 'Приседания', emoji: '🧎', sets: 4, reps: 20, calories: 70),
      Exercise(name: 'Планка', emoji: '🧘', sets: 3, reps: 1, calories: 40),
      Exercise(name: 'Бёрпи', emoji: '🔥', sets: 3, reps: 10, calories: 90),
      Exercise(
          name: 'Скручивания', emoji: '🏋', sets: 3, reps: 20, calories: 45),
      Exercise(name: 'Выпады', emoji: '🏃', sets: 3, reps: 12, calories: 60),
    ];

// Цель по калориям (изменяется в настройках)
int calorieGoal = 300;

// Задание 2: глобальный список истории
List<Map<String, dynamic>> history = [];

// ==============================
// ПРИЛОЖЕНИЕ
// ==============================
class FitDayApp extends StatelessWidget {
  const FitDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitDay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ==============================
// ГЛАВНЫЙ ЭКРАН С ВКЛАДКАМИ
// ==============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Задание 2: 4 вкладки
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitDay'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Тренировка'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Прогресс'),
            Tab(icon: Icon(Icons.settings), text: 'Настройки'),
            Tab(icon: Icon(Icons.history), text: 'История'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WorkoutTab(onChanged: _refresh),
          const ProgressTab(),
          SettingsTab(onChanged: _refresh),
          const HistoryTab(),
        ],
      ),
    );
  }
}

// ==============================
// ВКЛАДКА 1: ТРЕНИРОВКА
// ==============================
class WorkoutTab extends StatefulWidget {
  final VoidCallback onChanged;
  const WorkoutTab({super.key, required this.onChanged});

  @override
  State<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  // Диалог добавления упражнения
  void _addExercise() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новое упражнение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Подтягивания',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Подходы'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Повторения'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  todayWorkout.add(Exercise(
                    name: nameCtrl.text,
                    emoji: '⭐',
                    sets: int.tryParse(setsCtrl.text) ?? 3,
                    reps: int.tryParse(repsCtrl.text) ?? 10,
                    calories: 30,
                  ));
                });
                widget.onChanged();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  // Задание 1: диалог удаления по долгому нажатию
  void _confirmDelete(int index) {
    final ex = todayWorkout[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить упражнение?'),
        content: Text('«${ex.emoji} ${ex.name}» будет удалено из списка.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => todayWorkout.removeAt(index));
              widget.onChanged();
              Navigator.pop(ctx);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  // Задание 2: завершить день и сохранить в историю
  void _finishDay() {
    final doneCount = todayWorkout.where((e) => e.isDone).length;
    final totalCalories =
        todayWorkout.where((e) => e.isDone).fold(0, (s, e) => s + e.calories);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить день?'),
        content: Text(
          'Выполнено: $doneCount / ${todayWorkout.length} упражнений\n'
          'Сожжено: $totalCalories ккал\n\n'
          'Тренировка будет сохранена в историю.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              history.add({
                'date': DateTime.now().toString().substring(0, 10),
                'exercises': doneCount,
                'total': todayWorkout.length,
                'calories': totalCalories,
              });
              setState(() => todayWorkout = _initialWorkout());
              widget.onChanged();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('День сохранён в историю! 🎉'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = todayWorkout.where((e) => e.isDone).length;

    return Scaffold(
      body: Column(
        children: [
          // Заголовок-статистика
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Сегодня: $doneCount из ${todayWorkout.length}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Задание 2: кнопка завершения дня
                    TextButton.icon(
                      onPressed: _finishDay,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Завершить день'),
                      style: TextButton.styleFrom(foregroundColor: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: todayWorkout.isEmpty
                        ? 0
                        : doneCount / todayWorkout.length,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),

          // Список упражнений
          Expanded(
            child: todayWorkout.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🏋', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text('Список пуст',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Нажмите + чтобы добавить упражнение',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: todayWorkout.length,
                    itemBuilder: (context, index) {
                      final ex = todayWorkout[index];
                      return Card(
                        color: ex.isDone ? Colors.teal.withOpacity(0.1) : null,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          // Задание 3: нажатие — открыть таймер
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TimerScreen(exercise: ex),
                            ),
                          ),
                          // Задание 1: долгое нажатие — удалить
                          onLongPress: () => _confirmDelete(index),
                          leading: Text(ex.emoji,
                              style: const TextStyle(fontSize: 32)),
                          title: Text(
                            ex.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration:
                                  ex.isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            '${ex.sets} подходов × ${ex.reps} повт. | ${ex.calories} ккал',
                          ),
                          trailing: Switch(
                            value: ex.isDone,
                            onChanged: (val) {
                              setState(() => ex.isDone = val);
                              widget.onChanged();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==============================
// ВКЛАДКА 2: ПРОГРЕСС
// ==============================
class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final doneCount = todayWorkout.where((e) => e.isDone).length;
    final totalCalories =
        todayWorkout.where((e) => e.isDone).fold(0, (s, e) => s + e.calories);
    final totalMinutes = doneCount * 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Прогресс за сегодня',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildGoalCard(context,
              emoji: '🎯',
              title: 'Упражнения',
              current: doneCount,
              goal: todayWorkout.isEmpty ? 1 : todayWorkout.length,
              unit: 'шт.',
              color: Colors.teal),
          const SizedBox(height: 12),
          _buildGoalCard(context,
              emoji: '🔥',
              title: 'Калории',
              current: totalCalories,
              goal: calorieGoal,
              unit: 'ккал',
              color: Colors.orange),
          const SizedBox(height: 12),
          _buildGoalCard(context,
              emoji: '⏱',
              title: 'Время',
              current: totalMinutes,
              goal: 45,
              unit: 'мин',
              color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Выполнено:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...todayWorkout.where((e) => e.isDone).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Text(e.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('${e.name} — ${e.calories} ккал',
                      style: const TextStyle(fontSize: 15)),
                ]),
              )),
          if (doneCount == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Пока ничего. Отметьте упражнения на вкладке «Тренировка»!',
                style: TextStyle(
                    color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context,
      {required String emoji,
      required String title,
      required int current,
      required int goal,
      required String unit,
      required Color color}) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  Text('$percent%',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 6),
                Text('$current / $goal $unit',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================
// ВКЛАДКА 3: НАСТРОЙКИ
// ==============================
class SettingsTab extends StatefulWidget {
  final VoidCallback onChanged;
  const SettingsTab({super.key, required this.onChanged});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notifications = true;
  bool _sound = false;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Настройки',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              SwitchListTile(
                title: const Text('Уведомления'),
                subtitle: const Text('Напоминания о тренировке'),
                secondary: const Icon(Icons.notifications),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Звук'),
                subtitle: const Text('Звуковые эффекты'),
                secondary: const Icon(Icons.volume_up),
                value: _sound,
                onChanged: (v) => setState(() => _sound = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Вибрация'),
                subtitle: const Text('При выполнении упражнения'),
                secondary: const Icon(Icons.vibration),
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Цель по калориям',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$calorieGoal ккал',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Slider(
                    value: calorieGoal.toDouble(),
                    min: 100,
                    max: 800,
                    divisions: 14,
                    label: '$calorieGoal ккал',
                    onChanged: (val) {
                      setState(() => calorieGoal = val.toInt());
                      widget.onChanged();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('100 ккал',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                      Text('800 ккал',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('О приложении'),
                subtitle: Text('FitDay v1.0 — Лабораторная работа №4'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Сбросить тренировку',
                    style: TextStyle(color: Colors.red)),
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Подтверждение'),
                    content: const Text('Сбросить все отметки выполнения?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Отмена')),
                      FilledButton(
                        onPressed: () {
                          for (var e in todayWorkout) {
                            e.isDone = false;
                          }
                          setState(() {});
                          widget.onChanged();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Сбросить'),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ==============================
// Задание 2: ВКЛАДКА 4 — ИСТОРИЯ
// ==============================
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📅', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('История пуста',
                style: TextStyle(fontSize: 20, color: Colors.grey)),
            SizedBox(height: 6),
            Text(
              'Завершите тренировку на вкладке «Тренировка»',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        // Показываем от новых к старым
        final item = history[history.length - 1 - index];
        final done = item['exercises'] as int;
        final total = item['total'] as int;
        final calories = item['calories'] as int;
        final date = item['date'] as String;
        final progress = total > 0 ? done / total : 0.0;
        final isComplete = done == total;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок: дата + бейдж
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.teal),
                  const SizedBox(width: 6),
                  Text(date,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.teal.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isComplete ? '✅ Выполнено' : '⚡ Частично',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? Colors.teal : Colors.orange),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                // Чипы статистики
                Row(children: [
                  _chip('🎯', '$done/$total упр.'),
                  const SizedBox(width: 8),
                  _chip('🔥', '$calories ккал'),
                  const SizedBox(width: 8),
                  _chip('⏱', '${done * 5} мин'),
                ]),
                const SizedBox(height: 10),

                // Прогресс-бар
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                        isComplete ? Colors.teal : Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================
// Задание 3: ЭКРАН-ТАЙМЕР
// ==============================
class TimerScreen extends StatefulWidget {
  final Exercise exercise;
  const TimerScreen({super.key, required this.exercise});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int _startSeconds = 30;

  int _secondsLeft = _startSeconds;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning || _secondsLeft == 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _isRunning = false;
          t.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Подход завершён! 💪'),
              backgroundColor: Colors.teal,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _startSeconds;
      _isRunning = false;
    });
  }

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress => _secondsLeft / _startSeconds;

  Color get _timerColor {
    if (_secondsLeft <= 10) return Colors.red;
    if (_secondsLeft <= 20) return Colors.orange;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.teal.withOpacity(0.2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Эмодзи + название
              Text(widget.exercise.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(widget.exercise.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${widget.exercise.sets} подходов × ${widget.exercise.reps} повторений',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),

              const SizedBox(height: 40),

              // Круговой таймер
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(_timerColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _timeLabel,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: _timerColor,
                        ),
                      ),
                      Text(
                        _isRunning
                            ? 'идёт отсчёт'
                            : (_secondsLeft == 0 ? 'готово!' : 'пауза'),
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Кнопки: Сброс | Старт/Пауза | Дальше
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _sideButton(
                    icon: Icons.refresh,
                    label: 'Сброс',
                    color: Colors.grey,
                    onTap: _reset,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _isRunning ? _pause : _start,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _secondsLeft == 0
                            ? Colors.grey
                            : (_isRunning ? Colors.orange : Colors.teal),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRunning ? Colors.orange : Colors.teal)
                                .withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _sideButton(
                    icon: Icons.skip_next,
                    label: 'Дальше',
                    color: Colors.teal,
                    onTap: () {
                      _reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Следующий подход!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Подсказки
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _hint(Icons.touch_app,
                        'Нажмите на упражнение — открыть таймер'),
                    const SizedBox(height: 6),
                    _hint(
                        Icons.pan_tool, 'Долгое нажатие — удалить упражнение'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sideButton({
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _hint(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
      ],
    );
  }
}
