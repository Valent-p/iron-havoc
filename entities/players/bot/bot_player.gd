class_name BotPlayer
extends Player

@onready var bullet_scene: PackedScene = preload("res://entities/projectiles/bullet.tscn")
@onready var collision = $CollisionShape3D

# Visual Nodes
@onready var base_mesh = $AssaultTank/Model/base
# We group the turret parts to rotate them together
@onready var turret_parts = [
	$AssaultTank/Model/pipe, 
	$AssaultTank/Model/pipe_cup, 
	$AssaultTank/Model/turret_mount
]

# Stats
var speed: float = 6.0
var base_turn_speed: float = deg_to_rad(180) # Radians per second
var turret_turn_speed: float = 10.0 # Faster than base

# Logic State
var _move_direction: Vector3 = Vector3.ZERO
var _aim_position: Vector3 = Vector3.ZERO # The world position we want to shoot
var _is_aiming: bool = false
var can_fire = true

func _ready():
	# Keep your wheel logic
	var left_wheel = $AssaultTank/Model/left
	var right_wheel = $AssaultTank/Model/right
	left_wheel.reparent(base_mesh, true)
	right_wheel.reparent(base_mesh, true)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_turret_aiming(delta)
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 20 * 9.8 * delta
	move_and_slide()

# --- INTERNAL PHYSICS LOGIC ---

func _handle_movement(delta: float):
	if _move_direction == Vector3.ZERO:
		# Decelerate
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.z = move_toward(velocity.z, 0, speed * delta)
		return

	# 1. Rotate Base to face movement direction
	var target_angle = atan2(_move_direction.x, _move_direction.z)
	var current_angle = base_mesh.rotation.y
	
	# Smooth rotation (LerpAngle handles the 360->0 wrap-around automatically)
	base_mesh.rotation.y = lerp_angle(current_angle, target_angle, base_turn_speed * delta)
	collision.rotation.y = base_mesh.rotation.y # Sync collision
	
	# 2. Move
	# Turn penalty: Slow down if we are facing the wrong way
	var angle_diff = abs(angle_difference(base_mesh.rotation.y, target_angle))
	var turn_penalty = clamp(1.0 - (angle_diff / 1.5), 0.2, 1.0) # Never stop completely (0.2)
	
	var desired_velocity = _move_direction * speed * turn_penalty
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z

func _handle_turret_aiming(delta: float):
	if not _is_aiming: return
	
	# Calculate target angle from Turret Center to Aim Position
	var turret_center = $AssaultTank/Model/turret_mount.global_position
	var dir_to_target = ( _aim_position - turret_center).normalized()
	
	# Calculate Yaw (Y-axis rotation)
	var target_yaw = atan2(dir_to_target.x, dir_to_target.z)
	
	# Since your turret parts are likely children of the Tank Base (or Root), 
	# we need to rotate them. 
	# WARNING: If they are children of Base, we must account for Base rotation?
	# Assuming they are children of Root (Player) or independent:
	
	# We rotate the first part (mount), and others follow? 
	# Based on your previous code, you rotated ALL of them. Let's do that.
	
	var current_yaw = $AssaultTank/Model/turret_mount.rotation.y
	var new_yaw = lerp_angle(current_yaw, target_yaw, turret_turn_speed * delta)
	
	for part in turret_parts:
		# If parts are children of 'AssaultTank' (which doesn't rotate), global rotation logic applies directly.
		# If they are children of 'base', we'd need local rotation. 
		# Assuming they function like your previous code:
		part.rotation.y = new_yaw

# --- AI COMMANDS (Call these from Behavior Tree) ---

## AI calls this to move. Input is normalized direction vector.
func cmd_move(direction: Vector3):
	_move_direction = direction.normalized()
	_move_direction.y = 0 # Flatten

## AI calls this to look at a specific point in the world
func cmd_aim_at(position: Vector3):
	_aim_position = position
	_is_aiming = true

## AI calls this to stop aiming
func cmd_stop_aim():
	_is_aiming = false

func action_shoot():
	if can_fire:
		can_fire = false
		$AssaultTank.fire_bullet()
		# Add timer reset logic here or in node

func _on_firerate_timer_timeout() -> void:
	can_fire = true
