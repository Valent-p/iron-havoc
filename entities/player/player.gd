extends CharacterBody3D

var bullet_scene: PackedScene = preload("res://entities/projectiles/bullet.tscn")

@onready var muzzle = $Muzzle
@onready var collision = $CollisionShape3D

var can_fire = true

var mouse_sensitivity: float = 0.002
var speed: float = 5.0
var rotation_speed: float = 5.0
var target_velocity = Vector3.ZERO
var target_angle: float = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# 1. Get the nodes
	var base = $tank_assault/base
	var left_wheel = $tank_assault/left
	var right_wheel = $tank_assault/right
	var pipe_cup = $tank_assault/pipe_cup
	
	# 2. Move the wheels inside the base
	# The 'true' argument keeps them in their current physical position
	left_wheel.reparent(base, true)
	right_wheel.reparent(base, true)
	muzzle.reparent(pipe_cup, true)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # "ui_cancel" is usually the Escape key
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# Rotation
	if event is InputEventMouseMotion:
		# Get the relative movement distance (delta)
		var mouse_delta_x = event.relative.x * mouse_sensitivity

		# Rotate the main node (player/controller) around the Y-axis for left/right movement
		$tank_assault/pipe.rotate_y(-mouse_delta_x) # Subtract for inverted control, remove '-' if you want normal direction
		$tank_assault/pipe_cup.rotate_y(-mouse_delta_x) # Subtract for inverted control, remove '-' if you want normal direction
		$tank_assault/turret_mount.rotate_y(-mouse_delta_x) # Subtract for inverted control, remove '-' if you want normal direction
		$CameraPivot.rotate_y(-mouse_delta_x)

func fire_bullet():
	if bullet_scene:
		# 1. Create the bullet
		var bullet = bullet_scene.instantiate()
		
		# 2. Add it to the MAIN SCENE, not the tank.
		# If you add it to the tank, the bullet will move/rotate with the tank.
		get_tree().root.add_child(bullet)
		
		# 3. Set position and rotation to match the muzzle
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = muzzle.global_rotation
			
		
func _physics_process(delta: float) -> void:
	# Shooting
	if can_fire and Input.is_action_pressed("primary_shoot"):
		can_fire = false
		fire_bullet()
	
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		
		# 1. Get the rotation of the Camera Pivot (where you are looking)
		var camera_basis = $CameraPivot.global_transform.basis
		
		# 2. Apply that rotation to your input direction
		var direction = (camera_basis * input_dir)
		
		# 3. Flatten the Y axis so looking up/down doesn't slow you down or make you fly
		direction.y = 0
		direction = direction.normalized()
		
		# Apply velocity
		target_velocity = direction * speed
		
		# Smoothly rotate the base
		var look_direction = Vector3(direction.x, 0, direction.z)
		if look_direction != Vector3.ZERO:
			# Calculate the angle we want to face (in radians)
			# atan2(x, z) gives us the angle from the vector
			target_angle = atan2(look_direction.x, look_direction.z)
			
			target_angle += PI 

			# Smoothly rotate ONLY the Y axis
			$tank_assault/base.rotation.y = lerp_angle($tank_assault/base.rotation.y, target_angle, rotation_speed * delta)
			collision.rotation.y = $tank_assault/base.rotation.y 
	else:
		target_velocity = Vector3.ZERO
	
		
	# Calculate how far off we are (0.0 is perfect, 1.0 is facing opposite)
	var angle_diff = abs(angle_difference($tank_assault/base.rotation.y, target_angle))
	
	# Create a multiplier: 
	# If angle is 0 (facing forward), multiplier is 1.0 (Full Speed).
	# If angle is 90 degrees (1.57 rad), multiplier is approx 0.0 (Stop and rotate then start moving).
	var turn_penalty = clamp(1.0 - (angle_diff / 2.0), 0.0, 1.0)
	
	# Apply velocity with the penalty
	velocity = target_velocity * turn_penalty
	
	if not is_on_floor():
		velocity.y -= 100 * 9.8 * delta
		
	move_and_slide()


func _on_firerate_timer_timeout() -> void:
	can_fire = true
