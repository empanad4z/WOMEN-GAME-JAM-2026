# Women Game Jam 2026 - El Último Recuerdo

Plataformas de acción 2D en Godot 4.7.2 (GDScript), exportado a web para itch.io.

## Configuración del proyecto

- Renderizador: Compatibilidad.
- Escena principal: `scenes/main.tscn`.
- Export: preset "Web" -> `build/web/index.html`. Para subir, comprimir el contenido de `build/web/` en un ZIP.

## Input

| Acción | Tecla |
|---|---|
| `move_left` | Flecha izquierda |
| `move_right` | Flecha derecha |
| `jump` | Espacio |

Usar siempre las acciones (`Input.is_action_pressed("jump")`), no teclas fijas.

## Capas de física 2D

| Capa | Nombre | Uso |
|---|---|---|
| 1 | - | Cuerpos y mundo |
| 2 | `player_hitbox` | Hitbox del jugador (espada) |
| 3 | `enemy_hitbox` | Hitbox de enemigos (cuerpo) |

Configuración de áreas:

| Área | Layer | Mask |
|---|---|---|
| Hitbox del jugador | 2 | — |
| Hitbox de enemigo | 3 | — |
| Hurtbox del jugador | — | 3 |
| Hurtbox de enemigo | — | 2 |

## Sistema de vida y golpes

- `HealthComponent` (`scripts/health_component.gd`): vida de una entidad. Emite `health_changed(current, max_health)` y `died`.
- `Hitbox` (`scripts/hitbox.gd`): área que hace daño (`damage`).
- `Hurtbox` (`scripts/hurtbox.gd`): área que recibe el golpe. Asignar su `HealthComponent` en el Inspector.

Prueba: `scenes/tests/test_combat.tscn` (F6).

## Carpetas

- `scenes/`: escenas (`.tscn`). Pruebas en `scenes/tests/`.
- `scripts/`: scripts (`.gd`). Pruebas en `scripts/tests/`.
- `ui/`: interfaz.
- `assets/sprites/`, `assets/audio/`, `assets/fonts/`.

## Convenciones

- Indentación con tabs.
- `snake_case` en variables, funciones, archivos y señales; `PascalCase` en `class_name` y nodos; `CONSTANT_CASE` en constantes.
- Commitear siempre los `.uid` junto a su script.

## Git

- Una rama por feature y PR a `main`. No pushear directo a `main`.
- `pull` antes de empezar a trabajar.
- Una sola persona edita una escena (`.tscn`) a la vez.
