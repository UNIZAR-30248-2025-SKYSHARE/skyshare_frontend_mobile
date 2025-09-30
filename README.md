# README — Cómo contribuir y flujo Git (GitFlow)

**Proyecto:** App de visualización de estrellas (Flutter + Supabase + Provider)  
Este documento guía a cualquier colaborador sobre cómo estructurar cambios, cómo crear ramas con GitFlow y pasos para dejar el trabajo listo para revisión/CI.

---

## 1 Visión rápida

- Usamos una estructura **feature-first**: cada _feature_ contiene `presentation/`, `providers/` y `data/`.
- Control de versiones: **GitFlow** (ramas `main` / `develop` + `feature/*`, `release/*`, `hotfix/*`).  
  El modelo se basa en la la documentación de GitFlow; 
  Referencias: https://www.atlassian.com/es/git/tutorials/comparing-workflows/gitflow-workflow.

---

## 2 Estructura del repositorio (resumen)

```
lib/
├─ main.dart
├─ core/
│  ├─ configs/
│  ├─ services/            # supabase_service.dart, notification_service.dart
│  ├─ models/
│  └─ widgets/
├─ features/
│  ├─ auth/
│  │  ├─ presentation/
│  │  ├─ providers/
│  │  └─ data/
│  ├─ map/
│  │  ├─ presentation/
│  │  ├─ providers/
│  │  └─ data/
│  └─ lunar/
├─ shared/
└─ tests/
```

- Cada feature contiene su `providers/` con `ChangeNotifier` por responsabilidad.
- Servicios que tocan Supabase, localización, notificaciones van en `core/services/`.  
(Este patrón está basado en prácticas estándar y guías de arquitectura Flutter).

---

## 3 Setup local rápido

Clona el repo:

```bash
git clone git@github.com:ORGANIZACION/REPO.git
cd REPO
```

Cambia a la rama develop:

```bash
git checkout develop
```

- Copia `.env.example` → `.env` y rellena las variables necesarias: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, etc. **NO subir `.env` al repo.**
- Instala dependencias Flutter:

```bash
flutter pub get
```

- Ejecuta la app (emulador o dispositivo):

```bash
flutter run
```

---

## 4 Flujo de trabajo con Git para añadir cambios (paso a paso)

1. Actualiza `develop` localmente:

```bash
git checkout develop
git pull origin develop
```

2. Crea una rama de feature a partir de `develop` (ver convenciones de nombre abajo).

- Usando `git-flow` (si está instalado):

```bash
git flow feature start mi-nueva-funcionalidad
```

- O con Git puro:

```bash
git checkout -b feature/mi-nueva-funcionalidad develop
```

3. Trabaja localmente con commits pequeños y atómicos.

4. Cuando la feature está lista: push de la rama y abrir Pull Request hacia `develop`.

```bash
git push -u origin feature/mi-nueva-funcionalidad
```

5. Tras realizar merge: elimina la rama remota.

```bash
git push origin --delete feature/mi-nueva-funcionalidad
```

---

## 5 Convención de nombres de ramas

Recomendación general:
- `feature/<descripcion-corta>` — nuevas funcionalidades.
- `fix/<descripcion-corta>` o `bugfix/<descripcion-corta>` — correcciones de bugs.
- `chore/<descripcion>` — tareas de mantenimiento (dependencias, scripts, etc).

Usar `kebab-case` (minúsculas y guiones) y descripciones cortas y claras.

## 6 Implementación práctica: como empezar a escribir código

A continuación se muestra **qué** código va en cada carpeta y **ejemplos** mínimos para empezar una funcionalidad. Tomaremos como ejemplo una nueva feature: **favorites** (marcar spots favoritos).

### Estructura sugerida para `favorites`

```
lib/features/favorites/
├─ data/
│  ├─ models/
│  │  └─ favorite_model.dart
│  ├─ repositories/
│  │  └─ favorite_repository.dart
├─ providers/
│  └─ favorites_provider.dart
└─ presentation/
   ├─ favorites_screen.dart
   └─ widgets/
      └─ favorite_tile.dart
```

### 6.1 Modelos (`data/models`)

Los modelos son clases simples que representan datos. Si existen modelos comunes, colócalos en `core/models/`.

**`lib/features/favorites/data/models/favorite_model.dart`**
```dart
class Favorite {
  final String id; // id del spot o recurso
  final String name;
  final DateTime createdAt;

  Favorite({required this.id, required this.name, DateTime? createdAt})
      : this.createdAt = createdAt ?? DateTime.now();

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### 6.2 Repositorios / Data source (`data/repositories`)

Aquí se aísla la lógica de acceso a Supabase (o cualquier API). Coloca tests unitarios que mockeen el repositorio.

**`lib/features/favorites/data/repositories/favorite_repository.dart`**
```dart
import 'package:your_app/core/services/supabase_service.dart';
import 'models/favorite_model.dart';

class FavoriteRepository {
  final SupabaseService supabase;

  FavoriteRepository(this.supabase);

  Future<List<Favorite>> getFavoritesForUser(String userId) async {
    final data = await supabase.from('favorites').select().eq('user_id', userId);
    // transforma la respuesta al modelo
    return (data as List).map((e) => Favorite.fromMap(e)).toList();
  }

