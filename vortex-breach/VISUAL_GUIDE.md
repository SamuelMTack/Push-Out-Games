# VISUAL SETUP GUIDE - ASCII Diagrams

## Scene Hierarchy Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        World.tscn                            │
│                      (Main Scene)                            │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼────────────────────────┐
        │                     │                        │
        ▼                     ▼                        ▼
   ┌─────────┐         ┌──────────┐            ┌──────────┐
   │ Player  │         │  Level   │            │    UI    │
   │CharBody3D        │Generator │            │CanvasLyr │
   └─────────┘         │  Node3D  │            └──────────┘
        │               └──────────┘                  │
        │                     │                       │
   ┌────┴────┐          (Spawns)              ┌──────┴──────┐
   │         │                │                │             │
   ▼         ▼                ▼                ▼             ▼
Camera3D  Collision    ┌──────────┐      Health Bar    Ammo Label
   │                   │Platforms │      Stamina Bar   Gold Label
   │                   │ Enemies  │      Power-up Lbl
   ▼                   │ Hazards  │
Gun (Node3D)          │ Powerups │
   │                   │   Door   │
   ▼                   └──────────┘
Muzzle
```

## Player Scene Structure

```
Player (CharacterBody3D) ◄── Player.gd
│
├── CollisionShape3D ◄── CapsuleShape3D (r:0.5, h:2.0)
│
└── Camera3D (Position: 0, 0.6, 0)
    │
    ├── Gun (Node3D) (Position: 0.3, -0.2, -0.5)
    │   │
    │   ├── MeshInstance3D ◄── BoxMesh (Gun visual)
    │   │
    │   └── Muzzle (Node3D) (Position: 0, 0, -0.3)
    │       └── [Bullets spawn here]
    │
    └── RayCast3D (Target: 0, 0, -100)
```

## UI Scene Structure

```
UI (CanvasLayer) ◄── UI.gd
│
└── MarginContainer
    │
    └── VBoxContainer
        │
        ├── HealthBar (ProgressBar)
        │   └── HealthLabel (Label)
        │
        ├── StaminaBar (ProgressBar)
        │   └── StaminaLabel (Label)
        │
        ├── AmmoLabel (Label)
        │
        ├── GoldLabel (Label)
        │
        └── PowerupLabel (Label)
```

## Enemy Prefab

```
Enemy (CharacterBody3D) ◄── Enemy.gd
│                            [Group: "Enemy"]
├── MeshInstance3D ◄── CapsuleMesh
│
├── CollisionShape3D ◄── CapsuleShape3D
│
└── Area3D (For player detection)
    └── CollisionShape3D
```

## Game Flow Diagram

```
┌─────────────┐
│ Game Start  │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ Level Generation    │
│ • Create floor      │
│ • Spawn platforms   │
│ • Place hazards     │
│ • Spawn enemies     │
│ • Add powerups      │
│ • Create exit door  │
└─────────┬───────────┘
          │
          ▼
    ┌──────────┐
    │ Gameplay │◄──────────┐
    │  Loop    │           │
    └────┬─────┘           │
         │                 │
    ┌────┴────┐            │
    │ Actions │            │
    └────┬────┘            │
         │                 │
    ┌────┴──────────────┐  │
    │ Player can:       │  │
    │ • Move/Jump       │  │
    │ • Sprint          │  │
    │ • Shoot enemies   │  │
    │ • Collect items   │  │
    │ • Avoid hazards   │  │
    │ • Use powerups    │  │
    └────┬──────────────┘  │
         │                 │
    ┌────┴────┐            │
    │ Events  │            │
    └────┬────┘            │
         │                 │
    ┌────┴──────────────┐  │
    │ • Enemy defeated  │  │
    │ • Item collected  │  │
    │ • Damage taken    │  │
    │ • Powerup used    │  │
    └────┬──────────────┘  │
         │                 │
         ▼                 │
    ┌─────────┐            │
    │ UI      │            │
    │ Updated │            │
    └────┬────┘            │
         │                 │
         ▼                 │
    ┌──────────┐           │
    │ Check    │           │
    │ Conditions          │
    └────┬─────┘           │
         │                 │
    ┌────┴─────────────┐   │
    │                  │   │
    ▼                  ▼   │
