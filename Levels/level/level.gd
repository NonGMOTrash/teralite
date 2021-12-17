extends Navigation2D

enum TYPES {NONE, AUTUMN, UNDERGROUND}

export(TYPES) var AMBIANCE = TYPES.AUTUMN
export(TYPES) var GLOBAL_PARTICLES = TYPES.AUTUMN
export var FORCE_SLEEP_UNTIL_VISIBLE = false

export(String) var WORLD := "A"
const LEVEL_TYPE := 0 # PROBLEM_NOTE: make this a string

var update_particles := true
var has_particles := true
var spawn_paused := false

onready var particle_anchor: Node2D = $particle_anchor
onready var particles: Particles2D = $particle_anchor/particles

func _ready() -> void:
	if name != "test_level":
		global.write_save(global.save_name, global.get_save_data_dict())
	
	refs.level = weakref(self)
	refs.canvas_layer = weakref($CanvasLayer)
	refs.ysort = weakref($YSort)
	refs.background = weakref($background)
	refs.background_tiles = weakref($YSort/background_tiles)
	
	if global.settings["spawn_pause"] == true:
		refs.camera.get_ref().pause_mode = PAUSE_MODE_PROCESS
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
	
	if global.last_ambiance == AMBIANCE: return
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
	
	match AMBIANCE:
		TYPES.AUTUMN: ambiance.stream = load("res://Levels/level/forest_ambiance.ogg")
		TYPES.UNDERGROUND: ambiance.stream = load("res://Levels/level/cave_ambiance.ogg")
		_: return
	
	global.add_child(ambiance)
	refs.ambiance = weakref(ambiance)
	
	# prevent freeze when this is loaded
	res.allocate("hit_effect")
	res.allocate("item_pickup_effect")

func pathfind(start:Vector2, end:Vector2) -> PoolVector2Array:
	var path := get_simple_path(start, get_closest_point(end), true)
	
	if path.size() == 0:
		return path
	
	return path

func _physics_process(delta: float) -> void:
	if update_particles == true:
		var player = refs.player.get_ref()
		if player != null:
			particle_anchor.position = to_local(player.global_position)
			if player.velocity != Vector2.ZERO:
				particle_anchor.position += player.velocity * 2
			particle_anchor.position.y -= 216

func _on_level_tree_exiting() -> void:
	global.total_time += refs.stopwatch.get_ref().time
	global.speedrun_time += refs.stopwatch.get_ref().time

func _input(event: InputEvent) -> void:
	if spawn_paused == false:
		return
	elif not event is InputEventMouse and not event is InputEventJoypadMotion:
		get_tree().paused = false
		spawn_paused = false
		refs.camera.get_ref().pause_mode = PAUSE_MODE_STOP
