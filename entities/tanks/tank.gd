@abstract class_name Tank
extends Node3D

## Base damage can deal
var damage: float = 10

## Maximum health points
var health_max: float = 100 

## Maximum speed when moving
var speed_max: float = 200

@abstract func fire_primary()
@abstract func fire_secondary()