┌────────┐      ┌──────────┐
│ Death? │      │Door Used?│
└───┬────┘      └────┬─────┘
    │                │
    │Yes             │Yes
    ▼                │
┌────────┐           │
│Restart │           │
│ Game   │           │
└────────┘           │
                     │
                     └──────┘
            (Generate New Level)
```

## Combat Flow

```
Player Shoots                Enemy Attacks
     │                            │
     ▼                            ▼
┌─────────┐                ┌──────────┐
│ Create  │                │ Collision│
│ Bullet  │                │ Detected │
└────┬────┘                └─────┬────┘
     │                            │
     ▼                            ▼
┌─────────┐                ┌──────────┐
│ Bullet  │                │  Player  │
│ Travels │                │Take Dmg  │
└────┬────┘                └─────┬────┘
     │                            │
     ▼                            ▼
┌─────────┐                ┌──────────┐
│ Hit     │                │  Health  │
│ Enemy?  │                │  Update  │
└────┬────┘                └─────┬────┘
     │Yes                         │
     ▼                            ▼
┌─────────┐                ┌──────────┐
│ Enemy   │                │   UI     │
│Take Dmg │                │  Update  │
└────┬────┘                └──────────┘
     │                            
     ▼                            
┌─────────┐                       
│ Dead?   │                       
└────┬────┘                       
     │Yes                         
     ▼                            
┌─────────┐                       
│ Drop    │                       
│ Loot    │                       
└────┬────┘                       
     │                            
     ▼                            
┌─────────┐                       
│ Destroy │                       
│ Enemy   │                       
└─────────┘                       
```

## Pickup System Flow

```
┌──────────────┐
│ Enemy Dies   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Always Drop  │
│    Gold      │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│ Random Check │────►│ 60% Chance   │
└──────┬───────┘ No  └──────────────┘
       │Yes
       ▼
┌──────────────┐
│  Drop Ammo   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Pickups     │
│  Created     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Rotating    │
│  Animation   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Player      │
│  Collision?  │
└──────┬───────┘
       │Yes
       ▼
┌──────────────┐
│  Add to      │
│  Player      │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Destroy     │
│  Pickup      │
└──────────────┘
```

## Power-up System Flow

```
┌──────────────┐
│ Level Gen    │
│ Spawns 3     │
│ Power-ups    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Random Type  │
│ Selected     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Set Color    │
│ & Effect     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Rotating &   │
│ Bobbing      │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Player       │
│ Collects?    │
└──────┬───────┘
       │Yes
       ▼
┌──────────────┐
│ Apply        │
│ Multiplier   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Start 10s    │
│ Timer        │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Update UI    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Timer        │
│ Expires?     │
└──────┬───────┘
       │Yes
       ▼
┌──────────────┐
│ Remove       │
│ Effect       │
└──────────────┘
```

## Level Progression

```
Level 1          Level 2          Level 3
┌──────┐        ┌──────┐        ┌──────┐
│ 10   │───────►│ 12   │───────►│ 14   │
│Enemies        │Enemies        │Enemies
└──┬───┘        └──┬───┘        └──┬───┘
   │               │               │
   ▼               ▼               ▼
┌──────┐        ┌──────┐        ┌──────┐
│ Exit │        │ Exit │        │ Exit │
│ Door │        │ Door │        │ Door │
└──────┘        └──────┘        └──────┘
   │               │               │
   └───────────────┴───────────────┘
              (Continues...)
```

## Collision Layer Setup

```
Layer 1 (Player)          Layer 2 (Enemy)
┌──────────┐             ┌──────────┐
│  Player  │────Hits────►│  Enemy   │
└──────────┘             └──────────┘
     │                        ▲
     │                        │
Collides                   Hit by
   With                    Bullets
     │                        │
     ▼                        │
