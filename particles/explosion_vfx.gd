extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Debris.emitting = true
	$Fire.emitting = true
	$Smoke.emitting = true
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
