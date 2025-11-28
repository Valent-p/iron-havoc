extends Node3D

@onready var hp_pu_scn = preload("res://entities/powerups/health/health_pu.tscn")
@onready var map_gen = $MapGenerator # Reference to the generator


@onready var bot_scn = preload("res://entities/players/bot/bot_player.tscn")
@onready var user_scn = preload("res://entities/players/user/user_player.tscn")


var players_data = {
	0: { "uuid": 0, "type": "user", "name": "Valentino", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },   
	1: { "uuid": 1, "type": "bot", "name": "James D", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#2: { "uuid": 2, "type": "bot", "name": "Nosey", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#3: { "uuid": 3, "type": "bot", "name": "UrBoy", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#4: { "uuid": 4, "type": "bot", "name": "Stanley", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#5: { "uuid": 5, "type": "bot", "name": "Sb", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#6: { "uuid": 6, "type": "bot", "name": "AngryFace", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#7: { "uuid": 7, "type": "bot", "name": "Mary", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#8: { "uuid": 8, "type": "bot", "name": "Kai", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
	#9: { "uuid": 9, "type": "bot", "name": "Lal", "kills": 0, "dies": 0, "score": 0, "tank": "Assault" },
}

func _ready() -> void:
	# 1. Generate the Map first
	map_gen.generate_world()
	
	# 2. Wait for the signal (Map is built and NavMesh is baked)
	await map_gen.map_ready
	
	# 3. NOW Spawn players
	for p in players_data.values():
		_spawn_entity(p)

# I refactored this into a helper function to use the map's safe spots
func _spawn_entity(p_data: Dictionary):
	# Get a safe position from the map generator
	var safe_pos = map_gen.get_random_empty_position()
	
	var player: Player =  user_scn.instantiate() if p_data.type == "user" else bot_scn.instantiate() 
	get_tree().root.add_child.call_deferred(player)
	player.position = safe_pos
	player.scale *= 0.5
	player.data = p_data
	
func player_die_listener(player: Player):
	players_data[player.last_attacker.data.uuid].kills += 1
	players_data[player.last_attacker.data.uuid].score += 10
	
	players_data[player.data.uuid].dies += 1
	players_data[player.data.uuid].score = max(players_data[player.data.uuid].score - 3, 0)
	
	# Respawn logic
	_spawn_entity(players_data[player.data.uuid])

func _on_pu_timer_timeout() -> void:
	var hp: Powerup = hp_pu_scn.instantiate()
	add_child(hp)
	
	# Use the map generator to find a valid spot for powerups too!
	# No more spawning inside walls.
	hp.global_position = map_gen.get_random_empty_position()
	hp.scale *= 0.5
