@tool
extends BTAction

## Strafe around Target
## Uses cmd_move to circle the target while maintaining a radius.

@export var target_var: StringName = &"target"
@export var radius: float = 8.0 # Ideal combat distance
@export var direction_change_interval: float = 2.0 

var _strafe_dir: int = 1 
var _timer: float = 0.0

func _generate_name() -> String:
	return "Strafe around %s (Dist: %s)" % [LimboUtility.decorate_var(target_var), radius]

func _enter() -> void:
	_strafe_dir = 1 if randf() > 0.5 else -1
	_timer = 0.0

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	# Safe Cast (Enables autocomplete and type checking)
	var bot: BotPlayer = agent as BotPlayer
	
	# 1. Calculate Geometry
	var vector_to_target = target.global_position - bot.global_position
	var distance = vector_to_target.length()
	var dir_to_target = vector_to_target.normalized()
	
	# 2. Random Zig-Zag
	_timer += delta
	if _timer > direction_change_interval:
		_timer = 0.0
		# 30% chance to flip direction, keeps it unpredictable
		if randf() > 0.7: 
			_strafe_dir *= -1 
			
	# 3. Calculate Base Strafe Vector (Perpendicular)
	# Rotated 90 degrees around Up axis
	var strafe_vector = dir_to_target.rotated(Vector3.UP, deg_to_rad(90)) * _strafe_dir
	
	# 4. Spiral Logic (Blend In/Out)
	# We create a 'final_direction' by mixing the strafe with forward/backward
	var final_direction = strafe_vector
	
	if distance < radius - 2.0:
		# Too close? Push away (Back up 70%, Strafe 30%)
		var push_back = -dir_to_target 
		final_direction = (strafe_vector * 0.5) + (push_back * 1.0)
		
	elif distance > radius + 2.0:
		# Too far? Pull in (Chase 60%, Strafe 40%)
		# This effectively replaces the need to 'Fail' and switch to Chase
		# The bot will spiral inward until it hits the radius.
		final_direction = (strafe_vector * 0.8) + (dir_to_target * 1.0)
	
	# 5. Execute Command
	# cmd_move expects a direction. We normalize the result of our blending.
	bot.cmd_move(final_direction.normalized())
	
	# Always return RUNNING to keep the Parallel node alive
	return RUNNING