┌──────────┐             ┌──────────┐
│Platforms │             │  Bullet  │
│ Hazards  │             │ (Layer 3)│
│ Pickups  │             └──────────┘
└──────────┘
(Layer 4,5)
```

## Camera & Gun Positioning

```
Side View:
                  Camera
                    │
         ┌──────────┼──────────┐
         │          ▼          │
         │      ┌──────┐       │
         │      │ Eye  │       │ Player Head
         │      └──────┘       │
         └─────────────────────┘
                    │
                    │ (0, 0.6, 0)
                    │
              ┌─────▼─────┐
              │    Gun    │
              │(0.3,-0.2) │
              │  ┌──┐     │
              │  │  │─────┼──► Muzzle (0,0,-0.3)
              │  └──┘     │
              └───────────┘

Front View:
        
        ┌───────┐
        │ Head  │
        └───┬───┘
            │
        ┌───┴───┐
        │ Body  │
        └───┬───┘
            │
      ┌─────┴─────┐
      │           │
   ┌──┴──┐     ┌──┴──┐
   │Left │     │Right│◄── Gun Here
   │Hand │     │Hand │    (0.3, -0.2, -0.5)
   └─────┘     └─────┘
```

## Debug Console Commands

```
┌──────────────────────────────┐
│    Press F1 for Console      │
└──────────────────────────────┘
           │
           ▼
    ┌──────────┐
    │ Console  │
    │  Active  │
    └─────┬────┘
          │
    Type Command:
          │
    ┌─────┴─────────────────┐
    │                       │
    ▼                       ▼
┌────────┐            ┌──────────┐
│  god   │            │ammo [#]  │
└───┬────┘            └────┬─────┘
    │                      │
    ▼                      ▼
┌────────┐            ┌──────────┐
│Invinci-│            │Set Ammo  │
│bility  │            │  Count   │
└────────┘            └──────────┘

More commands:
• gold [amount]
• health [amount]
• spawn_enemy
• power [type]
• clear_enemies
• next_level
```

## File Dependencies

```
World.tscn
    │
    ├── Requires: Player.gd
    │   └── Requires: Bullet.tscn
    │       └── Requires: Bullet.gd
    │
    ├── Requires: LevelGenerator.gd
    │   ├── Spawns: Platform.tscn (Platform.gd)
    │   ├── Spawns: Enemy.tscn (Enemy.gd)
    │   │   ├── Drops: GoldPickup.tscn (GoldPickup.gd)
    │   │   └── Drops: AmmoPickup.tscn (AmmoPickup.gd)
    │   ├── Spawns: HazardSpike.tscn (HazardSpike.gd)
    │   ├── Spawns: HazardLava.tscn (HazardLava.gd)
    │   ├── Spawns: Powerup.tscn (Powerup.gd)
    │   └── Spawns: Door.tscn (Door.gd)
    │
    └── Requires: UI.tscn (UI.gd)
```

## Setup Checklist

```
□ Create World.tscn
  ├─□ Add Player (CharacterBody3D)
  │  ├─□ Add CollisionShape3D
  │  ├─□ Add Camera3D
  │  │  ├─□ Add Gun (Node3D)
  │  │  │  └─□ Add Muzzle (Node3D)
  │  │  └─□ Add RayCast3D
  │  └─□ Attach Player.gd
  │
  ├─□ Add LevelGenerator (Node3D)
  │  └─□ Attach LevelGenerator.gd
  │
  ├─□ Add DirectionalLight3D
  │
  └─□ Add UI (CanvasLayer)
     └─□ Attach UI.gd

□ Create all prefab scenes
  ├─□ Bullet.tscn
  ├─□ Enemy.tscn
  ├─□ Platform.tscn
  ├─□ HazardSpike.tscn
  ├─□ HazardLava.tscn
  ├─□ Powerup.tscn
  ├─□ Door.tscn
  ├─□ GoldPickup.tscn
  └─□ AmmoPickup.tscn

□ Setup UI scene structure
□ Add Player to "Player" group
□ Test run!
```

---

These diagrams should help visualize the structure! 🎨
