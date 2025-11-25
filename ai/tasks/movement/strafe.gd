@tool
extends BTAction

## Strafe around Target
## Uses cmd_move to circle the target.

@export var target_var: StringName = &"target"
@export var direction_change_interval: float = 2.0 

var _strafe_dir: int = 1 
var _timer: float = 0.0

func _generate_name() -> String:
	return "Strafe around %s" % [LimboUtility.decorate_var(target_var)]

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	# Safe Cast (Enables autocomplete and type checking)
	var bot: BotPlayer = agent as BotPlayer
	
	# 1. Calculate Geometry
	var vector_to_target = target.global_position - bot.global_position
	var dir_to_target = vector_to_target.normalized()
	
	# 2. Random Zig-Zag
	_timer += delta
	if _timer > direction_change_interval:
		_timer = 0.0
		# 30% chance to flip direction, keeps it unpredictable
		if randf() > 0.7: 
			_strafe_dir *= -1 
			
	# Calculate Base Strafe Vector (Perpendicular)
	# Rotated 90 degrees around Up axis
	var strafe_vector = dir_to_target.rotated(Vector3.UP, deg_to_rad(90)) * _strafe_dir
	
	# Execute Command
	# cmd_move expects a direction. We normalize the result of our blending.
	bot.cmd_move(strafe_vector.normalized())
	
	# Always return RUNNING to keep the Parallel node alive
	return RUNNING
