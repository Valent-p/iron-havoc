extends Area3D
class_name HitboxComponent

@export var health_component: HealthComponent

func hit(damage_amount):
	if health_component:
		health_component.damage(damage_amount)
