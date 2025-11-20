# Vortex Breach - 3D FPS Game

A fast-paced 3D first-person shooter with procedurally generated levels, various enemy types, power-ups, and challenging platforming.

## Features

### Core Gameplay
- **First-Person Shooting**: Visible gun model with realistic shooting mechanics
- **Procedural Level Generation**: Each level is randomly generated with unique layouts
- **Verticality & Platforming**: Jump across platforms at various heights
- **Enemy Variety**: 4 different enemy types with unique behaviors
  - Basic: Balanced stats, red color
  - Fast: Quick but fragile, orange color
  - Tank: High health and damage, dark red color, larger
  - Sniper: Keeps distance, purple color, tall and thin

### Combat System
- **Ammo Management**: Limited ammo that affects damage and range when depleted
- **Multiple Enemy Types**: Enemies with different AI behaviors and appearances
- **Gold & Loot**: Enemies drop gold and ammunition
- **Damage Feedback**: Visual feedback on hit

### Power-Up System
Power-ups last 10 seconds and provide:
- **Speed Boost** (Cyan): 50% faster movement
- **Jump Enhancement** (Green): 50% higher jumps
- **Damage Amplifier** (Red): 2x bullet damage
- **Accuracy Boost** (Yellow): Tighter bullet spread
- **Bullet Velocity** (Blue): 50% faster bullets
- **Fire Rate** (Magenta): 2x faster shooting

### Level Hazards
- **Spikes**: Deal 25 damage on contact
- **Lava Pools**: Deal 15 damage every 0.5 seconds while standing in them

### Player Mechanics
- **Health System**: 100 HP, regenerate by avoiding damage
- **Stamina System**: Sprint for limited duration, regenerates when not sprinting
- **Movement**: WASD movement with sprint (Shift)
- **Jumping**: Space bar with enhanced platforming
- **Mouse Look**: Full 360° camera control

### Progression
- **Level Portal**: Walk through the golden door to generate a new level
- **Increasing Difficulty**: More enemies spawn each level
- **Gold Collection**: Track your wealth across levels

## Controls

- **W/A/S/D**: Movement
- **Mouse**: Look around
- **Left Click**: Shoot
- **Space**: Jump
- **Shift**: Sprint (uses stamina)
- **ESC**: Show mouse cursor

## UI Elements

The HUD displays:
- **Health Bar**: Green (60%+), Yellow (30-60%), Red (<30%)
- **Stamina Bar**: Shows sprint capacity
- **Ammo Counter**: Current/Max ammunition (turns red when empty)
- **Gold Counter**: Total gold collected
- **Active Power-up**: Current power-up and remaining time

## Setup Instructions

### In Godot Editor:

1. **Create the Scene Structure**:
   ```
   World (Node3D)
   ├── Player (CharacterBody3D) [Attach Player.gd]
   │   ├── CollisionShape3D (CapsuleShape3D)
   │   └── Camera3D
   │       ├── Gun (Node3D)
   │       │   └── Muzzle (Node3D)
   │       └── RayCast3D
   ├── LevelGenerator (Node3D) [Attach LevelGenerator.gd]
   ├── DirectionalLight3D
   └── UI (CanvasLayer) [Attach UI.gd]
   ```

2. **Create Individual Scenes**:
   - **Bullet.tscn**: Area3D with SphereShape3D collision
   - **Enemy.tscn**: CharacterBody3D with CapsuleShape3D and MeshInstance3D
   - **Platform.tscn**: StaticBody3D with BoxShape3D and MeshInstance3D
   - **HazardSpike.tscn**: Area3D (script creates visuals)
   - **HazardLava.tscn**: Area3D (script creates visuals)
   - **Powerup.tscn**: Area3D with MeshInstance3D
   - **Door.tscn**: Area3D (script creates visuals)
   - **GoldPickup.tscn**: Area3D (script creates visuals)
   - **AmmoPickup.tscn**: Area3D (script creates visuals)

3. **Configure Player**:
   - Add Player to "Player" group
   - Set Camera3D as child of Player
   - Position Gun model under Camera
   - Set Muzzle position at gun barrel tip

4. **Create UI Layout** in UI scene:
   ```
   UI (CanvasLayer)
   └── MarginContainer
       └── VBoxContainer
           ├── HealthBar (ProgressBar)
           │   └── HealthLabel (Label)
           ├── StaminaBar (ProgressBar)
           │   └── StaminaLabel (Label)
           ├── AmmoLabel (Label)
           ├── GoldLabel (Label)
           └── PowerupLabel (Label)
   ```

5. **Set Input Mappings**: Already configured in project.godot

## Game Design Highlights

### Balanced Gameplay Loop
1. Start in a new procedural level
2. Fight enemies to collect gold and ammo
3. Find and use power-ups strategically
4. Navigate platforming challenges and avoid hazards
5. Reach the exit door to progress to harder levels

### Risk/Reward Systems
- **Low Ammo Risk**: Running out of ammo severely weakens your shots
- **Stamina Management**: Sprint to escape but manage stamina carefully
- **Hazard Navigation**: Platforms reward skilled movement, hazards punish mistakes
- **Enemy Variety**: Different strategies needed for different enemy types

## Additional Feature Suggestions

Here are some enhancements you could add:

1. **Weapon System**:
   - Multiple guns (pistol, shotgun, rifle)
   - Weapon switching
   - Melee attack option

2. **Shop System**:
   - Spend gold between levels
   - Buy permanent upgrades
   - Purchase health/ammo

3. **Score System**:
   - Points for kills, combos
   - Leaderboard
   - Time attack mode

4. **Environmental Interactions**:
   - Exploding barrels
   - Destructible walls
   - Moving platforms

5. **Boss Battles**:
   - Special boss enemy every 5 levels
   - Unique attack patterns
   - Better rewards

6. **Visual Polish**:
   - Particle effects for shooting
   - Blood/impact decals
   - Screen shake on damage
   - Post-processing effects

7. **Audio**:
   - Gun sound effects
   - Enemy sounds
   - Background music
   - Footstep sounds

8. **Abilities**:
   - Dash/dodge ability
   - Grenade throwable
   - Slow-motion power-up
   - Shield ability

9. **Multiplayer** (Advanced):
   - Co-op mode
   - Versus mode
   - Wave survival mode

10. **Progression Meta-Game**:
    - Unlockable characters
    - Permanent upgrades
    - Achievement system
    - Daily challenges

## Technical Notes

- Built for Godot 4.x
- Uses GDScript exclusively
- Physics set to 20.0 gravity for responsive platforming
- Procedural generation uses randomization for replayability
- Enemy AI uses simple chase behavior with type-specific variations

## Performance Tips

- The level generator spawns objects in batches
- Enemies are pooled via instantiation
- Bullets auto-delete after max range
- Pickups have simple physics

## Credits

Game Name: **Vortex Breach**
Created with Godot Engine 4.x
All code in GDScript

---

Enjoy the game! May your aim be true and your stamina never run out! 🎮
