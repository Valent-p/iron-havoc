extends Node3D

var peer = ENetMultiplayerPeer.new()

@export var player_scene: PackedScene
@onready var spawner = $MultiplayerSpawner

@onready var spawn_points = $SpawnPoints

func _ready() -> void:
	spawner.spawn_function = _spawn_custom_player

func  _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	_on_peer_connected(1)
	$CanvasLayer.queue_free()
	

func _on_join_pressed():
	peer.create_client("127.0.0.1", 135)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.queue_free()
	
func _on_peer_connected(id):
	spawner.spawn(id)

func _spawn_custom_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	
	if spawn_points:
		var index = get_tree().get_nodes_in_group("Players").size() % spawn_points.get_child_count()
		var spawn_node = spawn_points.get_child(index)
		player.position = spawn_node.global_position
		player.rotation = spawn_node.global_rotation
	
	player.set_multiplayer_authority(id)
	return player
