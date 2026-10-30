# Phone Cleaner

Flutter-приложение для очистки телефона: поиск и удаление мусорных файлов, дублей фото и неиспользуемых приложений. Тёмная тема с «жидким» glassmorphism-интерфейсом.

## Возможности

- **Обзор** — сводка по состоянию памяти устройства
- **Очистка** — сканирование файловой системы на мусор (кэши, логи, временные файлы) с удалением
- **Дубли** — поиск дубликатов фото по хешу содержимого (MD5) с предпросмотром и удалением
- **Память** — оценка неиспользуемых приложений

## Стек

- Flutter (Dart ^3.10), Riverpod для состояния
- `permission_handler`, `path_provider`, `crypto`, `shared_preferences`, `image`

## Запуск

```bash
flutter pub get
flutter run
```

## Сборка APK

```bash
flutter build apk --debug
```

## Тесты и анализ

```bash
flutter analyze
flutter test
```

CI (GitHub Actions) прогоняет analyse, test и debug-сборку APK на каждый push — см. [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Структура

```
lib/
├── main.dart                 # точка входа, навигация между экранами
├── models/clean_item.dart    # модели CleanItem, DuplicateGroup, UnusedApp
├── screens/                  # экраны: обзор, очистка, дубли, память
├── services/
│   ├── scan_service.dart     # сканирование ФС, дубликаты, неиспользуемые приложения
│   └── permission_service.dart
├── theme/app_theme.dart      # тёмная «liquid»-тема
└── widgets/                  # glass-карточки, навигация, фон
```

## Ограничения платформ

- **iOS** — из-за песочницы очистка произвольных файлов недоступна; работают только фото-дубли и кэш приложения.
- **Android** — для полного доступа к хранилищу требуется разрешение `MANAGE_EXTERNAL_STORAGE`.

## Roadmap

- [ ] Platform channel для списка установленных приложений и usage stats
- [ ] История очисток (shared_preferences)
- [ ] Локализация

## Лицензия

[MIT](LICENSE)
