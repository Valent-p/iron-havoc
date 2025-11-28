# meta-name: MoveTo Task
# meta-description: Move a player from current position to another.
# meta-default: true
@tool
extends BTAction
## _CLASS_

@export var target_var: StringName = &"target"
@export var distance: float = 5.0

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Chase %s (distance: %s)" % [LimboUtility.decorate_var(target_var), str(distance)] 
	
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
	
	agent.nav_agent.set_target_position(target.global_position)
	var direction = agent.position.direction_to(agent.nav_agent.get_next_path_position())
	
	var actual_dist = (target.position - agent.position).length()
	## Chased and caught
	if actual_dist <= distance:
		return SUCCESS
		
	agent.cmd_move(direction)
	
	return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
