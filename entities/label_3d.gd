extends Label3D

# Assign the HealthComponent in Inspector
@export var health_component: HealthComponent 

func _ready():
	# Update text immediately
	update_text(health_component.current_health, health_component.max_health)
	
	# Listen for changes
	health_component.on_health_changed.connect(update_text)

func update_text(current, max_hp):
	text = str(round(current)) + " HP"
	
	# Change color based on health
	if current < max_hp * 0.3:
		modulate = Color.RED
	else:
		modulate = Color.WHITE
