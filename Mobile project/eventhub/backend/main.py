"""
EventHub — REST API (FastAPI)
Итоговый проект. Студент: Валерий Иванов, НГУЭУ
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import date, time
import uuid

app = FastAPI(
    title="EventHub API",
    description="REST API для приложения планировщика мероприятий EventHub",
    version="1.0.0",
)

# CORS — разрешаем запросы с любых источников (для мобильного клиента)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────────────────────────────────────────
# МОДЕЛИ
# ──────────────────────────────────────────────

class EventCreate(BaseModel):
    title: str
    description: str
    location: str
    category: str          # "Учёба" | "Спорт" | "Развлечения" | "Работа" | "Личное"
    date: str              # ISO-формат: "2025-06-01"
    time: str              # "HH:MM"
    emoji: str = "📌"
    participants: List[str] = []

class EventUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    category: Optional[str] = None
    date: Optional[str] = None
    time: Optional[str] = None
    emoji: Optional[str] = None
    participants: Optional[List[str]] = None

class EventOut(BaseModel):
    id: str
    title: str
    description: str
    location: str
    category: str
    date: str
    time: str
    emoji: str
    participants: List[str]

class StatsOut(BaseModel):
    total: int
    by_category: dict

# ──────────────────────────────────────────────
# «БАЗА ДАННЫХ» (in-memory для MVP)
# ──────────────────────────────────────────────

_db: dict[str, dict] = {}

def _seed():
    """Заполняем начальными данными при старте."""
    seed_events = [
        {"title": "Лекция по Flutter",       "description": "Разбираем GridView, BottomSheet, Kubernetes.",
         "location": "Аудитория 305", "category": "Учёба",       "date": "2025-06-01", "time": "09:00",
         "emoji": "📚", "participants": ["Иванов А.", "Петрова Б."]},
        {"title": "Футбол с друзьями",        "description": "Товарищеский матч 5 на 5.",
         "location": "Стадион Спартак",       "category": "Спорт",        "date": "2025-06-02", "time": "18:30",
         "emoji": "⚽", "participants": ["Команда А", "Команда Б"]},
        {"title": "Кинопремьера",             "description": "Новый фильм в IMAX, ряд 7.",
         "location": "Синема Парк",           "category": "Развлечения",  "date": "2025-06-03", "time": "20:00",
         "emoji": "🎬", "participants": ["Аня", "Максим", "Даша"]},
        {"title": "Митап по мобайлу",         "description": "Compose vs Flutter, CI/CD.",
         "location": "Коворкинг Точка",       "category": "Работа",       "date": "2025-06-04", "time": "19:00",
         "emoji": "💻", "participants": ["Спикер 1", "Спикер 2"]},
        {"title": "День рождения Маши",       "description": "Подарок — книга по Dart.",
         "location": "ул. Ленина 42",         "category": "Личное",       "date": "2025-06-06", "time": "17:00",
         "emoji": "🎂", "participants": ["Маша", "Ваня", "Катя"]},
        {"title": "Защита курсовой",          "description": "Финальная защита по мобильной разработке.",
         "location": "Аудитория 112",         "category": "Учёба",        "date": "2025-06-08", "time": "10:00",
         "emoji": "🎓", "participants": ["Группа ИСТ-21", "Преподаватель"]},
    ]
    for ev in seed_events:
        eid = str(uuid.uuid4())
        _db[eid] = {"id": eid, **ev}

_seed()

# ──────────────────────────────────────────────
# ENDPOINTS
# ──────────────────────────────────────────────

@app.get("/", tags=["health"])
def root():
    return {"status": "ok", "service": "EventHub API", "version": "1.0.0"}

@app.get("/health", tags=["health"])
def health():
    return {"status": "healthy"}

# --- Events CRUD ---

@app.get("/events", response_model=List[EventOut], tags=["events"])
def list_events(category: Optional[str] = None):
    """Получить все события. Опциональная фильтрация по категории."""
    result = list(_db.values())
    if category:
        result = [e for e in result if e["category"] == category]
    result.sort(key=lambda e: (e["date"], e["time"]))
    return result

@app.get("/events/{event_id}", response_model=EventOut, tags=["events"])
def get_event(event_id: str):
    """Получить одно событие по ID."""
    if event_id not in _db:
        raise HTTPException(status_code=404, detail="Событие не найдено")
    return _db[event_id]

@app.post("/events", response_model=EventOut, status_code=201, tags=["events"])
def create_event(event: EventCreate):
    """Создать новое событие."""
    eid = str(uuid.uuid4())
    record = {"id": eid, **event.dict()}
    _db[eid] = record
    return record

@app.put("/events/{event_id}", response_model=EventOut, tags=["events"])
def update_event(event_id: str, update: EventUpdate):
    """Обновить существующее событие (частичное обновление)."""
    if event_id not in _db:
        raise HTTPException(status_code=404, detail="Событие не найдено")
    for field, value in update.dict(exclude_none=True).items():
        _db[event_id][field] = value
    return _db[event_id]

@app.delete("/events/{event_id}", status_code=204, tags=["events"])
def delete_event(event_id: str):
    """Удалить событие."""
    if event_id not in _db:
        raise HTTPException(status_code=404, detail="Событие не найдено")
    del _db[event_id]

# --- Statistics ---

@app.get("/stats", response_model=StatsOut, tags=["stats"])
def get_stats():
    """Статистика: общее число событий и разбивка по категориям."""
    by_cat: dict[str, int] = {}
    for ev in _db.values():
        cat = ev["category"]
        by_cat[cat] = by_cat.get(cat, 0) + 1
    return {"total": len(_db), "by_category": by_cat}
