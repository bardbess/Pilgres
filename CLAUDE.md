# Pilgres

GameMaker typing game (IDE 2026.0.0.16, 60fps, room 1366x768) — *The Pilgrim's Progress*,
City of Destruction. Enemies carry words; typing a word kills the targeted one. 60s timer,
3 health, XP/levels.

All state and logic live on a **single object, `obj_game`**. There are no enemy instances —
enemies are plain structs in an `enemies` array, drawn by hand each frame.

| File | Holds |
|---|---|
| `objects/obj_game/Create_0.gml` | all state; word + phrase lists |
| `objects/obj_game/Step_0.gml` | timer, spawning, enemy movement, targeting, typing input |
| `objects/obj_game/Draw_0.gml` | world: city, rubble, fire, enemies, player |
| `objects/obj_game/Draw_64.gml` | Draw GUI: HUD, typing panel, game over |
| `scripts/spawn_enemy/spawn_enemy.gml` | pushes one enemy struct |

`spawn_enemy()` is a global script but reads `game_width`, `game_height`, `level`, `enemies`
and `enemy_uid_next` from the **calling instance's scope** — it only works from `obj_game`.

Enemies are tracked by a unique `uid`, never by array index — `array_delete` shifts indices.
Look enemies up by `uid`.

## Reading this repo cheaply

- **`Draw_0.gml` (8.7KB) and `Draw_64.gml` (4.4KB) are long, flat drawing code.** Don't read
  them whole. Locate the part you want with `grep -n '^// [A-Z]' <file>`, then `sed -n 'A,Bp'`.
- **`.yy` / `.yyp` / `.resource_order` are IDE-generated single-line JSON.** `grep -o` the key
  you need; never read one whole, and never hand-edit — GameMaker rewrites them on save.
- **`options/` is 13 files and half the repo.** Irrelevant unless the task is a platform export.

## Running it

There is no CLI build on macOS — the game runs from the GameMaker IDE via `Pilgres.yyp`.
Changes here cannot be verified by running them; say that rather than implying a change was tested.
