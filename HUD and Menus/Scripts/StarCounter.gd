extends Control

onready var label = $Label

func _ready() -> void:
	label.text = "Stars: " + str(global.stars)
