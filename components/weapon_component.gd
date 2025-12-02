extends Node3D
class_name WeaponComponent

@export var weapon_stats: WeaponResource
@export var muzzle: Marker3D

# Internal State
var current_cooldown: float = 0.0

func _process(delta):
	# Cooldown Management
	if current_cooldown > 0:
		current_cooldown -= delta

func shoot():
	if current_cooldown > 0: return # Still reloading
	if not weapon_stats: return
	
	# Reset Cooldown
	current_cooldown = weapon_stats.fire_rate
	
	# Networking: Ask Server to spawn
	if multiplayer.is_server():
		spawn_projectile()
	else:
		rpc_id(1, "request_fire")

@rpc("call_local")
func request_fire():
	# Server validates (simple check)
	spawn_projectile()

func spawn_projectile():
	if not weapon_stats.projectile_scene: return
	
	# 1. Create Bullet
	var bullet = weapon_stats.projectile_scene.instantiate()
	
	# 2. Setup Stats
	if bullet.has_method("setup"):
		bullet.setup(weapon_stats)
	
	# 3. Position (At Muzzle)
	var world = get_tree().root.get_node("MainLevel") # Adjust if your root is named differently
	world.add_child(bullet, true) # 'true' creates readable name for spawner
	
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
