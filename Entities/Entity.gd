extends KinematicBody2D
class_name Entity

const ATTACK_FLASH := preload("res://Effects/attack_flash/attack_flash.tscn")

export var STATIC = false
export var ACCELERATION = 500
export var SLOWDOWN = 500
export var TOP_SPEED = 80
#export var FRICTION = 50
export(float, 0.0, 10.0) var FORCE_MULT = 1.0
export var INANIMATE := false
export var INVISIBLE := false
export var FLYING := false

var velocity: Vector2 = Vector2.ZERO
var input_vector = Vector2.ZERO
var rooted := false
var dead := false

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

func _physics_process(delta: float): # physics logic
	if STATIC == true: 
		return
	
	input_vector = input_vector.normalized() # diagonally is same speed as straight
	
	# movement w/ input vector
	#var old_velocity := velocity
	if input_vector != Vector2.ZERO and rooted == false and get_speed() <= TOP_SPEED:
		velocity = velocity.move_toward(input_vector * TOP_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SLOWDOWN * delta)
	
	velocity = move_and_slide(velocity)

func apply_force(force: Vector2):
	velocity += force * FORCE_MULT

func death():
	if dead == true:
		return
	
	dead = true
	emit_signal("death")
	queue_free()
	visible = false

func get_speed() -> float:
	# NOTE: should be using pythagorean theorem here but i suck at math lol
	# changing this requires modifying TOP_SPEED values for every entity in the game,
	# so i'm just gonna keep this as is.
	
	var velo: Vector2 = velocity
	if input_vector != Vector2.ZERO:
		velo *= input_vector.normalized()
	return abs(velo.x) + abs(velo.y)

func attack_flash() -> void:
	var flash: Effect = ATTACK_FLASH.instance()
	flash.position = global_position
	refs.ysort.add_child(flash)
