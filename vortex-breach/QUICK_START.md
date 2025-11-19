# ⚡ QUICK START CHECKLIST

**Goal: Get Vortex Breach running in minimum time!**

## ✅ Phase 1: Project Setup (5 minutes)

### Step 1: Create Godot Project
- [ ] Open Godot 4.2+
- [ ] Create new project named "VortexBreach"
- [ ] Choose location for project
- [ ] Select "Forward+" renderer (default)
- [ ] Create & Edit

### Step 2: Copy Files
- [ ] Copy all .gd files to project root folder
- [ ] Replace project.godot with provided version

**Files to copy:**
```
✓ Player.gd
✓ Bullet.gd
✓ Enemy.gd
✓ LevelGenerator.gd
✓ Platform.gd
✓ HazardSpike.gd
✓ HazardLava.gd
✓ Powerup.gd
✓ Door.gd
✓ GoldPickup.gd
✓ AmmoPickup.gd
✓ UI.gd
✓ DebugConsole.gd
✓ project.godot
```

## ✅ Phase 2: Create Scenes (20 minutes)

### Scene 1: World.tscn (Main Scene)
- [ ] New Scene → 3D Scene
- [ ] Rename root "Node3D" to "World"
- [ ] Add Player (CharacterBody3D)
  - [ ] Add CollisionShape3D → CapsuleShape3D (r:0.5, h:2.0)
  - [ ] Add Camera3D (position: 0, 0.6, 0)
    - [ ] Add Gun (Node3D) (position: 0.3, -0.2, -0.5)
      - [ ] Add MeshInstance3D → BoxMesh (0.1, 0.1, 0.5)
      - [ ] Add Muzzle (Node3D) (position: 0, 0, -0.3)
    - [ ] Add RayCast3D (target: 0, 0, -100, enabled: true)
  - [ ] Attach Player.gd script
  - [ ] **IMPORTANT**: Add Player to "Player" group
- [ ] Add LevelGenerator (Node3D)
  - [ ] Attach LevelGenerator.gd script
- [ ] Add DirectionalLight3D
  - [ ] Rotate -45° on X and Y axes
  - [ ] Enable shadows
- [ ] Save as World.tscn
- [ ] Set as main scene (F6 → set as main scene)

### Scene 2: Bullet.tscn
- [ ] New Scene → 3D Scene → Area3D
- [ ] Add MeshInstance3D → SphereMesh (radius: 0.1)
- [ ] Add CollisionShape3D → SphereShape3D (radius: 0.1)
- [ ] Attach Bullet.gd
- [ ] Set Collision Layer: 3
- [ ] Set Collision Mask: 2, 4
- [ ] Save as Bullet.tscn

### Scene 3: Enemy.tscn
- [ ] New Scene → 3D Scene → CharacterBody3D
- [ ] Add MeshInstance3D → CapsuleMesh (r:0.5, h:2.0)
- [ ] Add CollisionShape3D → CapsuleShape3D (r:0.5, h:2.0)
- [ ] Add Area3D (for player detection)
  - [ ] Add CollisionShape3D → CapsuleShape3D (r:0.6, h:2.1)
- [ ] Attach Enemy.gd
- [ ] Add to "Enemy" group
- [ ] Set Collision Layer: 2
- [ ] Set Collision Mask: 1, 4
- [ ] Save as Enemy.tscn

### Scene 4: Platform.tscn
- [ ] New Scene → 3D Scene → StaticBody3D
- [ ] Add MeshInstance3D → BoxMesh (size: 1, 0.5, 1)
- [ ] Add CollisionShape3D → BoxShape3D (size: 1, 0.5, 1)
- [ ] Attach Platform.gd
- [ ] Set Collision Layer: 4
- [ ] Save as Platform.tscn

### Scene 5-11: Simple Prefabs (10 min total)
For each of the following, create Area3D and attach script:
- [ ] HazardSpike.tscn → Attach HazardSpike.gd
- [ ] HazardLava.tscn → Attach HazardLava.gd
- [ ] Powerup.tscn → Add MeshInstance3D, attach Powerup.gd
- [ ] Door.tscn → Attach Door.gd
- [ ] GoldPickup.tscn → Attach GoldPickup.gd
- [ ] AmmoPickup.tscn → Attach AmmoPickup.gd

*Note: These scripts create their own visuals, so just attach the script!*

### Scene 12: UI.tscn
- [ ] New Scene → User Interface → CanvasLayer
- [ ] Add MarginContainer
  - [ ] Set margins: 20 all sides
  - [ ] Add VBoxContainer
    - [ ] Add ProgressBar (name: HealthBar)
      - [ ] Min: 0, Max: 100, Value: 100
      - [ ] Custom Min Size: 300, 30
      - [ ] Add Label (name: HealthLabel, text: "Health: 100/100")
    - [ ] Add ProgressBar (name: StaminaBar)
      - [ ] Min: 0, Max: 100, Value: 100
      - [ ] Custom Min Size: 300, 20
      - [ ] Add Label (name: StaminaLabel, text: "Stamina: 100/100")
    - [ ] Add Label (name: AmmoLabel, text: "Ammo: 100/100", font size: 24)
    - [ ] Add Label (name: GoldLabel, text: "Gold: 0", font size: 24)
    - [ ] Add Label (name: PowerupLabel, text: "Powerup: None", font size: 20)
- [ ] Attach UI.gd
- [ ] Save as UI.tscn

### Final Step: Add UI to World
- [ ] Open World.tscn
- [ ] Right-click World node
- [ ] "Instantiate Child Scene"
- [ ] Select UI.tscn
- [ ] Save World.tscn

