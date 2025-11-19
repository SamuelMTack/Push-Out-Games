# VORTEX BREACH - Quick Reference Guide

## Game Systems Overview

### 1. Player System (Player.gd)
**Responsibilities:**
- Movement (WASD) with sprint mechanics
- Camera control (mouse look)
- Shooting mechanics with ammo management
- Health and damage system
- Stamina management for sprinting
- Power-up application and tracking
- Gold collection
- UI updates

**Key Variables:**
- `health`: Current player health (100 max)
- `stamina`: Current stamina (100 max)
- `current_ammo`: Bullets remaining
- `gold`: Collected currency
- `active_powerup`: Current active power-up name
- Various multipliers for power-ups

**Key Methods:**
- `shoot()`: Creates and fires bullets
- `take_damage(damage)`: Reduces health
- `apply_powerup(type, duration)`: Activates power-up effect
- `add_gold(amount)`: Adds currency
- `add_ammo(amount)`: Refills ammunition

### 2. Combat System

#### Bullet (Bullet.gd)
- Travels in straight line with given direction
- Has speed, damage, and range properties
- Auto-destroys after traveling max range
- Calls `take_damage()` on hit enemies

#### Enemy (Enemy.gd)
**4 Enemy Types:**
1. **Basic** (Red): Balanced - 30 HP, 3 speed, 10 damage
2. **Fast** (Orange): Quick - 20 HP, 6 speed, 5 damage
3. **Tank** (Dark Red): Slow tank - 80 HP, 1.5 speed, 20 damage
4. **Sniper** (Purple): Ranged - 15 HP, 2 speed, 15 damage (keeps distance)

**AI Behavior:**
- Chases player constantly
- Deals damage on collision
- Different movement patterns per type
- Drops gold and ammo on death

### 3. Level Generation (LevelGenerator.gd)

**Generates:**
- Main floor (50x50 units)
- 30 platforms at varying heights (2-15 units)
- 15 hazards (spikes or lava)
- 10+ enemies (scales with level)
- 3 power-ups
- 1 exit door

**Difficulty Scaling:**
- Enemy count increases by 2 per level
- Platform positions randomized each level
- Level number tracked in `current_level`

### 4. Hazards

#### Spikes (HazardSpike.gd)
- Instant 25 damage on contact
- Static cone-shaped visual
- Dark gray color

#### Lava (HazardLava.gd)
- 15 damage every 0.5 seconds
- Continuous damage while in contact
- Orange-red glowing appearance
- 3x3 unit pools

### 5. Power-Up System (Powerup.gd)

**All power-ups last 10 seconds:**

| Power-up | Color | Effect |
|----------|-------|--------|
| Speed | Cyan | 1.5x movement speed |
| Jump | Green | 1.5x jump height |
| Damage | Red | 2x bullet damage |
| Spread | Yellow | Tighter bullet spread |
| Bullet Speed | Blue | 1.5x bullet velocity |
| Fire Rate | Magenta | 2x shooting speed |

**Visual Features:**
- Rotating spheres
- Bobbing animation
- Glowing emission
- Auto-collected on contact

### 6. Pickups

#### Gold (GoldPickup.gd)
- Yellow rotating coin
- Default value: 5 gold
- Drops from all enemies
- Automatically collected

#### Ammo (AmmoPickup.gd)
- Dark green box with yellow stripe
- Restores 20 bullets
- 60% drop chance from enemies
- Stackable to 100 max

### 7. Level Progression (Door.gd)
- Golden glowing door with frame
- Pulsing scale animation
- Spawns at level edge
- Triggers level regeneration
- Resets player position to spawn

### 8. User Interface (UI.gd)

**HUD Elements:**
1. **Health Bar**
   - Green (>60%), Yellow (30-60%), Red (<30%)
   - Shows current/max values

2. **Stamina Bar**
   - Depletes during sprint
   - Regenerates when not sprinting

3. **Ammo Counter**
   - Shows current/max (100)
   - Red when empty
   - Yellow when low (<30)

4. **Gold Display**
   - Running total
   - Never decreases

5. **Power-up Indicator**
   - Shows active power-up name
   - Countdown timer
   - Cyan color when active

### 9. Debug Console (DebugConsole.gd)

**Press F1 to activate**

**Available Commands:**
```
god                    - Toggle invincibility
ammo [amount]         - Set ammunition
gold [amount]         - Add gold
health [amount]       - Set health
spawn_enemy           - Spawn enemy nearby
power [type]          - Apply power-up
clear_enemies         - Remove all enemies
next_level           - Generate new level
```

**Example Usage:**
- `ammo 999` - Set ammo to 999
- `power speed` - Get speed boost
- `god` - Enable/disable god mode

## Game Flow

### Level Loop
1. Level generates with platforms, hazards, enemies, power-ups
2. Player fights enemies, collects resources
3. Player navigates platforms and avoids hazards
4. Player finds and enters exit door
5. New level generates (difficulty +1)
6. Loop continues

### Combat Loop
1. Player shoots enemies (consumes ammo)
2. Enemies chase and attack player
3. Enemies drop gold and ammo
4. Player collects resources
5. Player manages ammo carefully
6. Low ammo = weak shots

### Survival Loop
1. Player takes damage from enemies/hazards
2. Player health decreases
3. If health = 0, game restarts
4. Player must balance aggression with safety

## Tips for Players

### Combat
- **Conserve Ammo**: Low ammo severely weakens shots
- **Prioritize Targets**: Kill fast enemies first
- **Keep Moving**: Enemies can't hit moving targets easily
- **Use Height**: Jump on platforms to create distance

