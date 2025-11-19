# EXAMPLE: Adding Weapon Switching

This is an example of how to extend the game with a weapon system.
This file is for REFERENCE ONLY - you can implement this if you want weapon variety!

## Step 1: Create Weapon Script

```gdscript
# Weapon.gd
extends Node3D
class_name Weapon

enum WeaponType { PISTOL, SHOTGUN, RIFLE, SNIPER }

var weapon_type = WeaponType.PISTOL
var weapon_name = "Pistol"
var damage = 10.0
var fire_rate = 0.2
var bullet_speed = 50.0
var bullet_spread = 0.0
var bullets_per_shot = 1
var max_ammo = 100
var reload_time = 1.0

@onready var mesh = $MeshInstance3D
@onready var muzzle = $Muzzle

func _ready():
    configure_weapon()

func configure_weapon():
    match weapon_type:
        WeaponType.PISTOL:
            weapon_name = "Pistol"
            damage = 10.0
            fire_rate = 0.2
            bullet_speed = 50.0
            bullets_per_shot = 1
            bullet_spread = 0.0
            max_ammo = 100
            
        WeaponType.SHOTGUN:
            weapon_name = "Shotgun"
            damage = 5.0
            fire_rate = 0.8
            bullet_speed = 40.0
            bullets_per_shot = 8  # Fires multiple pellets
            bullet_spread = 0.15
            max_ammo = 40
            
        WeaponType.RIFLE:
            weapon_name = "Rifle"
            damage = 15.0
            fire_rate = 0.1
            bullet_speed = 80.0
            bullets_per_shot = 1
            bullet_spread = 0.02
            max_ammo = 150
            
        WeaponType.SNIPER:
            weapon_name = "Sniper"
            damage = 50.0
            fire_rate = 1.5
            bullet_speed = 100.0
            bullets_per_shot = 1
            bullet_spread = 0.0
            max_ammo = 30

func shoot(camera: Camera3D, bullet_scene: PackedScene) -> Array:
    var bullets = []
    
    for i in range(bullets_per_shot):
        var bullet = bullet_scene.instantiate()
        
        # Calculate spread
        var spread_offset = Vector3(
            randf_range(-bullet_spread, bullet_spread),
            randf_range(-bullet_spread, bullet_spread),
            0
        )
        var direction = (-camera.global_transform.basis.z + spread_offset).normalized()
        
        bullet.set_properties(direction, bullet_speed, damage, 100.0)
        bullets.append(bullet)
    
    return bullets
```

## Step 2: Modify Player.gd

Add to Player.gd:

```gdscript
# At the top with other variables
var weapons = []
var current_weapon_index = 0
var current_weapon: Weapon = null

# In _ready()
func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    setup_weapons()

func setup_weapons():
    # Create weapons
    var pistol = Weapon.new()
    pistol.weapon_type = Weapon.WeaponType.PISTOL
    
    var shotgun = Weapon.new()
    shotgun.weapon_type = Weapon.WeaponType.SHOTGUN
    
    var rifle = Weapon.new()
    rifle.weapon_type = Weapon.WeaponType.RIFLE
    
    weapons = [pistol, shotgun, rifle]
    
    # Equip first weapon
    equip_weapon(0)

func equip_weapon(index: int):
    if current_weapon:
        gun.remove_child(current_weapon)
    
    current_weapon_index = index
    current_weapon = weapons[index]
    gun.add_child(current_weapon)

# In _input()
func _input(event):
    # ... existing code ...
    
    # Weapon switching with number keys
    if event.is_action_pressed("weapon_1"):
        equip_weapon(0)
    elif event.is_action_pressed("weapon_2") and weapons.size() > 1:
        equip_weapon(1)
    elif event.is_action_pressed("weapon_3") and weapons.size() > 2:
        equip_weapon(2)
    
    # Or use mouse wheel
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            cycle_weapon(-1)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            cycle_weapon(1)

func cycle_weapon(direction: int):
    current_weapon_index = (current_weapon_index + direction) % weapons.size()
    if current_weapon_index < 0:
        current_weapon_index = weapons.size() - 1
    equip_weapon(current_weapon_index)

# Modify shoot() function
func shoot():
    if not current_weapon:
        return
    
    var bullets = current_weapon.shoot(camera, bullet_scene)
    
    for bullet in bullets:
        get_parent().add_child(bullet)
        bullet.global_transform.origin = muzzle.global_transform.origin
    
    current_ammo -= 1
    play_shoot_animation()
```

