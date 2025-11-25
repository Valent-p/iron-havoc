extends Area3D

@onready var particles_scn = preload("res://entities/particles/bullet_hit_particles.tscn")

var speed: float = 200.0
var damage: int = 10

func _ready():
	# If the bullet flies for 3 seconds without hitting anything, destroy it
	$LifespanTimer.timeout.connect(queue_free)
	
	# Connect the collision signal
	body_entered.connect(_on_body_entered)
	

func _physics_process(delta: float) -> void:
	# Move forward (local -Z axis)
	position -= transform.basis.z * speed * delta

func _on_body_entered(body: Node3D):
	# Don't hit ourselves (optional check, mostly handled by layers later)
	# But we usually want to ignore the shooter if possible.
	
	# Check if the object we hit has a 'take_damage' function
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Create an explosion effect here if you have one
	var particles: GPUParticles3D = particles_scn.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.one_shot = true
	#particles.process_material.scale_max = 0.1
	
	
	# Destroy the bullet
	queue_free()
