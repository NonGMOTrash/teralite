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
var marked_enemies = []

var components = { # PROBLEM_NOTE, this doesn't support duplicate components but whatever
	"brain": null,
	"death_spawn": null,
	"entity_push": null,
	"health_bar": null,
	"hit_spawn": null,
	"hitbox": null,
	"hurtbox": null,
	"player_controlled": null,
	"sleeper": null,
	"entity_sprite": null,
	"stats": null
}

signal death()

func _ready():
	global_position.y -= 0.01
	# this is to solve ysort issues. it's a little jank but it works
	# I think it has sometihng to do with the sorting only being triggered when the y position changes

func _physics_process(delta): # physics logic
	if STATIC == true: return
	
	input_vector = input_vector.normalized() # diagonally is same speed as straight
	
	# movement w/ input vector
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * TOP_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SLOWDOWN * delta)
	
	velocity = move_and_slide(velocity)

func apply_force(force:Vector2):
	var delta = get_physics_process_delta_time()
	velocity += force * FORCE_MULT

func death():
	emit_signal("death")
	queue_free()
