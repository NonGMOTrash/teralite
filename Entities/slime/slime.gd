extends Entity

const SLIME := preload("res://Entities/slime/slime.png")
const SLIME_2 := preload("res://Entities/slime/slime_2.png")
const SLIME_3 := preload("res://Entities/slime/slime_3.png")
const SLIME_4 := preload("res://Entities/slime/slime_4.png")
const SLIME_5 := preload("res://Entities/slime/slime_5.png")

export(float) var lunge_delay: float
export(float) var lunge_speed: float
export(float) var lunge_delay_scaling: float

onready var lunge_timer: Timer = $lunge_timer
onready var stats: Node = $stats
onready var animation: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $entity_sprite

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
	lunge_timer.wait_time = (
			lunge_delay * pow(lunge_delay_scaling, stats.MAX_HEALTH-stats.HEALTH))
	
	match stats.HEALTH:
		4: sprite.texture = SLIME_2
		3: sprite.texture = SLIME_3
		2: sprite.texture = SLIME_4
		1: sprite.texture = SLIME_5
	sprite.front_texture = sprite.texture
	
	var slime: Entity = load("res://Entities/slime/slime.tscn").instance()
	slime.velocity = velocity
	refs.ysort.call_deferred("add_child", slime)
	yield(slime, "tree_entered")
	slime.global_position = global_position - input_vector * 3
	yield(slime, "ready")
	slime.stats.HEALTH = stats.HEALTH
	slime.lunge_timer.wait_time = lunge_timer.wait_time
	slime.components["entity_sprite"].texture = sprite.texture
	slime.components["health_bar"].update_bar(0, 0, 0)
	
	slime.apply_force(global_position.direction_to(by_area.global_position).normalized() * -225)
