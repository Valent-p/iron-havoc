extends Node3D

@onready var hp_pu_scn = preload("res://entities/powerups/health/health_pu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pu_timer_timeout() -> void:
	var hp: Powerup = hp_pu_scn.instantiate()
	add_child(hp)
	
	hp.global_position = global_position + Vector3(randi_range(-14, 14), 1, randi_range(-14, 14))
	hp.scale *= 0.5
