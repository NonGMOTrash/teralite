extends Entity
class_name Attack

export var ONHIT_SELF_DAMAGE = 99
export var RANGE = 100

var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO
var DIRECTION = Vector2.ZERO

export var auto_setup = true
export var auto_rotate = true
export var death_free = false
export(AudioStream) var SPAWN_SOUND
export(AudioStream) var HIT_SOUND
export(AudioStream) var KILL_SOUND
export(AudioStream) var BLOCKED_SOUND
export(AudioStream) var COLLIDE_SOUND
export(AudioStream) var KILLED_SOUND

var SOURCE: Entity
var SOURCE_PATH: NodePath
var hit_pause_count: int = 0

onready var hitbox: Area2D = $hitbox
onready var collision: Area2D = $collision
onready var stats: Node = $stats
onready var sound = $sound

func _init():
	visible = false

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	start_pos = SOURCE.global_position
	DIRECTION = start_pos.direction_to(target_pos).normalized()
	SOURCE_PATH = SOURCE.get_path()

func _ready():
	global_position = start_pos
	global_position.move_toward(target_pos, 6)
	
	if (
		SPAWN_SOUND == null and
		HIT_SOUND == null and
		KILL_SOUND == null and
		BLOCKED_SOUND == null and
		COLLIDE_SOUND == null and
		KILLED_SOUND == null
	):
		sound.queue_free()
		components["sound_player"] = null
	elif SPAWN_SOUND != null:
		var sfx = Sound.new()
		sfx.name = truName+"_spawn"
		sfx.stream = SPAWN_SOUND
		sound.add_sound(sfx)
		
		#if HIT_SOUND != null or KILL_SOUND != null  or BLOCKED_SOUND != null:
		#	hitbox.connect("hit", self, "hitbox_hit")
	
	if auto_rotate == true:
		look_at(target_pos)
	
	if not "recoiled" in self: # check if im a Melee
		visible = true

func _on_collision_body_entered(body: Node) -> void:
	if visible == false:
		return
	
	if body.get_name() == "world_tiles":
		if COLLIDE_SOUND != null:
			var sfx = Sound.new()
			sfx.name = truName+"_collide"
			sfx.stream = COLLIDE_SOUND
			sound.add_sound(sfx)
		
		death_free = true
		death()

func _on_hitbox_hit(area, type) -> void:
	# PROBLEM_NOTE: maybe find some way to put this in the player script or something
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.truName == "player" and hit_pause_count < 2:
		OS.delay_msec((1 / 60.0) * 1000)
		hit_pause_count += 1
	
	if HIT_SOUND == null and BLOCKED_SOUND == null and KILL_SOUND == null:
		return
	
	var sfx := Sound.new()
	
	match type:
		"hurt":
			sfx.name = truName+"_hit"
			sfx.stream = HIT_SOUND
		"killed":
			sfx.name = truName+"_kill"
			sfx.stream = KILL_SOUND
		"block":
			sfx.name = truName+"_blocked"
			sfx.stream = BLOCKED_SOUND
		_:
			sfx.name == truName+"_invalid_type"
			return
	
	if sfx.stream == null:
		sfx.queue_free()
	else:
		sound.add_sound(sfx)

func _on_stats_health_changed(type, result, net) -> void:
	if type == "killed":
		var sfx := Sound.new()
		sfx.stream = KILLED_SOUND
		sound.add_sound(sfx)

func death():
	emit_signal("death")
