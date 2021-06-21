extends Entity

const KNIGHT = preload("res://Entities/knight/knight.tscn")
const ARCHER = preload("res://Entities/archer/archer.tscn")
const ROGUE = preload("res://Entities/knight/rogue/rogue.tscn")

onready var stats = $stats
onready var cooldown = $cooldown
onready var animation = $AnimationPlayer
onready var brain = $brain
export(float, 0.01, 8.0) var cooldown_time = 3.8
export(float, 0.01, 1.0) var anger_cooldown_multiplier = 0.5

var stored_input

func _init() -> void:
	res.allocate("knight")
	res.allocate("archer")
	res.allocate("rogue")

func _ready():
	cooldown.wait_time = cooldown_time

func _physics_process(delta):
	# PROBLEM_NOTE: this is dumb, but I have to do it because the slowdown only triggers if the input_vector is
	# 0, 0, and it never is on this enemy so..
	velocity = velocity.move_toward(Vector2.ZERO, SLOWDOWN * delta) # applys slowdown

func summon():
	for _i in range(0, 3):
		var guard
		
		match stored_input:
			"knight": guard = KNIGHT.instance()
			"archer": guard = ARCHER.instance()
			"rogue": guard = ROGUE.instance()
		
		guard.marked_enemies = marked_enemies
		get_parent().call_deferred("add_child", guard)
		guard.global_position = global_position #+ Vector2(rand_range(-16, 16), rand_range(-16, 16))
		guard.velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 90
	
	cooldown.start()

func _on_stats_health_changed(_type, _result, _net) -> void:
	if stats.HEALTH < stats.MAX_HEALTH / 2:
		# anger
		cooldown.wait_time = cooldown_time / 1.5

func _on_action_lobe_action(action, target) -> void:
	if cooldown.time_left > 0 or animation.is_playing() == true: return
	stored_input = action
	animation.play("summon")
