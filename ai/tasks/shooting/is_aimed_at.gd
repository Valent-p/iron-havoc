@tool
extends BTCondition
## Checks if the turret is facing the target within a tolerance angle.

@export var target_var: StringName = &"target"
@export var angle_tolerance_degrees: float = 15.0 # How accurate must they be to shoot?

func _generate_name() -> String:
	return "Is Turret aligned to %s (< %s°)" % [LimboUtility.decorate_var(target_var), angle_tolerance_degrees]

func _tick(_delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
		
	var bot: BotPlayer = agent as BotPlayer
	# Access the turret directly using the node path from your BotPlayer script
	var turret = bot.get_node("AssaultTank/Model/turret_mount")
	
	# 1. Get Directions
	var turret_forward = -turret.global_transform.basis.z # -Z is forward
	var dir_to_target = (target.global_position - turret.global_position).normalized()
	
	# 2. Calculate Angle
	# angle_to returns always positive radians (0 to PI)
	var angle_rad = turret_forward.angle_to(dir_to_target)
	var angle_deg = rad_to_deg(angle_rad)
	
	# 3. Check Tolerance
	# If angle is smaller than tolerance, we are aiming at them!
	return angle_deg < angle_tolerance_degrees
