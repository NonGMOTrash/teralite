extends Node2D

enum TYPES {CUSTOM = -1, NONE, AUTUMN, UNDERGROUND, WASTELAND, OFFWORLD}

export(TYPES) var AMBIANCE = TYPES.AUTUMN
export(TYPES) var GLOBAL_PARTICLES = TYPES.AUTUMN
export(TYPES) var AMBIENT_LIGHTING = TYPES.AUTUMN
export(String) var LETTER := "A"

var update_particles := true
var has_particles := true

const LEVEL_TYPE = 1

onready var particle_anchor: Node2D = $particle_anchor
onready var particles: Particles2D = $particle_anchor/particles
onready var timer: Timer = $Timer
onready var ambient_lighting: CanvasModulate = $ambient_lighting


func _ready() -> void:
	refs.update_ref("level", self)
	refs.update_ref("canvas_layer", $CanvasLayer)
	refs.update_ref("ysort", $YSort)
	refs.update_ref("background", $background)
	refs.update_ref("background_tiles", $YSort/background_tiles)
	refs.update_ref("ambient_lighting", $ambient_lighting)
	
	$Camera.pause_mode = PAUSE_MODE_INHERIT
	
	global.last_hub = get_tree().current_scene.LETTER
	if not (global.save_name == "untitled_save" and global.stars == 0):
		global.write_save(global.save_name, global.get_save_data_dict())
	global.emit_signal("update_health")
	
	var player = $YSort.find_node("player")
	if player == null: 
		push_warning("could not find player")
	else:
		var pos: Vector2
		if global.player_hub_pos is Dictionary && global.player_hub_pos.has(LETTER):
			pos = global.player_hub_pos[LETTER]
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
	
	if global.last_ambiance != AMBIANCE:
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
	ambiance.volume_db = 0.4
	ambiance.name = "ambiance"
	ambiance.SCENE_PERSIST = true
	ambiance.autoplay = true
	ambiance.pause_mode = PAUSE_MODE_PROCESS
	ambiance.MODE = Sound.MODES.REPEATING
	ambiance.bus = "ambiance"
	
	match AMBIANCE:
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
				ambient_lighting.color = Color(1, 1, 1)
			TYPES.UNDERGROUND:
				ambient_lighting.color = Color(0.6, 0.6, 0.6)
			TYPES.WASTELAND:
				ambient_lighting.color = Color(1, 1, 0.7)
			TYPES.OFFWORLD:
				ambient_lighting.color = Color(1.0, 0.72, 0.9)
	
	match LETTER:
		"A": global.set_discord_activity("in autumn hub", "(chillin)")
		"B": global.set_discord_activity("in underground hub", "(calm before the storm)")
		"C": global.set_discord_activity("in wasteland hub", "(contemplating life)")

func _physics_process(_delta: float) -> void:
	if update_particles == true:
		var player = refs.player
		if player != null:
			particle_anchor.position = to_local(player.global_position)
			if player.velocity != Vector2.ZERO:
				particle_anchor.position += player.velocity * 2
			particle_anchor.position.y -= 216

func _on_hub_tree_exiting() -> void:
	global.total_time += timer.wait_time - timer.time_left
