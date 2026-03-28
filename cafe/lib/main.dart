      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.dishes.length,
        itemBuilder: (context, index) {
          return _buildDishCard(context, category.dishes[index]);
        },
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, Dish dish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DishDetailScreen(
                dish: dish,
                categoryColor: category.color,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(dish.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${dish.price.toInt()} ₽',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: category.color,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================
// ЭКРАН 3: КАРТОЧКА БЛЮДА
// ==============================
class DishDetailScreen extends StatefulWidget {
  final Dish dish;
  final Color categoryColor;

  const DishDetailScreen({
    super.key,
    required this.dish,
    required this.categoryColor,
  });

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish.name),
        backgroundColor: widget.categoryColor.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Баннер с эмодзи
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.categoryColor.withOpacity(0.4),
                    widget.categoryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(
                  widget.dish.emoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dish.name,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.dish.price.toInt()} ₽',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.categoryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.dish.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Состав:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.dish.ingredients
                        .map(
                          (item) => Chip(
                            avatar: Icon(Icons.check_circle,
                                size: 18, color: widget.categoryColor),
                            label: Text(item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Выбор количества
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 36,
                        color: widget.categoryColor,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 36,
                        color: widget.categoryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Кнопка «В заказ» — Задание 2: добавление в корзину
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        final total = widget.dish.price * _quantity;
                        // Задание 2: добавляем в глобальную корзину
                        cart.add({
                          'name': widget.dish.name,
                          'price': widget.dish.price,
                          'quantity': _quantity,
                          'emoji': widget.dish.emoji,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${widget.dish.name} x$_quantity = ${total.toInt()} ₽ добавлено в заказ!',
                            ),
                            backgroundColor: widget.categoryColor,
                            action: SnackBarAction(
                              label: 'Корзина',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CartScreen()),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.categoryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'В заказ — ${(widget.dish.price * _quantity).toInt()} ₽',
                        style: const TextStyle(fontSize: 18),
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

// ==============================
// Задание 2: ЭКРАН КОРЗИНЫ
// ==============================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get _totalSum => cart.fold(
        0,
        (sum, item) =>
            sum + (item['price'] as double) * (item['quantity'] as int),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Очистить корзину',
              onPressed: () {
                setState(() => cart.clear());
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛒', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('Корзина пуста',
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Добавьте блюда из меню',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final itemTotal =
                          (item['price'] as double) * (item['quantity'] as int);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Text(
                            item['emoji'] as String,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(
                            item['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['quantity']} × ${(item['price'] as double).toInt()} ₽',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${itemTotal.toInt()} ₽',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() => cart.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Итоговая сумма и кнопка оформления
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Итого:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_totalSum.toInt()} ₽',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Заказ оформлен! 🎉'),
                                content: Text(
                                  'Ваш заказ на ${_totalSum.toInt()} ₽ принят.\nОжидайте, пожалуйста!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() => cart.clear());
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Отлично!'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Оформить заказ',
                              style: TextStyle(fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
