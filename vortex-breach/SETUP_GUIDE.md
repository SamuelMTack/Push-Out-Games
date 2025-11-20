# SETUP GUIDE - Scene Structure Details

## Complete Scene Tree Structures

### World.tscn (Main Game Scene)
```
World (Node3D)
├── Player (CharacterBody3D) - Script: Player.gd
│   ├── CollisionShape3D
│   │   └── Shape: CapsuleShape3D (radius: 0.5, height: 2.0)
│   └── Camera3D
│       ├── Position: (0, 0.6, 0)
│       ├── Gun (Node3D)
│       │   ├── Position: (0.3, -0.2, -0.5)
│       │   ├── MeshInstance3D (for visual gun)
│       │   │   └── Mesh: BoxMesh (size: 0.1, 0.1, 0.5)
│       │   └── Muzzle (Node3D)
│       │       └── Position: (0, 0, -0.3)
│       └── RayCast3D
│           ├── Target Position: (0, 0, -100)
│           └── Enabled: true
│
├── LevelGenerator (Node3D) - Script: LevelGenerator.gd
│
├── DirectionalLight3D
│   ├── Transform: Rotation (-45, -45, 0)
│   └── Shadow Enabled: true
│
└── UI (CanvasLayer) - Script: UI.gd
```

### UI.tscn (User Interface)
```
UI (CanvasLayer)
└── MarginContainer
    ├── Margin Left: 20
    ├── Margin Top: 20
    ├── Margin Right: 20
    ├── Margin Bottom: 20
    └── VBoxContainer
        ├── HealthBar (ProgressBar)
        │   ├── Min Value: 0
        │   ├── Max Value: 100
        │   ├── Value: 100
        │   ├── Size Flags Horizontal: Expand Fill
        │   ├── Custom Minimum Size: (300, 30)
        │   └── HealthLabel (Label)
        │       ├── Text: "Health: 100/100"
        │       ├── Horizontal Alignment: Center
        │       └── Vertical Alignment: Center
        │
        ├── StaminaBar (ProgressBar)
        │   ├── Min Value: 0
        │   ├── Max Value: 100
        │   ├── Value: 100
        │   ├── Size Flags Horizontal: Expand Fill
        │   ├── Custom Minimum Size: (300, 20)
        │   └── StaminaLabel (Label)
        │       ├── Text: "Stamina: 100/100"
        │       ├── Horizontal Alignment: Center
        │       └── Vertical Alignment: Center
        │
        ├── AmmoLabel (Label)
        │   ├── Text: "Ammo: 100/100"
        │   └── Theme: Font Size: 24
        │
        ├── GoldLabel (Label)
        │   ├── Text: "Gold: 0"
        │   └── Theme: Font Size: 24
        │
        └── PowerupLabel (Label)
            ├── Text: "Powerup: None"
            └── Theme: Font Size: 20
```

### Bullet.tscn
```
Bullet (Area3D) - Script: Bullet.gd
├── MeshInstance3D
│   └── Mesh: SphereMesh (radius: 0.1)
└── CollisionShape3D
    └── Shape: SphereShape3D (radius: 0.1)
```

### Enemy.tscn
```
Enemy (CharacterBody3D) - Script: Enemy.gd
├── Groups: ["Enemy"]
├── MeshInstance3D
│   └── Mesh: CapsuleMesh (radius: 0.5, height: 2.0)
├── CollisionShape3D
│   └── Shape: CapsuleShape3D (radius: 0.5, height: 2.0)
└── Area3D (for player collision detection)
    ├── Collision Layer: 2
    ├── Collision Mask: 1
    └── CollisionShape3D
        └── Shape: CapsuleShape3D (radius: 0.6, height: 2.1)
```

### Platform.tscn
```
Platform (StaticBody3D) - Script: Platform.gd
├── MeshInstance3D
│   └── Mesh: BoxMesh (size: 1, 0.5, 1)
└── CollisionShape3D
    └── Shape: BoxShape3D (size: 1, 0.5, 1)
```

### HazardSpike.tscn
```
HazardSpike (Area3D) - Script: HazardSpike.gd
└── (Children created by script)
```

### HazardLava.tscn
```
HazardLava (Area3D) - Script: HazardLava.gd
└── (Children created by script)
```

