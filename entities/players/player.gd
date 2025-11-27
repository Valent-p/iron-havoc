@abstract class_name Player
extends CharacterBody3D

var _explosion_scn: PackedScene = preload("res://entities/particles/tank_explosion.tscn")

## Current health
var _health: int = 100

## Currently equipped tanks
var tank: Tank

## Data used for networking, here stored locally
var data: Dictionary

## Who attacked last. Useful to determine the killer.
var last_attacker: Player

## Returns true if dead, else false
@abstract func take_damage(value: int, attacker: Player) -> bool

func heal(value: int):
	_health = min(value + _health, tank.health_max)

## Die by exploding
func die():
	var explosion: Node3D = _explosion_scn.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = global_position
	
	# Report to game manager
	get_tree().root.get_child(0).player_die_listener(self)
	
	queue_free()

## Get current health
func get_health():
	return _health
