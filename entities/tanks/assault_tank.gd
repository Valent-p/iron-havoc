extends Tank

@onready var bullet_scene: PackedScene = preload("res://entities/projectiles/bullet.tscn")

@onready var muzzle = $Muzzle
@onready var muzzle_raycast = $Muzzle/RayCast3D
@onready var model_left = $Model/left
@onready var model_right = $Model/right
@onready var model_base = $Model/base
@onready var model_pipe = $Model/pipe
@onready var model_pipe_cup = $Model/pipe_cup
@onready var model_turret_mount = $Model/turret_mount

## The owner
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		muzzle.reparent(model_pipe_cup, true)
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	'''
	# Ensure the raycast is enabled
	muzzle_raycast.enabled = true
	# Update the raycast (if its position or target changes)
	muzzle_raycast.force_raycast_update()

	if muzzle_raycast.is_colliding():
		var collider: Object = muzzle_raycast.get_collider()
		var collision_point: Vector3 = muzzle_raycast.get_collision_point()
		print("Ray hit: ", collider.name, " at ", collision_point)
	else:
		print("Ray not colliding.")
	'''
	
	

func fire_bullet():
	# 1. Create the bullet
	var bullet = bullet_scene.instantiate()
		
	# 2. Add it to the MAIN SCENE, not the tank.
	# If you add it to the tank, the bullet will move/rotate with the tank.
	get_tree().root.add_child(bullet)

	# 3. Set position and rotation to match the muzzle
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
	
	# 4. Setting argues
	bullet.player = player
