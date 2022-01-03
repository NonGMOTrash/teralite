extends Entity

export var lunge_force: float
export var rage_threshold: int
export var rage_speed_mult: float
export var burrow_speed_mult: float

onready var animation: AnimationPlayer = $AnimationPlayer
onready var stats: Node = $stats
onready var original_top_speed: int = TOP_SPEED

var attacking := false
var target_path: NodePath
var enraged := false

func set_attacking(to: bool):
	attacking = to

func _physics_process(delta: float) -> void:
	if attacking == false:
		if input_vector == Vector2.ZERO:
			animation.play("stand")
		else:
			animation.play("walk")

func _on_action_lobe_action(action, target) -> void:
	if attacking == true:
		return
	target_path = target.get_path()
	attacking = true
	TOP_SPEED = 0
	animation.play(action)

func lunge():
	var target: Entity = get_node_or_null(target_path)
	if target != null:
		apply_force(global_position.direction_to(target.global_position).normalized() * lunge_force)

func shoot():
	var target: Entity = get_node_or_null(target_path)
	if target != null:
		var rocket := res.aquire_projectile("rocket")
		rocket.setup(self, target.global_position)
		refs.ysort.get_ref().add_child(rocket)

func burrow():
	var target: Entity = get_node_or_null(target_path)
	prints(target, target_path)
	if target != null:
		global_position = global_position.move_toward(target.global_position, 110)

func poison():
	var directions := [
		Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(1, -1), Vector2(0, -1), Vector2(-1, -1),
		Vector2(-1, 0), Vector2(-1, 1)
	]
	for i in 8:
		var poison := res.aquire_projectile("poison_drop")
		poison.setup(self, global_position + directions[i] * 99)
		refs.ysort.get_ref().add_child(poison)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	TOP_SPEED = original_top_speed
	attacking = false

func _on_hurtbox_got_hit(by_area, type) -> void:
	if stats.HEALTH <= rage_threshold and enraged == false:
		original_top_speed *= rage_speed_mult
		TOP_SPEED = original_top_speed
		$brain/action_lobe/attack.COOLDOWN *= 1.0 - abs(rage_speed_mult - 1.0)
		$brain/action_lobe/shoot.COOLDOWN *= 1.0 - abs(rage_speed_mult - 1.0)
		animation.playback_speed = rage_speed_mult
		enraged = true
