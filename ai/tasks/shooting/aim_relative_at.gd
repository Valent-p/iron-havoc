@tool
extends BTAction

@export var target_var: StringName = &"target"

func _generate_name() -> String:
	return "Aim at %s" % [LimboUtility.decorate_var(target_var)]

func _tick(delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	
	# 1. Get the bot
	var bot: BotPlayer = agent as BotPlayer
	
	# 2. Tell the bot where to look
	bot.cmd_aim_at(target.global_position)
	
	# 3. Check if we are locked on (Optional, for returning SUCCESS)
	# But generally, for Parallel nodes, we return RUNNING to keep updating.
	return SUCCESS
