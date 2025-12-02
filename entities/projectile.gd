extends Area3D

var speed: float = 0.0
var damage: float = 0.0
var lifetime: float = 0.0

func setup(stats: WeaponResource):
	speed = stats.projectile_speed
	damage = stats.damage
	lifetime = stats.projectile_lifetime

func _ready():
	# Auto-destroy after lifetime ends
	if multiplayer.is_server():
		# Only server handles this
		await get_tree().create_timer(lifetime).timeout
		queue_free()

func _physics_process(delta):
	# Move forward relative to rotation
	position -= transform.basis.z * speed * delta

func _on_body_entered(_body):
	# Only server handles this
	if not multiplayer.is_server():
		visible = false # Hide it instantly so it looks responsive
		return 
	
	# Hit a Wall (Layer 1)
	queue_free()

func _on_area_entered(area):
	# Only server handles this
	if not multiplayer.is_server():
		visible = false # Hide it instantly so it looks responsive
		return 
	
	# Hit a Hitbox (Layer 4)
	if area.has_method("hit"):
		area.hit(damage)
	queue_free()
