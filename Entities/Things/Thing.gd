extends Entity
class_name Thing

# vars -------------------------------------------------------------------------------------------
export var ONHIT_SELF_DAMAGE = 1
export var RANGE = 450

var start_pos = Vector2.ZERO
var target_pos = Vector2.ZERO
var DIRECTION = Vector2.ZERO

export var auto_setup = true
export var auto_rotate = false
export var sprite_persist = false # wheither the sprite will stay until an animation finishes

var SOURCE = null

# get access to other components -----------------------------------------------------------------------------
onready var hitbox = $hitbox
onready var collision = $collision
onready var stats = $stats

# funcions -------------------------------------------------------------------------------------------
func _init():
	visible = false

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Thing.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	DIRECTION = global_position.direction_to(target_pos).normalized()
	start_pos = SOURCE.global_position

func _ready(): 
	# PROBLEM_NOTE I think i could make this a tree_entered (which triggers before ready), put setup() in it,
	# and be able to avoid calling the setup function when new things are added
	global_position = start_pos
	global_position.move_toward(target_pos, 6)
	if auto_rotate == true: rotation += get_angle_to(target_pos)
	visible = true
