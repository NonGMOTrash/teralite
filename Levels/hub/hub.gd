extends Node2D

enum TYPES {NONE, AUTUMN, UNDERGROUND}

export(TYPES) var AMBIANCE = TYPES.AUTUMN
export(TYPES) var GLOBAL_PARTICLES = TYPES.AUTUMN
export(String) var LETTER := "A" 

var update_particles := true
var has_particles := true

const LEVEL_TYPE = 1

onready var particle_anchor: Node2D = $particle_anchor
onready var particles: Particles2D = $particle_anchor/particles
onready var timer: Timer = $Timer

func _ready() -> void:
	refs.level = weakref(self)
	refs.canvas_layer = weakref($CanvasLayer)
	refs.ysort = weakref($YSort)
	refs.background = weakref($Background)
	refs.background_tiles = weakref($YSort/background_tiles)
	
	global.last_hub = get_tree().current_scene.LETTER
	if not (global.save_name == "untitled_save" and global.stars == 0):
		global.write_save(global.save_name, global.get_save_data_dict())
	global.emit_signal("update_health")
	
	var player = $YSort.find_node("player")
	if player == null: 
		push_warning("could not find player")
	else:
		var pos = global.player_hub_pos.get(LETTER)
		if pos != null and pos != Vector2.ZERO:
			player.global_position = global.player_hub_pos[LETTER]
	
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
		# PROBLEM_NOTE: not sure why i have to do this instead of find_node(), maybe a bug with godot
		# (this same thing is also done in level.gd)
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

func _physics_process(_delta: float) -> void:
	if update_particles == true:
		var player = refs.player.get_ref()
		if player != null:
			particle_anchor.position = to_local(player.global_position)
			if player.velocity != Vector2.ZERO:
				particle_anchor.position += player.velocity * 2
			particle_anchor.position.y -= 216

func _on_hub_tree_exiting() -> void:
	global.total_time += 9999.0 - timer.time_left
