extends Node3D

@onready var bot_scn = preload("res://entities/players/bot/bot_player.tscn")

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
	if _can_spawn:
		_can_spawn = false
		
		_spawn()

func _spawn():
	var bot: BotPlayer =  bot_scn.instantiate()
	get_tree().root.add_child(bot)
	bot.global_position = global_position
	bot.scale *= 0.5 

func _on_spawn_timer_timeout() -> void:
	_can_spawn = true