### Powerup.tscn
```
Powerup (Area3D) - Script: Powerup.gd
└── MeshInstance3D
    └── (Configured by script)
```

### Door.tscn
```
Door (Area3D) - Script: Door.gd
└── (Children created by script)
```

### GoldPickup.tscn
```
GoldPickup (Area3D) - Script: GoldPickup.gd
└── (Children created by script)
```

### AmmoPickup.tscn
```
AmmoPickup (Area3D) - Script: AmmoPickup.gd
└── (Children created by script)
```

## Player Group Setup
**IMPORTANT**: Add the Player node to the "Player" group:
1. Select Player node
2. Go to Node tab (next to Inspector)
3. Click "Groups"
4. Type "Player"
5. Click "Add"

## Collision Layers Setup

### Layer Configuration:
- **Layer 1**: Player
- **Layer 2**: Enemies
- **Layer 3**: Bullets
- **Layer 4**: Environment (platforms, hazards)
- **Layer 5**: Pickups

### Node Configurations:

**Player (CharacterBody3D)**:
- Collision Layer: 1
- Collision Mask: 2, 4, 5

**Enemy (CharacterBody3D)**:
- Collision Layer: 2
- Collision Mask: 1, 4

**Bullet (Area3D)**:
- Collision Layer: 3
- Collision Mask: 2, 4

**Platforms (StaticBody3D)**:
- Collision Layer: 4
- Collision Mask: 0

**Hazards (Area3D)**:
- Collision Layer: 4
- Collision Mask: 1

**Pickups (Area3D)**:
- Collision Layer: 5
- Collision Mask: 1

## Quick Start Steps

1. **Create New Project** in Godot 4.x

2. **Copy all .gd files** to the project root

3. **Replace project.godot** with the provided one

4. **Create World Scene**:
   - New Scene → 3D Scene
   - Rename root to "World"
   - Add nodes following structure above
   - Save as World.tscn

5. **Create Simple Scenes**:
   - Create each scene (Bullet, Enemy, Platform, etc.)
   - Add basic structure as shown
   - Attach corresponding scripts
   - Save with correct names

6. **Setup UI**:
   - Create UI scene following structure
   - Attach UI.gd script
   - Configure labels and progress bars
   - Save as UI.tscn

7. **Instance UI in World**:
   - Open World.tscn
   - Right-click World node
   - "Instance Child Scene"
   - Select UI.tscn

8. **Configure Player**:
   - Add to "Player" group
   - Attach Player.gd
   - Setup camera and gun positions
   - Add raycast

9. **Test Run**:
   - Set World.tscn as main scene
   - Press F5 to run
   - Should spawn in level with gun visible

## Common Issues & Solutions

### Issue: Player falls through floor
**Solution**: Check collision layers and masks on Player and platforms

### Issue: Can't shoot
**Solution**: Ensure Bullet.tscn exists and is saved in res://

### Issue: No enemies spawn
**Solution**: Check Enemy.tscn exists and enemy_scene preload path is correct

### Issue: UI doesn't appear
**Solution**: Make sure UI is instantiated in World scene

### Issue: Mouse not captured
**Solution**: Click on the game window after starting

### Issue: No level generated
**Solution**: Check LevelGenerator.gd is attached and all preload paths are correct

## Performance Notes

- Start with fewer enemies/platforms if performance is poor
- Adjust LEVEL_SIZE, PLATFORM_COUNT, ENEMY_COUNT in LevelGenerator.gd
- Enable shadow cascades on DirectionalLight3D for better performance

## Testing Checklist

- [ ] Player can move and look around
- [ ] Player can jump
- [ ] Player can sprint (stamina decreases)
- [ ] Shooting creates bullets
- [ ] Bullets hit and damage enemies
- [ ] Enemies chase player
- [ ] Enemies deal damage on contact
- [ ] Health UI updates
- [ ] Stamina UI updates
- [ ] Ammo UI updates
- [ ] Gold UI updates when collecting
- [ ] Power-ups can be picked up
- [ ] Power-up UI shows active power-up
- [ ] Door generates new level
- [ ] Hazards deal damage
- [ ] Platforms are jumpable
- [ ] Game over on death

## Next Steps

Once basic functionality works:
1. Add particle effects for muzzle flash
2. Improve gun model visuals
3. Add sound effects
4. Create more complex level layouts
5. Add more enemy types
6. Implement suggested features from README
