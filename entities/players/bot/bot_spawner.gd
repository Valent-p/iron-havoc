extends Node3D

@onready var bot_scn = preload("res://entities/players/bot/bot_player.tscn")
@onready var user_scn = preload("res://entities/players/user/user_player.tscn")

var _can_spawn = true

## Time interval between spawns.
@export var time_interval = 5.0

## How many bots must exist to pause spawning.
@export var bots_limit = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.autostart = true
	$SpawnTimer.wait_time = time_interval

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return 
	
	#if _can_spawn:
	#	_can_spawn = false
	#	
	#	spawn()

func spawn(player_data: Dictionary):
	print("Spawning... ", player_data)
	var player: Player =  user_scn.instantiate() if player_data.type == "user" else bot_scn.instantiate() 
	get_tree().root.add_child.call_deferred(player)
	player.position = position
	player.scale *= 0.5
	player.data = player_data

func _on_spawn_timer_timeout() -> void:
	_can_spawn = true
