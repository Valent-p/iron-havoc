@abstract class_name Player
extends CharacterBody3D

## Current health
var health: int = 100

## Currently equipped tanks
var tank: Tank

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		health = 0
		
		# The kill
		# TODO: This is to temporarily make UserPlayer non killable, remove
		if not self.is_in_group("UserPlayer"):
			queue_free()
