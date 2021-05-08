extends KinematicBody2D
class_name Entity

export var STATIC = false
export var ACCELERATION = 500
export var SLOWDOWN = 500
export var TOP_SPEED = 80
#export var FRICTION = 50
export(float, 0.0, 10.0) var FORCE_MULT = 1.0

var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO

export var truName = ""
export var faction = ""

var marked_enemies: Array = []

var components = { # PROBLEM_NOTE, this doesn't support duplicate components but whatever
	"brain": null,
	"movement_lobe": null,
	"memory_lobe": null,
	"action_lobe": null,
	"warning_lobe": null,
	"communication_lobe": null,
	"spawner": null,
	"entity_push": null,
	"health_bar": null,
	"hitbox": null,
	"hurtbox": null,
	"player_controlled": null,
	"sleeper": null,
	"entity_sprite": null,
	"stats": null,
	"sound_player": null,
	"held_item": null
}

signal death()

func _init():
	add_to_group("entity", true)

func _ready():
	global_position.y -= 0.02
	# this is to solve ysort issues. it's a little jank but it works
	# i think the sorting is only triggered when the y position changes
	
	# PROBLEM_NOTE: maybe do global_position.y += 0.01, might break things though
	
	if faction != "" and global.faction_relationships.get(faction) == null:
		push_error(get_name()+"'s faction '"+faction+"' is invalid")

func _process(delta): # physics logic
	# PROBLEM_NOTE: \/ not sure why i did this
	marked_enemies = []
	if marked_enemies.size() > 0:
		breakpoint
	
	if STATIC == true: return
	
	input_vector = input_vector.normalized() # diagonally is same speed as straight
	
	# movement w/ input vector
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * TOP_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SLOWDOWN * delta)
	
	velocity = move_and_slide(velocity)

func apply_force(force:Vector2):
	velocity += force * FORCE_MULT

func death():
	emit_signal("death")
	queue_free()

func get_speed():
	var velo = velocity
	if input_vector != Vector2.ZERO: velo *= input_vector.normalized()
	return abs(velo.x) + abs(velo.y)
