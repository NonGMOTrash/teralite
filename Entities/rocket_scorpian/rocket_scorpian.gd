extends Entity

export var lunge_force: float
export var rage_threshold: int
export var rage_speed_mult: float

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

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	TOP_SPEED = original_top_speed
	attacking = false

func _on_hurtbox_got_hit(by_area, type) -> void:
	if stats.HEALTH <= rage_threshold and enraged == false:
		TOP_SPEED *= rage_speed_mult
		$brain/action_lobe/attack.COOLDOWN *= 1.0 - abs(rage_speed_mult - 1.0)
		$brain/action_lobe/shoot.COOLDOWN *= 1.0 - abs(rage_speed_mult - 1.0)
		animation.playback_speed = rage_speed_mult
		enraged = true
		
