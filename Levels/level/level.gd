extends Navigation2D

enum TYPES {CUSTOM = -1, NONE, AUTUMN, UNDERGROUND, WASTELAND, OFFWORLD, SITE}

export(TYPES) var AMBIANCE = TYPES.AUTUMN
export(TYPES) var GLOBAL_PARTICLES = TYPES.AUTUMN
export(TYPES) var AMBIENT_LIGHTING = TYPES.AUTUMN
export var FORCE_SLEEP_UNTIL_VISIBLE = false

export(String) var WORLD := "A"
export(String) var DISPLAY_NAME := ""
const LEVEL_TYPE := 0 # PROBLEM_NOTE: make this a string

var update_particles := true
var has_particles := true
var spawn_paused := false

onready var particle_anchor: Node2D = $particle_anchor
onready var particles: Particles2D = $particle_anchor/particles
onready var ambient_lighting: CanvasModulate = $ambient_lighting

func _ready() -> void:
	if name != "test_level":
		global.write_save(global.save_name, global.get_save_data_dict())
	
	refs.update_ref("level", self)
	refs.update_ref("canvas_layer", $CanvasLayer)
	refs.update_ref("ysort", $YSort)
	refs.update_ref("background", $background)
	refs.update_ref("background_tiles", $YSort/background_tiles)
	refs.update_ref("ambient_lighting", $ambient_lighting)
	refs.update_ref("vignette", $CanvasLayer/vignette)
	
	var deaths: int = 1
	if get_name() in global.level_deaths:
		deaths = global.level_deaths[get_name()] + 1
	var suffix: String = "th"
	match deaths % 10:
		1: suffix = "st"
		2: suffix = "nd"
		3: suffix = "rd"
	global.set_discord_activity("in " + get_name().to_lower(),
			"dying for the " + str(deaths) + suffix + " time")
	
	if global.settings["spawn_pause"] == true:
		refs.camera.pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = true
		spawn_paused = true
	
	if global.settings["particles"] != 3:
		update_particles = false
		set_physics_process(false)
		particles.visible = false
		particles.emitting = false
	
	match GLOBAL_PARTICLES:
		TYPES.AUTUMN:
			particles.amount = 100
			particles.lifetime = 18
			particles.preprocess = 15
			particles.process_material = load("res://Levels/level/autumn_particles.tres")
			particles.texture = load("res://Levels/level/leaf.png")
		_:
			update_particles = false
			set_physics_process(false)
			particle_anchor.queue_free()
			has_particles = false
	
	if global.last_ambiance == AMBIANCE:
		return
	else:
		var old_ambiance
		for global_sound in global.get_children():
			if global_sound.name == "ambiance":
				old_ambiance = global_sound
				break
		
		if old_ambiance != null:
			old_ambiance.free()
		
	var ambiance = Global_Sound.new()
	ambiance.volume_db = 0.2
	ambiance.name = "ambiance"
	ambiance.SCENE_PERSIST = true
	ambiance.autoplay = true
	ambiance.pause_mode = PAUSE_MODE_PROCESS
	ambiance.MODE = Sound.MODES.REPEATING
	ambiance.bus = "ambiance"
	
	match AMBIANCE:
		TYPES.NONE: pass
		TYPES.AUTUMN: ambiance.stream = load("res://Levels/level/forest_ambiance.ogg")
		TYPES.UNDERGROUND: ambiance.stream = load("res://Levels/level/cave_ambiance.ogg")
		TYPES.WASTELAND: ambiance.stream = load("res://Levels/level/wasteland_ambience.ogg")
		TYPES.OFFWORLD: ambiance.stream = load("res://Levels/level/offworld_ambiance.ogg")
	
	global.add_child(ambiance)
	refs.update_ref("ambiance", ambiance)
	
	if global.settings["ambient_lighting"] == false:
		ambient_lighting.visible = false
	else:
		match AMBIENT_LIGHTING:
			TYPES.NONE, TYPES.AUTUMN:
				ambient_lighting.color = Color.white
			TYPES.UNDERGROUND:
				ambient_lighting.color = Color(0.55, 0.55, 0.8)
			TYPES.WASTELAND:
				ambient_lighting.color = Color(1.4, 0.9, 0.7)
			TYPES.OFFWORLD:
				ambient_lighting.color = Color(1.0, 0.72, 0.9)
			TYPES.SITE:
				ambient_lighting.color = Color.white
	
	var hud_elements := [refs.health_ui, refs.item_bar, refs.item_info, refs.stopwatch]
	for element in hud_elements:
		if is_instance_valid(element):
			element.visible = global.settings["show_hud"]

func pathfind(start:Vector2, end:Vector2) -> PoolVector2Array:
	var path := get_simple_path(start, get_closest_point(end), true)
	
	if path.size() == 0:
		return path
	
	return path

func _physics_process(delta: float) -> void:
	if update_particles == true:
		var player = refs.player
		if is_instance_valid(player):
			particle_anchor.position = to_local(player.global_position)
			if player.velocity != Vector2.ZERO:
				particle_anchor.position += player.velocity * 2
			particle_anchor.position.y -= 216

func _input(event: InputEvent) -> void:
	if spawn_paused == false:
		return
	elif not event is InputEventMouse and not event is InputEventJoypadMotion:
		get_tree().paused = false
		spawn_paused = false
		refs.camera.pause_mode = PAUSE_MODE_STOP
