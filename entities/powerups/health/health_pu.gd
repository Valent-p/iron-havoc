extends Powerup

## Rotation speed
var rot_speed = deg_to_rad(2)

## How much to heal
var value = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("up_down")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(rot_speed)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("heal"):
		body.heal(value)
		queue_free()
