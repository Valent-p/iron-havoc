extends Node
class_name LifeCycleComponent

@export var health_component: HealthComponent
@export var tank_root: CharacterBody3D
@export var visuals: Node3D
@export var collider: CollisionShape3D

func _ready():
	# Only the Server manages life/death rules
	if multiplayer.is_server():
		health_component.on_died.connect(_on_died)

func _on_died():
	# 1. Tell everyone "I died" (RPC)
	rpc("handle_death_visuals")
	
	# 2. Start Respawn Timer (Server Only)
	await get_tree().create_timer(3.0).timeout
	respawn()

@rpc("call_local")
func handle_death_visuals():
	# Hide the tank
	visuals.visible = false
	# Disable physics
	collider.disabled = true
	tank_root.set_physics_process(false)
	
	# Optional: Spawn Explosion Particle here!

func respawn():
	# 1. Reset Health
	health_component.current_health = health_component.max_health
	
	# 2. Find a Spawn Point
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoint") # We will group them
	if spawn_points.size() > 0:
		var point = spawn_points.pick_random()
		tank_root.global_position = point.global_position
		tank_root.global_rotation = point.global_rotation
	
	# 3. Tell everyone "I'm back"
	rpc("handle_respawn_visuals")

@rpc("call_local")
func handle_respawn_visuals():
	visuals.visible = true
	collider.disabled = false
	tank_root.set_physics_process(true)
	# Optional: Spawn "Teleport In" effect
