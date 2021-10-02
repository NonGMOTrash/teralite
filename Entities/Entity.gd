extends KinematicBody2D
class_name Entity

export var STATIC = false
export var ACCELERATION = 500
export var SLOWDOWN = 500
export var TOP_SPEED = 80
#export var FRICTION = 50
export(float, 0.0, 10.0) var FORCE_MULT = 1.0
export(bool) var INANIMATE := false

var velocity: Vector2 = Vector2.ZERO
var input_vector = Vector2.ZERO
var rooted := false

export var truName = ""
export var faction = ""

var marked_enemies: Array = []
var marked_allies: Array = []

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
	global_position.y -= 0.01
	# PROBLEM_NOTE: maybe do 'move_and_slide(Vector2(0, 0.01)'
	
	if truName == "":
		push_error("%s's truName was not set" % get_name())
	
	if faction != "" and global.faction_relationships.get(faction) == null:
		push_error(get_name()+"'s faction '"+faction+"' is invalid")
	
	if INANIMATE == false and get_tree().current_scene.LEVEL_TYPE == 0 and truName != "player":
		get_tree().current_scene.max_kills += 1

func _physics_process(delta: float): # physics logic
	if STATIC == true: 
		set_physics_process(false)
		return
	
	input_vector = input_vector.normalized() # diagonally is same speed as straight
	
	# movement w/ input vector
	#var old_velocity := velocity
	if input_vector != Vector2.ZERO and rooted == false and get_speed() <= TOP_SPEED:
		velocity = velocity.move_toward(input_vector * TOP_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SLOWDOWN * delta)
	
	velocity = move_and_slide(velocity)

func apply_force(force:Vector2):
	velocity += force * FORCE_MULT

func death():
	emit_signal("death")
	queue_free()
	visible = false

func get_speed() -> float:
	var velo = velocity
	if input_vector != Vector2.ZERO: velo *= input_vector.normalized()
	return abs(velo.x) + abs(velo.y)
