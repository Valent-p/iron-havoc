@abstract class_name Player
extends CharacterBody3D

var _explosion_scn: PackedScene = preload("res://entities/particles/tank_explosion.tscn")

## Current health
var _health: int = 100

## Currently equipped tanks
var tank: Tank

## Returns true if dead, else false
@abstract func take_damage(value: int) -> bool

## Die by exploding
func die():
	var explosion: Node3D = _explosion_scn.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = global_position
	
	queue_free()
