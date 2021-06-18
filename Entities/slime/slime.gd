extends Entity

export(float) var lunge_delay: float
export(float) var lunge_speed: float
export(float) var lunge_delay_scaling: float

onready var lunge_timer: Timer = $lunge_timer
onready var stats: Node = $stats
onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	lunge_timer.wait_time = lunge_delay
	lunge_timer.start()

func _on_lunge_timer_timeout() -> void:
	apply_force(lunge_speed * input_vector)
	animation.play("squish")

func _on_hurtbox_got_hit(by_area, type) -> void:
	if type != "hurt":
		return
	
	animation.play("squish")
	lunge_timer.wait_time *= lunge_delay_scaling
	
	var slime: Entity = res.aquire_entity("slime")
	slime.velocity = velocity
	global.nodes["ysort"].call_deferred("add_child", slime)
	yield(slime, "tree_entered")
	slime.global_position = global_position - input_vector * 3
	yield(slime, "ready")
	slime.stats.HEALTH = stats.HEALTH
	for i in stats.MAX_HEALTH - stats.HEALTH:
		slime.lunge_timer.wait_time *= lunge_delay_scaling
