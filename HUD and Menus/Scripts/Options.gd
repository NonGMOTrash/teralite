extends TabContainer

onready var smooth = $Options/smooth
onready var hidebar = $Options/hidebar
onready var fullscreen = $Options/fullscreen
onready var perfection = $Options/perfection
onready var pixel = $Options/pixel

signal closed

func multi_color_set(target:Control, color:Color):
	target.set_deferred("custom_colors/font_color", color)
	target.set_deferred("custom_colors/font_color_pressed", color)
	target.set_deferred("custom_colors/font_color_hover", color)

func _on_Options_visibility_changed() -> void:
	smooth.pressed = global.settings["smooth_camera"]
	hidebar.pressed = global.settings["hide_bar"]
	fullscreen.pressed = global.settings["fullscreen"]
	perfection.pressed = global.settings["perfection_mode"]
	pixel.pressed = global.settings["pixel_perfect"]
	
	if visible == false: return
	current_tab = 0
	smooth.grab_focus()

func _on_exit_pressed() -> void:
	global.settings["smooth_camera"] = smooth.pressed
	global.settings["hide_bar"] = hidebar.pressed
	global.settings["fullscreen"] = fullscreen.pressed
	global.settings["perfection_mode"] = perfection.pressed
	global.settings["pixel_perfect"] = pixel.pressed
	
	OS.window_fullscreen = fullscreen.pressed
	if global.settings["pixel_perfect"] == true:
			get_tree().set_screen_stretch(
					SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(384, 216)
				)
	else:
		get_tree().set_screen_stretch(
					SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(384, 216)
				)
	
	var camera = get_tree().current_scene
	if camera == null: global.debug_msg(self, 0, "could not find current_scene")
	else: camera = camera.find_node("Camera")
	if camera == null: global.debug_msg(self, 0, "could not find Camera")
	else: camera = camera.find_node("Camera2D")
	if camera == null: global.debug_msg(self, 0, "could not find Camera2D")
	else:
		camera.smoothing_enabled = global.settings["smooth_camera"]
		camera.limit_smoothed = global.settings["smooth_camera"]
	
	var item_bar = get_tree().current_scene
	if item_bar == null: global.debug_msg(self, 0, "could not find current_scene")
	else: item_bar = item_bar.find_node("CanvasLayer")
	if item_bar == null: global.debug_msg(self, 0, "could not find CanvasLayer")
	else: item_bar = item_bar.find_node("itemBar")
	if item_bar == null: global.debug_msg(self, 0, "could not find itemBar")
	else:
		if global.players_path == null: return
		var player = get_node_or_null(global.players_path)
		if player == null: return
		var inventory = player.inventory
		if global.settings["hide_bar"]==true and inventory[0]==null and inventory[1]==null and inventory[2]==null:
			item_bar.visible = false
		else:
			item_bar.visible = true
	
	
	var settings_config = File.new()
	
	if settings_config.file_exists("user://settings_config"):
		var error = settings_config.open("user://settings_config", File.WRITE)
		
		if error == OK:
			# load works
			settings_config.store_var(global.settings)
			settings_config.close()
		else:
			# load failed
			global.debug_msg(self, 0, "could not find settings_config (on save)")
	
	visible = false
	emit_signal("closed")
