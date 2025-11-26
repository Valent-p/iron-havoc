@tool
extends BTAction
## SetRandomPlayer

@export var target_var: StringName = &"target"
@export var group_name: String = "AllPlayers"
@export var overwrite: bool = false

func _generate_name() -> String:
	return "Find Target from %s (Overwrite: %s)" % [group_name, str(overwrite)]

func _tick(_delta: float) -> Status:
	# 1. Check current target status
	var current_target = blackboard.get_var(target_var)
	var is_current_valid = is_instance_valid(current_target)
	
	# If we have a valid target and we are NOT overwriting, we are done. Keep the current one.
	if is_current_valid and not overwrite:
		# Optional: Check if target is dead (if you have a 'dead' variable)
		# if current_target.health > 0:
		return SUCCESS
	
	# 2. Get all potential candidates
	var all_nodes = agent.get_tree().get_nodes_in_group(group_name)
	var valid_candidates = []
	
	# 3. FILTER the candidates
	for node in all_nodes:
		# A. Don't target myself! (Crucial for the "Shooting Wall" fix)
		if node == agent:
			continue
			
		# B. Must be a valid instance
		if not is_instance_valid(node):
			continue
			
		# C. (Optional) Don't target dead bodies if they linger
		if node.is_queued_for_deletion():
			continue
			
		valid_candidates.append(node)
	
	# 4. If no one is alive (except me), FAIL.
	if valid_candidates.is_empty():
		blackboard.set_var(target_var, null) # Clear target
		return FAILURE
	
	# 5. Pick a random winner
	var new_target = valid_candidates.pick_random()
	blackboard.set_var(target_var, new_target)
	
	return SUCCESS
