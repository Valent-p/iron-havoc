@tool
extends BTCondition
## IsHealthLQ
## Checks if health is less than specific value as percent.

## % (Percent), 0 to 100
@export_range(0, 100, 1) var value: int = 20

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Is health less than or equal to %s  percent" % [str(value)]

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if (agent.get_health()/agent.tank.health_max)*100 <= value:
		return SUCCESS
	return FAILURE


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
