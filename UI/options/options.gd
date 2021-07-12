extends Control

onready var sound_player = $sound_player
onready var tabs = $tabs
onready var smooth = $tabs/Visual/smooth
onready var hidebar = $tabs/Visual/hidebar
onready var fullscreen = $tabs/Visual/fullscreen
onready var perfection = $tabs/Game/perfection
onready var pixel = $tabs/Visual/pixel
onready var volume = $tabs/Audio/volume
onready var volume_label = $tabs/Audio/volume_label

signal closed

func multi_color_set(target:Control, color:Color):
	target.set_deferred("custom_colors/font_color", color)
	target.set_deferred("custom_colors/font_color_pressed", color)
	target.set_deferred("custom_colors/font_color_hover", color)

func _on_tabs_visibility_changed() -> void:
	smooth.pressed = global.settings["smooth_camera"]
	hidebar.pressed = global.settings["hide_bar"]
	fullscreen.pressed = global.settings["fullscreen"]
	perfection.pressed = global.settings["perfection_mode"]
	pixel.pressed = global.settings["pixel_perfect"]
	volume.value = global.settings["volume"] * 100
	
	if visible == false: return
	tabs.current_tab = 0
	smooth.grab_focus()

func _on_volume_value_changed(value: float) -> void:
	volume_label.text = "Volume ("+str(value)+"%)"
	# PROBLEM_NOTE: maybe make a smart_slider that does the above line automatically
	# maybe it could also use a texture progress somehow to look a little nicer
	AudioServer.set_bus_volume_db(0, linear2db(value/100))

func _on_exit_pressed() -> void:
	global.settings["smooth_camera"] = smooth.pressed
	global.settings["hide_bar"] = hidebar.pressed
	global.settings["fullscreen"] = fullscreen.pressed
	global.settings["perfection_mode"] = perfection.pressed
	global.settings["pixel_perfect"] = pixel.pressed
	global.settings["volume"] = volume.value / 100
	
	global.update_settings()
	
	visible = false
	emit_signal("closed")

func _on_tabs_tab_changed(tab: int) -> void:
	sound_player.create_sound(smooth.click_sound, true, Sound.MODES.ONESHOT, true, true)
