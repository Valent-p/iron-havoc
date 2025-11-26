extends Node3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Debris.emitting = true
	$Fire.emitting = true
	$Smoke.emitting = true
	$Timer.timeout.connect(queue_free)
