extends Entity
class_name Thing

# vars -------------------------------------------------------------------------------------------
export var ONHIT_SELF_DAMAGE = 99
export var RANGE = 100

var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO
var DIRECTION = Vector2.ZERO

export var auto_setup = true
export var auto_rotate = false
export var death_free = false
export(AudioStream) var SPAWN_SOUND
export(AudioStream) var HIT_SOUND
export(AudioStream) var KILL_SOUND
export(AudioStream) var BLOCKED_SOUND
export(AudioStream) var COLLIDE_SOUND
export(AudioStream) var DEATH_SOUND

var SOURCE = null
var SOURCE_PATH = "string"

# get access to other components -----------------------------------------------------------------------------
onready var hitbox = $hitbox
onready var collision = $collision
onready var stats = $stats
onready var sound = $sound

# funcions -------------------------------------------------------------------------------------------
func _init():
	visible = false

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Thing.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	start_pos = SOURCE.global_position
	DIRECTION = start_pos.direction_to(target_pos).normalized()
	SOURCE_PATH = SOURCE.get_path()

func _ready(): 
	# PROBLEM_NOTE I think i could make this a tree_entered (which triggers before ready), put setup() in it,
	# and be able to avoid calling the setup function when new things are added
	global_position = start_pos
	global_position.move_toward(target_pos, 6)
	
	if (
		SPAWN_SOUND == null and
		HIT_SOUND == null and
		KILL_SOUND == null and
		BLOCKED_SOUND == null and
		COLLIDE_SOUND == null and
		DEATH_SOUND == null
		):
			sound.queue_free()
			components["sound_player"] = null
	else:
		var sfx = Sound.new()
		if SPAWN_SOUND != null:
			sfx.name = truName+"_spawn"
			sfx.stream = SPAWN_SOUND
		sound.add_sound(sfx)
		
		if HIT_SOUND != null or KILL_SOUND != null  or BLOCKED_SOUND != null:
			hitbox.connect("hit", self, "hitbox_hit")
	
	if auto_rotate == true: rotation += get_angle_to(target_pos)
	visible = true

func _on_collision_body_entered(body: Node) -> void:
	if visible == false: return
	if body.get_name() == "WorldTiles":
		if COLLIDE_SOUND != null:
			var sfx = Sound.new()
			sfx.stream = COLLIDE_SOUND
			sound.add_sound(sfx)
		
		death_free = true
		death()

func hitbox_hit(area: Area2D, type: String):
	# PROBLEM_NOTE: maybe find some way to put this in the player script or something
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.truName == "player":
		OS.delay_msec(10)
	
	var sfx = Sound.new()
	
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
			return
	
	sound.add_sound(sfx)