## Step 3: Add Input Actions

Add to project.godot:

```
weapon_1={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":49,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
weapon_2={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":50,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
weapon_3={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":51,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
```

## Step 4: Update UI

Add to UI.gd:

```gdscript
@onready var weapon_label = $MarginContainer/VBoxContainer/WeaponLabel

func update_weapon(weapon_name: String):
    weapon_label.text = "Weapon: %s" % weapon_name
```

Add to UI scene:
- Add WeaponLabel as child of VBoxContainer

Update from Player.gd:
```gdscript
func equip_weapon(index: int):
    # ... existing code ...
    
    var ui = get_node_or_null("/root/World/UI")
    if ui:
        ui.update_weapon(current_weapon.weapon_name)
```

## Alternative: Weapon Pickups

Create WeaponPickup.gd:

```gdscript
extends Area3D

var weapon_type = Weapon.WeaponType.PISTOL

func _ready():
    body_entered.connect(_on_body_entered)
    create_visual()

func create_visual():
    var mesh_instance = MeshInstance3D.new()
    var box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(0.3, 0.1, 0.5)
    mesh_instance.mesh = box_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.STEEL_BLUE
    mesh_instance.set_surface_override_material(0, material)
    
    add_child(mesh_instance)

func _on_body_entered(body):
    if body.is_in_group("Player") and body.has_method("unlock_weapon"):
        body.unlock_weapon(weapon_type)
        queue_free()
```

Add to Player.gd:

```gdscript
var unlocked_weapons = [Weapon.WeaponType.PISTOL]  # Start with pistol

func unlock_weapon(weapon_type):
    if not weapon_type in unlocked_weapons:
        unlocked_weapons.append(weapon_type)
        
        var new_weapon = Weapon.new()
        new_weapon.weapon_type = weapon_type
        weapons.append(new_weapon)
        
        print("Unlocked: ", new_weapon.weapon_name)
```

## Other Feature Examples

### Grenade System

```gdscript
# Grenade.gd
extends RigidBody3D

var explosion_radius = 5.0
var explosion_damage = 50.0
var fuse_time = 3.0

func _ready():
    await get_tree().create_timer(fuse_time).timeout
    explode()

func explode():
    # Find enemies in radius
    var space_state = get_world_3d().direct_space_state
    var enemies = get_tree().get_nodes_in_group("Enemy")
    
    for enemy in enemies:
        var distance = global_position.distance_to(enemy.global_position)
        if distance <= explosion_radius:
            var damage = explosion_damage * (1.0 - distance / explosion_radius)
            enemy.take_damage(damage)
    
    queue_free()
```

### Dash Ability

```gdscript
# Add to Player.gd
var dash_speed = 20.0
var dash_duration = 0.2
var dash_cooldown = 1.0
var can_dash = true

func _input(event):
    if event.is_action_pressed("dash") and can_dash:
        perform_dash()

func perform_dash():
    can_dash = false
    var dash_direction = -camera.global_transform.basis.z
    dash_direction.y = 0
    dash_direction = dash_direction.normalized()
    
    velocity = dash_direction * dash_speed
    
    await get_tree().create_timer(dash_duration).timeout
    await get_tree().create_timer(dash_cooldown).timeout
    can_dash = true
```

### Shop System

```gdscript
# Shop.gd
extends Control

signal purchase_made(item_type: String)

func _ready():
    $BuyHealthButton.pressed.connect(func(): buy_item("health", 50))
    $BuyAmmoButton.pressed.connect(func(): buy_item("ammo", 30))
    $BuyDamageButton.pressed.connect(func(): buy_item("damage", 100))

func buy_item(item_type: String, cost: int):
    var player = get_tree().get_first_node_in_group("Player")
    if player and player.gold >= cost:
        player.gold -= cost
        purchase_made.emit(item_type)
        
        match item_type:
            "health":
                player.max_health += 20
                player.health = player.max_health
            "ammo":
                player.max_ammo += 50
            "damage":
                player.base_bullet_damage += 5
```

## Conclusion

This example shows how to:
1. Create new game systems (weapons)
2. Modify existing systems (player)
3. Add new input actions
4. Update UI for new features
5. Create pickup items

Use this pattern to add ANY new feature to Vortex Breach!
