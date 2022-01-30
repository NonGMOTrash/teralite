extends CheckBox

export var selected_color = Color8(242, 211, 53)
export var normal_color = Color8(255, 255, 255)
export(AudioStream) var hover_sound
export(AudioStream) var unhover_sound
export(AudioStream) var click_sound

onready var sound_player = $sound_player

func _ready() -> void:
	color_set(normal_color)
	
func color_set(color):
	set_deferred("custom_colors/font_color", color)
	set_deferred("custom_colors/font_color_focus", color)
	set_deferred("custom_colors/font_color_pressed", color)
	set_deferred("custom_colors/font_color_hover", color)

func _on_SmartCheckbox_focus_entered() -> void:
	color_set(selected_color)
	if sound_player != null and hover_sound != null:
		sound_player.create_sound(hover_sound, true, Sound.MODES.ONESHOT, true, true)

func _on_SmartCheckbox_focus_exited() -> void:
	color_set(normal_color)
	if unhover_sound != null:
		sound_player.create_sound(unhover_sound, true, Sound.MODES.ONESHOT, true, true)

func _on_SmartCheckbox_mouse_entered() -> void:
	grab_focus()

func _on_SmartCheckbox_button_down() -> void:
	if click_sound != null:
		sound_player.create_sound(click_sound, true, Sound.MODES.ONESHOT, true, true)
#
#func _make_custom_tooltip(for_text: String) -> Control:
#	var container := Panel.new()
#	container.size_flags_horizontal = container.SIZE_EXPAND_FILL
#	container.size_flags_vertical = container.SIZE_FILL
#	var label := Label.new()
#	label.text = hint_tooltip
#	label.autowrap = true
#	container.add_child(label)
#	return container
