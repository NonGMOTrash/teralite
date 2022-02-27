extends Entity

const BULLET := preload("res://Entities/Attacks/Projectile/small_bullet/small_bullet.tscn")
const SHOOT_SOUND := preload("res://Entities/player/item_thinkers/assault_rifle/assault_rifle_shoot.wav")

export var warnings: int
export var shoot_cooldown: float

var current_target: Entity
var current_target_path: NodePath
var bullets: int = 30

onready var shoot_timer: Timer = $shoot_timer
onready var stats: Node = $stats
onready var held_item: Node2D = $held_item
onready var brain: Node2D = $brain
onready var animation: AnimationPlayer = $AnimationPlayer
onready var muzzle_flash: Node = $muzzle_flash

func _on_action_lobe_action(action, target) -> void:
	current_target = target
	current_target_path = target.get_path()
	if not shoot_timer.time_left > 0:
		for i in range(0, warnings):
			held_item.animation.queue("warn")

func _on_shoot_timer_timeout() -> void:
	if held_item.animation.is_playing():
		return
	
	var bullet: Projectile = BULLET.instance()
	bullet.SPAWN_SOUND = SHOOT_SOUND
	bullet.setup(self, current_target.global_position)
	refs.ysort.add_child(bullet)
	
	if brain.get_closest_target() != null:
		muzzle_flash.spawn()
	
	bullets -= 1
	if bullets <= 0:
		held_item.animation.play("load")

func _on_brain_lost_target() -> void:
	shoot_timer.stop()
	held_item.animation.stop()
	held_item.animation.clear_queue()
	held_item.sprite.scale = Vector2(1, 1)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "warn" and held_item.animation.get_queue().size() == 0 and brain.targets.size() != 0:
		shoot_timer.start()
	elif anim_name == "load":
		bullets = 30

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")
