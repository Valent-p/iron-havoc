@tool
extends BTAction
## Runaway

## Entity to run from: Node3D
@export var target_var: StringName = &"target"

## Total distance to stop running away
@export var distance: float = 5

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Runaway from %s (dist <= %s)" % [LimboUtility.decorate_var(target_var), str(distance)]


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	pass


# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	# Safe Cast (Enables autocomplete and type checking)
	var bot: BotPlayer = agent as BotPlayer
	
	# Calculate Geometry
	var vector_to_target = target.global_position - bot.global_position
	var covered_dist = vector_to_target.length()
	
	bot.cmd_move(-vector_to_target.normalized())
	
	if covered_dist >= distance:
		return SUCCESS
	return RUNNING
