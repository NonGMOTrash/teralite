extends ColorRect

const yellow = Color8(242, 211, 53)
const white = Color8(255, 255, 255)
export(AudioStream) var PAUSE_SOUND
export(AudioStream) var UNPAUSE_SOUND

onready var resume = $items/resume
onready var options = $items/options
onready var return_to = $items/return_to
onready var quit = $items/quit
onready var pause_menu = $items
onready var options_menu = $Options
onready var sound_player = $sound_player

signal paused
signal unpaused

func _ready():
	global.nodes["pause_menu"] = self
	if get_tree().current_scene.LEVEL_TYPE == 1: 
		return_to.text = "Return to Titlescreen"
	
	visible = false
	pause_menu.visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible
		pause_menu.visible = visible
		if visible == true:
			global.emit_signal("paused")
			resume.grab_focus()
			Input.set_custom_mouse_cursor(global.CURSOR_NORMAL, Input.CURSOR_ARROW, Vector2(0, 0))
			sound_player.create_sound(PAUSE_SOUND, true)
		else:
			global.emit_signal("unpaused")
			global.update_cursor()
			sound_player.create_sound(UNPAUSE_SOUND, true, Sound.MODES.ONESHOT, true, true)

func multi_color_set(target:Control, color:Color):
	target.set_deferred("custom_colors/font_color", color)
	target.set_deferred("custom_colors/font_color_pressed", color)
	target.set_deferred("custom_colors/font_color_hover", color)

func _on_resume_pressed() -> void:
	visible = false
	pause_menu.visible = false
	get_tree().paused = false
	global.emit_signal("unpaused")
	global.update_cursor()
	sound_player.create_sound(UNPAUSE_SOUND, true)

func _on_options_pressed() -> void:
	pause_menu.visible = false
	options_menu.visible = true

func _on_return_to_pressed() -> void:
	get_tree().paused = false
	if get_tree().current_scene.LEVEL_TYPE == 1: 
		global.player_hub_pos = global.get_node(global.nodes["player"]).global_position
		global.write_save(global.save_name, global.get_save_data_dict())
		
		for sound in global.get_children():
			if sound.name == "ambiance":
				sound.free()
				break
		
		get_tree().change_scene_to(load("res://UI/title_screen/title_screen.tscn"))
	else: 
		get_tree().change_scene_to(load("res://Levels/A/A-Hub.tscn")) 
		# PROBLEM_NOTE: this ^^ won't work with multiple hubs

func _on_quit_pressed() -> void:
	if get_tree().current_scene.LEVEL_TYPE == 1: 
		global.player_hub_pos = global.get_node(global.nodes["player"]).global_position
		global.write_save(global.save_name, global.get_save_data_dict())
	get_tree().quit()

func _on_Options_closed() -> void:
	visible = true
	pause_menu.visible = true
