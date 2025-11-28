extends Area3D

@onready var particles_scn = preload("res://entities/particles/missile_explosion.tscn")

## Who shot
var player: Player

## How fast to move
var speed: float = 150.0

## How bad to hurt
var damage: int = 50

func _ready():
	# If the bullet flies for 3 seconds without hitting anything, destroy it
	$LifespanTimer.timeout.connect(queue_free)
	
	# Connect the collision signal
	body_entered.connect(_on_body_entered)
	

func _physics_process(delta: float) -> void:
	# Move forward (local -Z axis)
	position -= transform.basis.z * speed * delta

func _on_body_entered(body: Node3D):
	# In case it was freed or something
	if not is_instance_valid(body) or not is_instance_valid(self.player):
		return
		
	# Don't hit ourselves (optional check, mostly handled by layers later)
	# But we usually want to ignore the shooter if possible.
	
	# Create an explosion effect here if you have one
	var particles: Node3D = particles_scn.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.player = self.player
	particles.max_damage = damage
	
	# Destroy the bullet
	queue_free()