## ✅ Phase 3: First Test Run (2 minutes)

### Pre-Flight Check
- [ ] All .gd files in project folder
- [ ] World.tscn set as main scene
- [ ] Player in "Player" group
- [ ] All 11 scene files created

### Launch!
- [ ] Press F5 (or click Play button)
- [ ] Click on game window to capture mouse

### Test Checklist
- [ ] Can move with WASD
- [ ] Can look around with mouse
- [ ] Can jump with Space
- [ ] Floor is visible
- [ ] Platforms appear
- [ ] Enemies spawn
- [ ] Can see gun model
- [ ] UI is visible

### If Something Breaks:
**No floor/platforms?**
→ Check LevelGenerator.gd is attached to LevelGenerator node

**Can't move?**
→ Check Player.gd is attached to Player node
→ Check Player has CollisionShape3D

**Can't see anything?**
→ Check Camera3D is child of Player
→ Add DirectionalLight3D if missing

**Errors in console?**
→ Check all .tscn files exist (Bullet, Enemy, Platform, etc.)
→ Verify preload paths in scripts match file names

## ✅ Phase 4: Full Feature Test (5 minutes)

### Combat Test
- [ ] Left-click to shoot
- [ ] Bullets appear and travel
- [ ] Enemies take damage (flash white)
- [ ] Enemies die when health depletes
- [ ] Gold drops appear
- [ ] Ammo drops appear (sometimes)

### Pickup Test
- [ ] Walk over gold - counter increases
- [ ] Walk over ammo - ammo count increases
- [ ] Walk over power-up - effect applies, UI updates

### Movement Test
- [ ] Hold Shift - sprint (stamina decreases)
- [ ] Release Shift - stamina regenerates
- [ ] Jump onto platforms
- [ ] Can navigate vertical spaces

### Hazard Test
- [ ] Touch spikes - take damage
- [ ] Touch lava - take continuous damage
- [ ] Health bar updates

### Door Test
- [ ] Find golden door
- [ ] Walk through it
- [ ] New level generates
- [ ] More enemies spawn

## ✅ Phase 5: Debug Console Test (1 minute)

- [ ] Press F1
- [ ] See console message in output
- [ ] Try: "god" - enable god mode
- [ ] Try: "ammo 999" - set ammo
- [ ] Try: "spawn_enemy" - create enemy
- [ ] Try: "next_level" - new level

## 🎉 SUCCESS CRITERIA

You've successfully set up Vortex Breach if:
- ✅ Game runs without errors
- ✅ Can move and shoot
- ✅ Enemies appear and can be killed
- ✅ Pickups can be collected
- ✅ UI updates correctly
- ✅ New levels generate
- ✅ Debug console works

## ⚠️ Common First-Time Issues

### Issue: "Invalid get index 'global_transform'"
**Fix**: Camera3D must be child of Player, not sibling

### Issue: Bullets don't hit enemies
**Fix**: Check collision layers
- Bullet: Layer 3, Mask 2,4
- Enemy: Layer 2, Mask 1,4

### Issue: Player falls through floor
**Fix**: Floor is generated by LevelGenerator - ensure script attached

### Issue: Can't see gun
**Fix**: Gun should be at position (0.3, -0.2, -0.5) relative to Camera3D

### Issue: Enemies don't spawn
**Fix**: Verify Enemy.tscn exists and is saved properly

### Issue: UI doesn't appear
**Fix**: UI.tscn must be instanced as child of World node

## 📊 Estimated Time Breakdown

| Phase | Time | Difficulty |
|-------|------|------------|
| Project Setup | 5 min | Easy |
| Main Scene (World) | 10 min | Medium |
| Prefab Scenes | 15 min | Easy |
| UI Scene | 5 min | Medium |
| First Test | 2 min | Easy |
| Feature Test | 5 min | Easy |
| Debug Console | 1 min | Easy |
| **TOTAL** | **~45 min** | **Medium** |

*Experienced Godot users: ~30 minutes*
*Complete beginners: ~90 minutes*

## 🚀 After Successful Setup

**Now you can:**
1. Play your game!
2. Adjust values in scripts
3. Add features from EXAMPLE_FEATURES.md
4. Read QUICK_REFERENCE.md for system details
5. Share with friends!

## 📚 Next Steps

### Immediate
- [ ] Read QUICK_REFERENCE.md
- [ ] Experiment with debug console
- [ ] Try modifying enemy stats

### Short Term
- [ ] Add sounds (see README.md suggestions)
- [ ] Tweak balance values
- [ ] Create better gun model

### Long Term
- [ ] Implement weapon system (EXAMPLE_FEATURES.md)
- [ ] Add boss battles
- [ ] Create shop system

## 🎯 Pro Tips

1. **Save Often**: Ctrl+S after every change
2. **Test Incrementally**: Test after each scene creation
3. **Use Debug Console**: F1 is your friend for testing
4. **Read Error Messages**: They usually tell you what's wrong
5. **Check Scene Names**: Must match preload paths exactly

## 🆘 Emergency Reset

If everything breaks:
1. Close Godot
2. Delete .godot folder in project
3. Reopen project (will reimport everything)
4. If still broken, recreate scenes from scratch

## ✨ You're Done!

Congratulations! You've successfully set up **Vortex Breach**!

**Time to play and extend your game!** 🎮

---

**Need help?** Check:
- SETUP_GUIDE.md for detailed instructions
- QUICK_REFERENCE.md for system info
- VISUAL_GUIDE.md for diagrams

**Want to add features?** See:
- EXAMPLE_FEATURES.md
- PROJECT_SUMMARY.md (Suggested Additions)

Good luck and have fun! 🚀