  Future<void> addFavorite(String userId, Favorite fav) async {
    await supabase.from('favorites').insert({
      'id': fav.id,
      'name': fav.name,
      'user_id': userId,
      'created_at': fav.createdAt.toIso8601String(),
    });
  }

  Future<void> removeFavorite(String userId, String id) async {
    await supabase.from('favorites').delete().eq('id', id).eq('user_id', userId);
  }
}
```

> **Nota:** `SupabaseService` sería un wrapper en `core/services/supabase_service.dart` que expone métodos como `from(table).select()` para centralizar configuración y manejo de errores.

### 6.3 Providers (`providers/`)

`ChangeNotifier` que contiene el estado y la lógica de negocio ligada a UI.

**`lib/features/favorites/providers/favorites_provider.dart`**
```dart
import 'package:flutter/material.dart';
import '../data/models/favorite_model.dart';
import '../data/repositories/favorite_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoriteRepository repository;
  List<Favorite> _items = [];
  bool _loading = false;

  FavoritesProvider({required this.repository});

  List<Favorite> get items => _items;
  bool get isLoading => _loading;

  Future<void> loadFavorites(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      _items = await repository.getFavoritesForUser(userId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(String userId, Favorite fav) async {
    await repository.addFavorite(userId, fav);
    _items.add(fav);
    notifyListeners();
  }

  Future<void> removeFavorite(String userId, String id) async {
    await repository.removeFavorite(userId, id);
    _items.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}
```

### 6.4 Presentación (`presentation/`)

Widgets y pantallas consumen el Provider.

**`lib/features/favorites/presentation/favorites_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'widgets/favorite_tile.dart';

class FavoritesScreen extends StatelessWidget {
  final String userId;
  const FavoritesScreen({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Favoritos')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (_, i) => FavoriteTile(favorite: provider.items[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ejemplo: añadir favorito dummy
          provider.addFavorite(userId, Favorite(id: '123', name: 'Sirius'));
        },
      ),
    );
  }
}
```

**`lib/features/favorites/presentation/widgets/favorite_tile.dart`**
```dart
import 'package:flutter/material.dart';
import '../../data/models/favorite_model.dart';

class FavoriteTile extends StatelessWidget {
  final Favorite favorite;
  const FavoriteTile({required this.favorite, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(favorite.name),
      subtitle: Text(favorite.createdAt.toLocal().toString()),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          // obtener provider y borrar
        },
      ),
    );
  }
}
```

### 6.5 Registrar Provider en `main.dart` o en un scope local

Si la feature se usa en muchas pantallas, regístralo en `main.dart`. Si solo la usa una pantalla concreta, envuelve esa pantalla con `ChangeNotifierProvider`.

**Ejemplo en `main.dart`**
```dart
void main() {
  final supabaseService = SupabaseService(); // configuración centralizada
  final favoriteRepo = FavoriteRepository(supabaseService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(repository: favoriteRepo),
        ),
        // otros providers...
      ],
      child: MyApp(),
    ),
  );
}
```

**Ejemplo scope-local**
```dart
ChangeNotifierProvider(
  create: (_) => FavoritesProvider(repository: favoriteRepo),
  child: FavoritesScreen(userId: '...'),
);
```

### 6.6 Tests (ubicación `tests/`)

- Tests unitarios de `FavoritesProvider` en `tests/features/favorites/favorites_provider_test.dart`.
- Mockear `FavoriteRepository` usando paquetes como `mockito` o `mocktail`.

**Ejemplo de test (esqueleto)**
```dart
void main() {
  test('loadFavorites should populate items', () async {
    // arrange: mock repository to return list
    // act: call provider.loadFavorites('user')
    // assert: provider.items length > 0
  });
}
```

### 6.7 Buenas prácticas de código y dónde colocarlas

- Lógica de negocio y llamadas a Supabase → `data/repositories/` (no en widgets).
- Modelos → `data/models/` de cada feature o `core/models/` si compartidos.
- Widgets y UI → `presentation/`.
- Estado / notifiers → `providers/` dentro de la feature.
- Servicios globales (e.g. Supabase, Location) → `core/services/`.
- Reutilizables (widgets, constantes, estilos) → `shared/` o `core/widgets`.

---


## 7 Cómo añadir un nuevo Provider / feature (pasos prácticos)

Resumen paso a paso para implementar la funcionalidad `favorites`:

1. Crear rama:
   ```bash
   git checkout -b feature/favorites develop
   ```
2. Crear estructura de carpetas (como en la sección 8).
3. Implementar modelo y repo con métodos mínimos: `getFavoritesForUser`, `addFavorite`, `removeFavorite`.
4. Implementar `FavoritesProvider` y escribir tests unitarios que mockeen `FavoriteRepository`.
5. Crear pantalla `FavoritesScreen` y widgets básicos.
6. Registrar provider en `main.dart` (si es global).
7. Ejecutar `dart analyze` y `flutter test`.
8. Commit y push:
   ```bash
   git add .
   git commit -m "feat(favorites): añadir skeleton de favorites provider y repo"
   git push -u origin feature/favorites
   ```
9. Integrador hace merge a `develop` y elimina rama remota.

