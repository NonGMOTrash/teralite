extends Entity

const BLAST := preload("res://Entities/Attacks/Projectile/blast/blast.tscn")
const BEAM := preload("res://Entities/Attacks/Melee/beam/beam.tscn")
const BLASTER_TEXTURE := preload("res://Entities/Item_Pickups/blaster/blaster.png")
const SABER_TEXTURE := preload("res://Entities/Item_Pickups/saber/saber.png")

export var warnings: int

var current_target: Entity
var current_target_path: NodePath
var queued_action: String

onready var cooldown: Timer = $cooldown
onready var stats: Node = $stats
onready var held_item: Node2D = $held_item
onready var brain: Node2D = $brain
onready var animation: AnimationPlayer = $AnimationPlayer
onready var muzzle_flash: Node = $muzzle_flash

func _on_action_lobe_action(action, target) -> void:
	if action == queued_action or held_item.animation.is_playing():
		return
	
	queued_action = action
	match action:
		"shoot":
			held_item.sprite.texture = BLASTER_TEXTURE
			held_item.light.enabled = false
		"melee":
			held_item.sprite.texture = SABER_TEXTURE
			held_item.light.enabled = true
	current_target = target
	current_target_path = target.get_path()
	if not held_item.animation.is_playing():
		for i in range(0, warnings):
			held_item.animation.queue("warn")

func _on_cooldown_timeout() -> void:
	if held_item.animation.current_animation == "warn":
		return
	
	var attack: Attack
	if queued_action == "shoot":
		attack = BLAST.instance() as Projectile
	elif queued_action == "melee":
		attack = BEAM.instance() as Melee
	attack.setup(self, current_target.global_position)
	refs.ysort.add_child(attack)
	
	if queued_action == "shoot" and brain.get_closest_target() != null:
		muzzle_flash.spawn()

func _on_brain_lost_target() -> void:
	cooldown.stop()
	held_item.animation.stop()
	held_item.animation.clear_queue()
	held_item.sprite.scale = Vector2(1, 1)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if held_item.animation.get_queue().size() == 0 and brain.targets.size() != 0:
		cooldown.start()

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")
