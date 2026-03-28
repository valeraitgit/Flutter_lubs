# EventHub — Итоговый проект

**Студент:** Валерий Иванов  
**Университет:** НГУЭУ  
**Дисциплина:** Мобильная разработка  

---

## Описание

**EventHub** — мобильное приложение планировщика мероприятий.  
Архитектура: Flutter-клиент ↔ REST API (FastAPI) ↔ Kubernetes.

---

## Архитектура системы

```
┌─────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                  │
│  Namespace: eventhub                                 │
│                                                      │
│  ┌──────────────────┐    ┌──────────────────────┐   │
│  │  eventhub-        │    │  eventhub-backend    │   │
│  │  frontend         │    │  (FastAPI × 2 pods)  │   │
│  │  (Flutter Web     │───▶│                      │   │
│  │   nginx × 2 pods) │    │  ClusterIP :8000     │   │
│  │                   │    │  NodePort  :30800    │   │
│  │  LoadBalancer :80 │    └──────────────────────┘   │
│  └──────────────────┘              ▲                 │
│           ▲                        │ HPA (2–5 pods)  │
└───────────┼────────────────────────┼─────────────────┘
            │                        │
     Браузер/Web              Flutter Mobile App
     (Flutter Web)            Android / iOS
```

### Компоненты

| Компонент | Технология | Назначение |
|---|---|---|
| Мобильный клиент | Flutter (Dart) | UI, HTTP-запросы к API |
| Backend API | Python FastAPI | REST CRUD, статистика |
| Контейнеризация | Docker | Сборка образов |
| Оркестрация | Kubernetes | Деплой, масштабирование |
| Автомасштабирование | HPA | CPU/RAM → до 5 реплик |

---

## Структура проекта

```
eventhub/
├── backend/
│   ├── main.py            # FastAPI REST API
│   ├── requirements.txt
│   └── Dockerfile
├── flutter_app/
│   ├── main.dart          # Flutter-приложение
│   ├── pubspec.yaml
│   ├── nginx.conf
│   └── Dockerfile
├── k8s/
│   ├── 00-namespace.yaml       # Namespace eventhub
│   ├── 01-backend.yaml         # Deployment + Service (ClusterIP)
│   ├── 02-frontend.yaml        # Deployment + Service (LoadBalancer)
│   ├── 03-hpa.yaml             # HorizontalPodAutoscaler
│   └── 04-config-nodeport.yaml # ConfigMap + NodePort для мобильного
└── README.md
```

---

## API — Эндпоинты

| Метод | URL | Описание |
|---|---|---|
| GET | `/` | Статус сервиса |
| GET | `/health` | Health-check (для Kubernetes probe) |
| GET | `/events` | Список событий (фильтр: `?category=Спорт`) |
| GET | `/events/{id}` | Одно событие |
| POST | `/events` | Создать событие |
| PUT | `/events/{id}` | Обновить событие |
| DELETE | `/events/{id}` | Удалить событие |
| GET | `/stats` | Статистика по категориям |

Документация Swagger: `http://localhost:8000/docs`

---

## Запуск локально (без Kubernetes)

### 1. Бэкенд

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Проверить: `http://localhost:8000/docs`

### 2. Flutter-приложение

В `flutter_app/main.dart` убедиться, что:
```dart
const String kBaseUrl = 'http://localhost:8000';
```

```bash
cd flutter_app
flutter pub get
flutter run          # мобильный эмулятор
# или
flutter run -d chrome  # веб
```

---

## Запуск в Kubernetes (Minikube)

### Шаг 1. Собрать Docker-образы

```bash
# Запустить Minikube и направить Docker в его окружение
minikube start
eval $(minikube docker-env)

# Собрать образы
docker build -t eventhub-backend:1.0.0  ./backend/
docker build -t eventhub-frontend:1.0.0 ./flutter_app/
```

### Шаг 2. Применить манифесты

```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-backend.yaml
kubectl apply -f k8s/02-frontend.yaml
kubectl apply -f k8s/03-hpa.yaml
kubectl apply -f k8s/04-config-nodeport.yaml
```

Или всё сразу:
```bash
kubectl apply -f k8s/
```

### Шаг 3. Проверить состояние

```bash
# Посмотреть поды
kubectl get pods -n eventhub

# Посмотреть сервисы
kubectl get services -n eventhub

# Посмотреть HPA
kubectl get hpa -n eventhub
```

Ожидаемый вывод:
```
NAME                          READY   STATUS    RESTARTS
eventhub-backend-xxxx-xxx     1/1     Running   0
eventhub-backend-xxxx-yyy     1/1     Running   0
eventhub-frontend-xxxx-xxx    1/1     Running   0
eventhub-frontend-xxxx-yyy    1/1     Running   0
```

### Шаг 4. Открыть приложение

```bash
# Фронтенд (Flutter Web)
minikube service eventhub-frontend -n eventhub

# API напрямую (для мобильного клиента)
minikube service eventhub-backend-nodeport -n eventhub
```

### Шаг 5. Обновить URL в Flutter-клиенте

Заменить в `main.dart`:
```dart
// Узнать IP: minikube ip
const String kBaseUrl = 'http://192.168.49.2:30800';
```

---

## Kubernetes — ключевые концепции

| Объект | Для чего используется |
|---|---|
| **Namespace** `eventhub` | Изоляция ресурсов проекта от других |
| **Deployment** | Описывает желаемое состояние (2 реплики, образ) |
| **Pod** | Запущенный контейнер (единица выполнения) |
| **Service ClusterIP** | Внутренний балансировщик между подами бэкенда |
| **Service LoadBalancer** | Внешний IP для доступа к фронтенду |
| **Service NodePort** | Прямой порт узла для мобильного клиента |
| **HPA** | Автомасштабирование при нагрузке CPU > 70% |
| **ConfigMap** | Хранение конфигурации без перестройки образа |
| **Liveness Probe** | Перезапуск пода, если `/health` не отвечает |
| **Readiness Probe** | Не пускает трафик, пока под не готов |

---

## Функциональность приложения

- Просмотр событий в сетке GridView (2 карточки в ряд)
- Фильтрация по категориям (ChoiceChip)
- Поиск по названию в реальном времени
- Создание события (BottomSheet: название, описание, место, категория, дата, время)
- Редактирование события (кнопка Edit на экране деталей)
- Удаление свайпом с возможностью отмены (SnackBar)
- Экран деталей с ExpansionTile (описание, участники)
- Экран статистики (CircularProgressIndicator по каждой категории)
- Pull-to-refresh для обновления данных с сервера
- Обработка ошибок сети (экран с кнопкой «Повторить»)

---

## Категории событий

| Категория | Цвет |
|---|---|
| Учёба | Синий |
| Спорт | Зелёный |
| Развлечения | Оранжевый |
| Работа | Красный |
| Личное | Розовый |