### Movement
- **Sprint Wisely**: Stamina is limited
- **Platform Carefully**: Hazards are deadly
- **Use Verticality**: High platforms = safety
- **Don't Sprint Constantly**: Save for emergencies

### Power-ups
- **Speed**: Best for escaping/repositioning
- **Jump**: Navigate high platforms easily
- **Damage**: Clear enemies quickly
- **Fire Rate**: Maximize DPS when surrounded

### Strategy
- **Circle Strafe**: Move around while shooting
- **Retreat When Low**: Find safe platform
- **Ammo Management**: Collect ammo boxes regularly
- **Plan Route to Door**: Spot exit early

## Performance Tuning

### In LevelGenerator.gd, adjust:
```gdscript
const LEVEL_SIZE = 50        # Smaller = better FPS
const PLATFORM_COUNT = 30    # Reduce if laggy
const ENEMY_COUNT = 10       # Fewer enemies = smoother
const HAZARD_COUNT = 15      # Visual clutter
```

### Graphics Settings:
- Disable shadows on DirectionalLight3D
- Reduce MSAA in project settings
- Lower resolution

## Modding & Extension Ideas

### Easy Additions:
1. **New Enemy Type**: Duplicate Enemy.gd, add new type enum
2. **New Hazard**: Copy HazardSpike.gd, change damage/visuals
3. **New Power-up**: Add enum to Powerup.gd, add case to apply_powerup()
4. **Adjust Difficulty**: Change enemy stats in Enemy.gd

### Medium Additions:
1. **Weapon System**: Create Weapon.gd, attach to gun node
2. **Shop Between Levels**: Create Shop.gd, trigger before level gen
3. **Boss Encounters**: Create Boss.gd, spawn every 5 levels
4. **Save System**: Use FileAccess to save gold/progress

### Advanced Additions:
1. **Multiplayer**: Implement Godot networking
2. **Custom Level Editor**: Create editor scene
3. **Procedural Weapons**: Generate guns with random stats
4. **Skill Tree**: Persistent upgrades between runs

## Common Modifications

### Make Game Easier:
- Increase `max_health` in Player.gd
- Increase `stamina_regen_rate` in Player.gd
- Decrease enemy damage in Enemy.gd
- Increase ammo drops

### Make Game Harder:
- Decrease `max_health` in Player.gd
- Increase enemy count per level
- Reduce ammo drop chance
- Add more hazards

### Adjust Speed:
- Change `WALK_SPEED` in Player.gd
- Change `SPRINT_MULTIPLIER` in Player.gd
- Modify enemy `move_speed` in Enemy.gd

### Modify Weapons:
- Change `base_bullet_damage` in Player.gd
- Change `base_fire_rate` in Player.gd
- Change `base_bullet_speed` in Player.gd
- Change `base_bullet_spread` in Player.gd

## Troubleshooting

### Enemies Not Spawning
- Check Enemy.tscn exists
- Verify preload path in LevelGenerator.gd
- Ensure Enemy has collision setup

### Can't Collect Items
- Check collision layers
- Verify Area3D signals connected
- Ensure Player in "Player" group

### UI Not Updating
- Verify UI script attached
- Check node paths in UI.gd
- Ensure update_ui() is called

### Poor Performance
- Reduce LEVEL_SIZE, PLATFORM_COUNT, ENEMY_COUNT
- Disable shadows
- Lower enemy AI update rate

### Bullets Not Hitting
- Check bullet collision mask includes enemies (layer 2)
- Verify Enemy collision layer is 2
- Check Bullet.tscn has collision shape

## File Structure Summary

```
res://
├── Player.gd                 # Player controller
├── Bullet.gd                 # Bullet projectile
├── Enemy.gd                  # Enemy AI and types
├── LevelGenerator.gd         # Procedural generation
├── Platform.gd               # Platform objects
├── HazardSpike.gd           # Spike hazard
├── HazardLava.gd            # Lava hazard
├── Powerup.gd               # Power-up system
├── Door.gd                  # Level exit
├── GoldPickup.gd            # Gold drops
├── AmmoPickup.gd            # Ammo drops
├── UI.gd                    # HUD interface
├── DebugConsole.gd          # Debug/cheat system
├── project.godot            # Project settings
├── World.tscn               # Main scene
├── Bullet.tscn              # Bullet scene
├── Enemy.tscn               # Enemy scene
├── Platform.tscn            # Platform scene
├── HazardSpike.tscn         # Spike scene
├── HazardLava.tscn          # Lava scene
├── Powerup.tscn             # Power-up scene
├── Door.tscn                # Door scene
├── GoldPickup.tscn          # Gold scene
├── AmmoPickup.tscn          # Ammo scene
└── UI.tscn                  # UI scene
```

## Next Steps After Setup

1. **Test Basic Movement**: WASD, mouse, jump
2. **Test Combat**: Shoot, damage enemies
3. **Test Pickups**: Collect gold and ammo
4. **Test Hazards**: Take damage from spikes/lava
5. **Test Power-ups**: Pick up and verify effects
6. **Test Door**: Enter door, see new level
7. **Play Full Loop**: Complete several levels

## Credits & License

**Vortex Breach**
- Engine: Godot 4.x
- Language: GDScript
- Genre: FPS / Roguelike
- Created: 2024

Feel free to modify, extend, and share!

---

**Good luck, and may your bullets fly true!** 🎯
