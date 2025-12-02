extends Node
class_name HealthComponent

signal on_died
signal on_health_changed(current, max)

@export var max_health: float = 100.0
var current_health: float = 100.0:
	set(value):
		current_health = value
		on_health_changed.emit(current_health, max_health)
		if current_health <= 0 and multiplayer.is_server():
			on_died.emit()

func damage(amount):
	current_health -= amount
