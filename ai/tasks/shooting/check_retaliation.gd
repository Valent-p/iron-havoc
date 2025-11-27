@tool
extends BTAction
## CheckRetaliation
## Checks if we were hit recently by a new enemy. If so, switches target.

@export var target_var: StringName = &"target"
@export var aggressor_var: StringName = &"latest_aggressor"
@export var time_var: StringName = &"last_hit_time"
@export var reaction_time_ms: int = 2000 # 2 Seconds memory

## If true, compare hp and go for lower
@export var compare_hp: bool = false

func _generate_name() -> String:
	return "Retaliate if attacked (Memory: %sms)" % reaction_time_ms

func _tick(_delta: float) -> Status:
	# 1. Get Data
	var current_target: Player = blackboard.get_var(target_var)
	var aggressor = blackboard.get_var(aggressor_var) if blackboard.get_var(aggressor_var) else null
	var last_hit = blackboard.get_var(time_var, 0) # Default to 0
	
	# 2. Validate Aggressor
	if not is_instance_valid(aggressor):
		#print("Retaliate fail, not valid", aggressor)
		return FAILURE
		
	# 3. Check Time (Are we still angry?)
	var time_diff = Time.get_ticks_msec() - last_hit
	if time_diff > reaction_time_ms:
		#print("Retaliate fail, time range")
		return FAILURE # Attack was too long ago, ignore it.
		
	# 4. Check if it's the SAME person
	if aggressor == current_target:
		#print("Retaliate fail, same")
		return FAILURE # We are already fighting them.
		
	# 5. Compare hp
	if compare_hp:
		# Go for the weak one
		if aggressor.get_health() < current_target.get_health():
			blackboard.set_var(target_var, aggressor)
			print("Switching target to aggressor (weak): ", aggressor.name)
			return SUCCESS
	
	blackboard.set_var(target_var, aggressor)
	#print("Switching target to aggressor: ", aggressor.name)
	
	# Clear the aggressor so we don't switch again next frame unnecessarily
	# (Or keep it if you want to constantly update)
	# blackboard.set_var(aggressor_var, null) 
	
	return SUCCESS
