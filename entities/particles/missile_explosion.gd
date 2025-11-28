extends Node3D


# Params
## The shooter
var player: Player

## The maximum damage
var max_damage: float

## Make hitting one_shot for each body
var hits: Dictionary[int, bool] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Debris.emitting = true
	$Debris.one_shot = true
	
	$Fire.emitting = true
	$Fire.one_shot = true
	
	$Smoke.emitting = true
	$Smoke.one_shot = true
	
	$Timer.timeout.connect(queue_free)


func _on_impact_area_body_entered(body: Node3D) -> void:
	if not body is Player: return
	body = body as Player
	
	# Take effect only for a specific period
	if hits.has(body.data.uuid) or $Timer.time_left <= $Timer.wait_time * 0.75 : return
	
	# 1. Get the ACTUAL world radius of the sphere
	var collider = $ImpactArea/CollisionShape3D # Adjust path if needed
	var max_radius = collider.shape.radius * $ImpactArea.scale.x
	
	# 2. Get Distance
	var dist = global_position.distance_to(body.global_position)
	
	# 3. Calculate Normalized Distance (0.0 to 1.0)
	# 0.0 means center, 1.0 means edge
	var distance_factor = dist / (max_radius * 2)
	
	# 4. Invert it for Damage
	# Now: 0.0 distance becomes 1.0 damage. 1.0 distance becomes 0.0 damage.
	# NOTE: I added 0.3 since due to the tank's size, you cannot exactly hit at 0.0
	# Therefore, for the curent tank, 0.3 gives 1.0 but removing it give 0.7 as max
	var damage_pct = (1.0 - distance_factor) + 0.3
	
	# 5. Clamp it just in case physics glitches and calculates a hit slightly outside bounds
	# Start at 0.05 to make sure there is always a hit
	damage_pct = clamp(damage_pct, 0.05, 1.0)
	
	# 6. The actual damage
	var final_damage = max_damage * damage_pct
	
	#print("Hit: ", body.name, " | Dist: ", snapped(dist, 0.1), " | Dmg %: ", snapped(damage_pct, 0.1), " ,, Dmg: ", final_damage)
	
	body.take_damage(final_damage, self.player)
	hits[body.data.uuid] = true
