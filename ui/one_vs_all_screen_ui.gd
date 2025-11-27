extends Control

@onready var you_ui = $TextureRect/FlowContainer/YouPoints
@onready var other_ui = $TextureRect/FlowContainer/OtherPoints

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	you_ui.text = "You 0"
	other_ui.text = "Other 0"

func update_you_score(new_score: int):
	other_ui.text = "You %s" % [str(new_score)]

func update_other_score(new_score: int):
	other_ui.text = "Other %s" % [str(new_score)]
