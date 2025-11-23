@tool
extends BTCondition
## IsDistanceLessthan

@export var target_var: StringName = &"target"
@export var distance_var: float = 0

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Is distance to %s Less than %sm?" % [LimboUtility.decorate_var(target_var) , (distance_var)]

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
func _tick(delta: float) -> Status:
	var target: Player = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	var actual_dist = agent.global_position.distance_to(target.global_position)
	if actual_dist < distance_var:
		return SUCCESS
	else:
		return FAILURE


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
