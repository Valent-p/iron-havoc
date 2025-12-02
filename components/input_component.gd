extends Node
class_name InputComponent

@export var movement_component: MovementComponent
@export var weapon_component: WeaponComponent

@export var turret_pivot: Node3D
@export var camera: Camera3D

@export var mouse_sensitivity: float = 0.002

func _enter_tree():
	# Networking Setup
	var id = get_parent().name.to_int()
	if id != 0: get_parent().set_multiplayer_authority(id)
	
	if is_multiplayer_authority():
		if camera: camera.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if camera: camera.current = false

func _input(event):
	if not is_multiplayer_authority(): return
	
	# Handle Mouse Rotation (Turret + Camera)
	if event is InputEventMouseMotion:
		if turret_pivot:
			# We rotate the Turret. 
			# Since Camera is a child of Turret, it rotates too.
			turret_pivot.rotate_y(-event.relative.x * mouse_sensitivity)

	# Handle Escape (Menu)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if not is_multiplayer_authority():
		# Stop remote tanks from moving on their own
		if movement_component:
			movement_component.move_direction = Vector3.ZERO
		return
		
	# 1. Get RAW Input
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# 2. Convert to 3D World Space (Camera Relative)
	var direction = Vector3.ZERO
	
	if input_vector != Vector2.ZERO and camera:
		# Convert 2D input to 3D
		var raw_direction = Vector3(input_vector.x, 0, input_vector.y)
		
		# Get Camera Rotation (Basis)
		var camera_basis = camera.global_transform.basis
		
		# Rotate input by Camera angle
		direction = camera_basis * raw_direction
		
		# Flatten Y (So looking up doesn't make us fly)
		direction.y = 0
		direction = direction.normalized()
	
	# 3. Send to Engine
	if movement_component:
		movement_component.move_direction = direction
	
	# SHOOTING LOGIC
	if Input.is_action_pressed("primary_fire"):
		if weapon_component:
			weapon_component.shoot()
