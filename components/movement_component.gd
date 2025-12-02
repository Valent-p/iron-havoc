extends Node
class_name MovementComponent

@export var body: CharacterBody3D
@export var turret_pivot: Node3D 

# Settings (Ported from your old code)
@export var speed: float = 10.0 # 200.0 in old code is approx 10-12 in Godot 4 units
@export var rotation_speed: float = 5.0 # High value for snappy turns
@export var gravity: float = 9.8 * 100

# Input variables (Set by InputComponent)
var move_direction: Vector3 = Vector3.ZERO

func _physics_process(delta):
	if not body: return
	# Save the Turret's current Global Rotation before we spin the body
	var saved_turret_rot
	if turret_pivot:
		saved_turret_rot = turret_pivot.global_rotation
	
	var target_velocity = Vector3.ZERO
	
	# If we have input
	if move_direction.length_squared() > 0.01:
		# 1. Calculate the Angle we WANT to face
		# atan2(x, z) gives the angle of the vector
		var target_angle = atan2(move_direction.x, move_direction.z)
		
		# 2. Smoothly rotate the body to face that angle
		# We use rotate_toward or lerp_angle. lerp_angle is smoother.
		var current_rot = body.rotation.y
		body.rotation.y = lerp_angle(current_rot, target_angle, rotation_speed * delta)
		
		# 3. Calculate Turn Penalty (The "Weight" of the tank)
		# If we are facing the wrong way, we move slower
		var angle_diff = abs(angle_difference(body.rotation.y, target_angle))
		
		# If angle is 0 (Perfect), penalty is 1.0. 
		# If angle is 90 deg (1.57 rad), penalty drops.
		var turn_penalty = clamp(1.0 - (angle_diff / 2.0), 0.0, 1.0)
		
		# 4. Apply Velocity
		target_velocity = move_direction * speed * turn_penalty
	
	# Apply Gravity
	if not body.is_on_floor():
		target_velocity.y -= gravity * delta
	else:
		target_velocity.y = 0

	# Move
	body.velocity = target_velocity
	body.move_and_slide()
	
	# Restore the Turret's Global Rotation
	if turret_pivot:
		turret_pivot.global_rotation = saved_turret_rot
