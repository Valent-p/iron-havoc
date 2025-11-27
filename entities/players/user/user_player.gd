class_name UserPlayer
extends Player

@onready var collision = $CollisionShape3D
@onready var camera = $TopdownCamera

var can_fire = true
## X rotation factor
var mouse_sensitivity: float = 0.002

var speed: float = 200.0
var rotation_speed: float = deg_to_rad(180)
var target_velocity = Vector3.ZERO
var target_angle: float = 0

func _ready():
	tank = $AssaultTank
	
	Input.mouse_mode = (Input.MOUSE_MODE_CAPTURED)
	
	# 1. Get the nodes
	var base = tank.model_base
	var left_wheel = tank.model_left
	var right_wheel = tank.model_right
	
	# 2. Move the wheels inside the base
	# The 'true' argument keeps them in their current physical position
	left_wheel.reparent(base, true)
	right_wheel.reparent(base, true)
	
	# Params
	$AssaultTank.player = self

func _physics_process(delta: float) -> void:
	action_shoot()
	
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
	
	action_move(delta, input_dir)

func action_shoot():
	if can_fire and Input.is_action_pressed("primary_shoot"):
		can_fire = false
		$AssaultTank.fire_bullet()

func action_move(delta:float, input_dir: Vector3) -> bool:
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		
		# 1. Get the rotation of the Camera Pivot (where you are looking)
		var camera_basis = camera.global_transform.basis
		
		# 2. Apply that rotation to your input direction
		var direction = (camera_basis * input_dir)
		
		# 3. Flatten the Y axis so looking up/down doesn't slow you down or make you fly
		direction.y = 0
		direction = direction.normalized()
		
		# Apply velocity
		target_velocity = direction * speed * delta
		
		# Smoothly rotate the base
		var look_direction = Vector3(direction.x, 0, direction.z)
		if look_direction != Vector3.ZERO:
			# Calculate the angle we want to face (in radians)
			# atan2(x, z) gives us the angle from the vector
			target_angle = atan2(look_direction.x, look_direction.z)
			
			target_angle += PI 

			# Smoothly rotate ONLY the Y axis
			tank.model_base.rotation.y = lerp_angle(tank.model_base.rotation.y, target_angle, rotation_speed * delta)
			collision.rotation.y = tank.model_base.rotation.y 
	else:
		target_velocity = Vector3.ZERO
	
		
	# Calculate how far off we are (0.0 is perfect, 1.0 is facing opposite)
	var angle_diff = abs(angle_difference(tank.model_base.rotation.y, target_angle))
	
	# Create a multiplier: 
	# If angle is 0 (facing forward), multiplier is 1.0 (Full Speed).
	# If angle is 90 degrees (1.57 rad), multiplier is approx 0.0 (Stop and rotate then start moving).
	var turn_penalty = clamp(1.0 - (angle_diff / 2.0), 0.0, 1.0)
	
	# Apply velocity with the penalty
	velocity = target_velocity * turn_penalty
	
	if not is_on_floor():
		velocity.y -= 100 * 9.8 * delta
		
	return move_and_slide()

func _unhandled_input(event):
	# 1. Handle the Escape Key
	# We check 'is_echo()' to ensure holding the button doesn't rapid-fire toggle it
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		print("Escape")
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			print("SHOWN")
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			print("HIDDEN")
		
		# IMPORTANT: Tell Godot "I handled this, don't let anyone else use it"
		get_viewport().set_input_as_handled()

	# 2. Handle Mouse Rotation
	# Only rotate if the mouse is actually captured (so you don't rotate while in menus)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		action_muzzle_rotate(event.relative.x)

func action_muzzle_rotate(relative_x: float):
	var mouse_delta_x = relative_x * mouse_sensitivity
	tank.model_pipe.rotate_y(-mouse_delta_x)
	tank.model_pipe_cup.rotate_y(-mouse_delta_x)
	tank.model_turret_mount.rotate_y(-mouse_delta_x)
	camera.rotate_y(-mouse_delta_x)


func take_damage(value: int, attacker: Player) -> bool:
	# temporarily disable dying
	return false
	
	_health -= value
	if _health <= 0:
		_health = 0
		
		# The kill
		queue_free()
		return true # dead
	
	return false # Not dead

func _on_firerate_timer_timeout() -> void:
	can_fire = true
