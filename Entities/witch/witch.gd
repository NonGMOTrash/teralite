extends Entity

export var attack_cooldown: float

var stored_target_pos: Vector2

onready var animation := $AnimationPlayer
onready var held_item := $held_item

func _init() -> void:
	res.allocate("blow_dart")

func _ready() -> void:
	$brain/action_lobe/attack.COOLDOWN = attack_cooldown
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")

func _on_action_lobe_action(action, target) -> void:
	stored_target_pos = target.global_position
	held_item.TARGETING = held_item.TT.MANUAL
	held_item.animation.play("warn")

func attack(_finished_animation: String) -> void:
	var blow_dart := res.aquire_projectile("blow_dart")
	blow_dart.setup(self, stored_target_pos)
	blow_dart.global_position = self.global_position
	refs.ysort.get_ref().call_deferred("add_child", blow_dart)
	held_item.TARGETING = held_item.TT.BRAIN_TARGET
