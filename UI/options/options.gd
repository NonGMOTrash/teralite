extends Control

onready var sound_player = $sound_player
onready var tabs = $tabs
onready var exit = $exit

onready var fullscreen = $tabs/video/VBox/fullscreen
onready var pixel = $tabs/video/VBox/pixel
onready var vsync = $tabs/video/VBox/vsync
onready var lighting = $tabs/video/VBox/lighting
onready var shadows = $tabs/video/VBox/shadows
onready var shadow_buffer = $tabs/video/VBox/shadow_buffer
onready var ambient_lighting = $tabs/video/VBox/ambient_lighting
onready var particles = $tabs/video/VBox/particles/dropdown
onready var gpu_snap = $tabs/video/VBox/gpu_snap

onready var master_volume = $tabs/audio/VBox/master_volume
onready var sound_volume = $tabs/audio/VBox/sound_volume
onready var menu_volume = $tabs/audio/VBox/menu_volume
onready var ambiance_volume = $tabs/audio/VBox/ambiance_volume
onready var footsteps_volume = $tabs/audio/VBox/footsteps_volume

onready var perfection = $tabs/game/VBox/perfection
onready var smooth = $tabs/game/VBox/smooth
onready var hidebar = $tabs/game/VBox/hidebar
onready var spawn_pause = $tabs/game/VBox/spawn_pause
onready var damage_numbers = $tabs/game/VBox/damage_numbers
onready var discord = $tabs/game/VBox/discord
onready var show_hud = $tabs/game/VBox/show_hud
onready var brain_sapping = $tabs/game/VBox/brain_sapping
onready var camera_zoom = $tabs/game/VBox/camera_zoom
onready var show_fps = $tabs/game/VBox/show_fps

signal closed

func _ready() -> void:
	visible = false

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
	master_volume.value = global.settings["volume"] * 100
	sound_volume.value = global.settings["sound_volume"] * 100
	menu_volume.value = global.settings["menu_volume"] * 100
	ambiance_volume.value = global.settings["ambiance_volume"] * 100
	footsteps_volume.value = global.settings["footsteps_volume"] * 100
	vsync.pressed = global.settings["vsync"]
	particles.selected = global.settings["particles"]
	spawn_pause.pressed = global.settings["spawn_pause"]
	lighting.pressed = global.settings["lighting"]
	shadows.pressed = global.settings["shadows"]
	shadow_buffer.value = global.settings["shadow_buffer"]
	ambient_lighting.pressed = global.settings["ambient_lighting"]
	damage_numbers.pressed = global.settings["damage_numbers"]
	discord.pressed = global.settings["discord"]
	show_hud.pressed = global.settings["show_hud"]
	brain_sapping.value = global.settings["brain_sapping"]
	camera_zoom.value = global.settings["camera_zoom"]
	show_fps.pressed = global.settings["show_fps"]
	
	if visible == false: return
	tabs.current_tab = 0
	fullscreen.grab_focus()

func _on_volume_value_changed(value: float) -> void:
	master_volume.label.text = "Volume ("+str(value)+"%)"
	# PROBLEM_NOTE: maybe make a smart_slider that does the above line automatically
	# maybe it could also use a texture progress somehow to look a little nicer
	AudioServer.set_bus_volume_db(0, linear2db(value/100))

func _on_exit_pressed() -> void:
	global.settings["smooth_camera"] = smooth.pressed
	global.settings["hide_bar"] = hidebar.pressed
	global.settings["fullscreen"] = fullscreen.pressed
	global.settings["perfection_mode"] = perfection.pressed
	global.settings["pixel_perfect"] = pixel.pressed
	global.settings["volume"] = master_volume.value / 100
	global.settings["sound_volume"] = sound_volume.value / 100
	global.settings["menu_volume"] = menu_volume.value / 100
	global.settings["ambiance_volume"] = ambiance_volume.value / 100
	global.settings["footsteps_volume"] = footsteps_volume.value / 100
	global.settings["vsync"] = vsync.pressed
	global.settings["particles"] = particles.selected
	global.settings["gpu_snap"] = gpu_snap.pressed
	global.settings["spawn_pause"] = spawn_pause.pressed
	global.settings["lighting"] = lighting.pressed
	global.settings["shadows"] = shadows.pressed
	global.settings["shadow_buffer"] = shadow_buffer.value
	global.settings["ambient_lighting"] = ambient_lighting.pressed
	global.settings["damage_numbers"] = damage_numbers.pressed
	global.settings["discord"] = discord.pressed
	global.settings["show_hud"] = show_hud.pressed
	global.settings["brain_sapping"] = brain_sapping.value
	global.settings["camera_zoom"] = camera_zoom.value
	global.settings["show_fps"] = show_fps.pressed
	
	global.update_settings()
	
	visible = false
	emit_signal("closed")

func _on_tabs_tab_changed(tab: int) -> void:
	sound_player.create_sound(smooth.click_sound, true, Sound.MODES.ONESHOT, true, true)
	match tabs.current_tab:
		0: fullscreen.grab_focus()
		1: master_volume.grab_focus()
		2: perfection.grab_focus()

func _input(event: InputEvent) -> void:
	var next_tab: int = tabs.current_tab
	
	if Input.is_action_just_pressed("ui_focus_next"):
		next_tab += 1
	elif Input.is_action_just_pressed("ui_focus_prev"):
		next_tab -= 1
	
	if next_tab > 3:
		next_tab = 0
	elif next_tab < 0:
		next_tab = 3
	
	if next_tab == 3:
		exit.grab_focus()
	else:
		tabs.current_tab = next_tab
