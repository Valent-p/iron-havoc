# meta-name: Custom Task
# meta-description: Custom task to be used in a BehaviorTree
# meta-default: true
@tool
extends BTAction
## SetRandomPlayer

@export var target_var: StringName = &"target"

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Set Random Player into %s" % [LimboUtility.decorate_var(target_var)]


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
	var targets = agent.get_tree().get_nodes_in_group("UserPlayer")
	if not targets.is_empty():
		blackboard.set_var(target_var, targets[randi_range(0, len(targets)-1)])
		return SUCCESS
	
	return FAILURE

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
