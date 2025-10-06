# Brick Breaker Test (Godot)

This is a small Brick Breaker prototype for Godot 4/5 (project uses config_version=5).

How to run

1. Open Godot and choose "Import" or "Open" and select `project.godot` in this folder.
2. Set `Main.tscn` as the main scene (if needed) and run the project.

Controls

- Left / Right arrow keys to move the paddle (or A / D if mapped).
- Space or Enter ("Accept") to launch the ball.

Files added

- `scenes/Main.tscn` - main scene that instantiates paddle, ball, and bricks.
- `scenes/Paddle.tscn`, `scripts/paddle.gd` - paddle node and movement logic.
- `scenes/Ball.tscn`, `scripts/ball.gd` - ball movement and basic collision handling.
- `scenes/Brick.tscn`, `scripts/brick.gd` - brick nodes that can be destroyed.

Notes

- This is a minimal prototype. Ball and collisions use Area2D signals; you can expand to RigidBody2D or CharacterBody2D for different physics.
- If you see script type warnings in the editor, open the scripts and save them once; Godot's static typing may need small adjustments depending on the engine minor version.
