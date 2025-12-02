extends "res://entities/projectile.gd"

@export var explosion_radius: float = 5.0
@export var explosion_scene: PackedScene

# We override the function from the parent script
func _on_area_entered(area):
	if not multiplayer.is_server(): return
	explode()

func _on_body_entered(body):
	if not multiplayer.is_server(): return
	explode()

func explode():
	# 1. Visuals (Spawn on Server, Sync via Spawner or RPC)
	# For simple particles, we can just spawn them. 
	# (Make sure ExplosionVFX is in your MultiplayerSpawner list!)
	if explosion_scene:
		var vfx = explosion_scene.instantiate()
		get_tree().root.get_node("MainLevel").add_child(vfx)
		vfx.global_position = global_position

	# 2. Area Damage Logic (The "Sphere Check")
	# We create a virtual sphere at the hit point and ask Physics: "Who is inside?"
	var space_state = get_world_3d().direct_space_state
	
	# Create a sphere shape for the query
	var shape = SphereShape3D.new()
	shape.radius = explosion_radius
	
	# Prepare the query
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), global_position)
	query.collide_with_areas = true # We want to hit Hitboxes (which are Areas)
	query.collide_with_bodies = false # Ignore walls/floors for damage
	query.collision_mask = 1 << 3 # Check Layer 4 (Hitboxes) only. (Bitwise math: 1 << 3 is 4th bit)
	
	# Execute
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		if collider.has_method("hit"):
			# Distance falloff? (Optional)
			# var dist = global_position.distance_to(collider.global_position)
			# var actual_damage = damage * (1.0 - (dist / explosion_radius))
			collider.hit(damage)

	# 3. Destroy Missile
	queue_free()
