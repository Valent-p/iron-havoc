@tool
extends BTAction
## CollectPowerUp [br]
## Returns RUNNING if there is a powerup to get, or SUCCESS if there is no powerup.

@export var target_powerup_var: StringName = &"target_powerup"
@export var powerup_id: int = 0

# Display a customized name (requires @tool).
func _generate_name() -> String:
	var pu_name = ""
	match powerup_id:
		Powerup.PU_TYPE.HEALTH: pu_name = "Health"
		_: "<Unkown>"
	
	return "Collect powerup %s of type %s if available" % [LimboUtility.decorate_var(target_powerup_var), pu_name] 

func _enter() -> void:
	var powerup = agent.detected_powerups.get(powerup_id)
	if powerup:
		blackboard.set_var(target_powerup_var, powerup)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var target_powerup = blackboard.get_var(target_powerup_var)
	if not is_instance_valid(target_powerup):
		return SUCCESS
	
	agent.nav_agent.set_target_position(target_powerup.global_position)
	var direction = agent.global_position.direction_to(agent.nav_agent.get_next_path_position())
	agent.cmd_move(direction)
	
	return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
