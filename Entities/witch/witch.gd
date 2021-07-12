extends Entity

export var attack_cooldown: float

var stored_target_pos: Vector2

onready var animation := $AnimationPlayer

func _init() -> void:
	res.allocate("blow_dart")

func _ready() -> void:
	$brain/action_lobe/attack.COOLDOWN = attack_cooldown

func _on_action_lobe_action(action, target) -> void:
	stored_target_pos = target.global_position
	animation.play("attack")

func attack():
	var blow_dart := res.aquire_projectile("blow_dart")
	blow_dart.setup(self, stored_target_pos)
	blow_dart.global_position = self.global_position
	refs.ysort.get_ref().call_deferred("add_child", blow_dart)
