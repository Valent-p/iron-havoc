# meta-name: MoveTo Task
# meta-description: Move a player from current position to another.
# meta-default: true
@tool
extends BTAction
## _CLASS_

@export var target_var: StringName = &"target"

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Chase %s" % [LimboUtility.decorate_var(target_var)] 
	
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
	
	var direction = agent.global_position.direction_to(target.global_position)
	agent.cmd_move(direction)
	return SUCCESS

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
