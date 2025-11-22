extends Node3D

@onready var bullet_scene: PackedScene = preload("res://entities/projectiles/bullet.tscn")

@onready var muzzle = $Muzzle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		muzzle.reparent($Model/pipe_cup, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fire_bullet():
	# 1. Create the bullet
	var bullet = bullet_scene.instantiate()
		
	# 2. Add it to the MAIN SCENE, not the tank.
	# If you add it to the tank, the bullet will move/rotate with the tank.
	get_tree().root.add_child(bullet)

	# 3. Set position and rotation to match the muzzle
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
