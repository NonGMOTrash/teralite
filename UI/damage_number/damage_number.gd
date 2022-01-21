extends Node2D

const HURT_COLOR := Color(0.95, 0.2, 0.2)
const HURT_SHADOW := Color(0.48, 0.15, 0.33)
const BLOCK_COLOR := Color(0.2, 0.48, 0.95)
const BLOCK_SHADOW := Color(0.11, 0.11, 0.52)
const HEAL_COLOR := Color(0.37, 0.91, 0.24)
const HEAL_SHADOW := Color(0.36, 0.39, 0.07)

var type: String = "hurt"
var amount: int = 1

onready var label: Label = $Label

func _ready() -> void:
	$AnimationPlayer.playback_speed = 1.0 + (amount / 8.0)
	
	label.text = str(amount)
	match type:
		"hurt":
			label.add_color_override("font_color", HURT_COLOR)
			label.add_color_override("font_color_shadow", HURT_SHADOW)
		"block":
			label.add_color_override("font_color", BLOCK_COLOR)
			label.add_color_override("font_color_shadow", BLOCK_SHADOW)
		"heal":
			label.add_color_override("font_color", HEAL_COLOR)
			label.add_color_override("font_color_shadow", HEAL_SHADOW)
	
