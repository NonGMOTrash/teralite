extends Button

export var selected_color = Color8(242, 211, 53)
export var normal_color = Color8(255, 255, 255)
export(AudioStream) var hover_sound
export(AudioStream) var click_sound

onready var sound_player = $sound_player

func _ready() -> void:
	color_set(normal_color)
	if hover_sound == null and click_sound == null:
		sound_player.queue_free()
	
func color_set(color):
	set_deferred("custom_colors/font_color", color)
	set_deferred("custom_colors/font_color_pressed", color)
	set_deferred("custom_colors/font_color_hover", color)

func _on_SmartButton_focus_entered() -> void:
	color_set(selected_color)
	if sound_player != null and hover_sound != null:
		sound_player.create_sound(hover_sound,true, Sound.MODES.ONESHOT,true,true,true, 0.0, "menu")

func _on_SmartButton_focus_exited() -> void:
	color_set(normal_color)

func _on_SmartButton_mouse_entered() -> void:
	grab_focus()

func _on_SmartButton_pressed() -> void:
	if click_sound != null:
		sound_player.create_sound(click_sound,true, Sound.MODES.ONESHOT,true,true,true, 0.0, "menu")
