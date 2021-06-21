extends Entity

export(float) var shoot_speed: float

var stored_attack: Attack
var stored_target: Entity

onready var animation: AnimationPlayer = $AnimationPlayer
onready var timer = $Timer

func _init() -> void:
	res.allocate("slash")
	res.allocate("arrow")

func _on_action_lobe_action(action, target) -> void:
	stored_target = target 
	
	if action == "slash":
		stored_attack = res.aquire_melee("slash")
	elif action == "shoot":
		stored_attack = res.aquire_projectile("arrow") 
	
	animation.play("attack")

func attack():
	if stored_attack.truName == "arrow":
		stored_attack.SPEED = shoot_speed
	
	stored_attack.setup(self, stored_target.global_position)
	stored_attack.SOURCE_PATH = get_path()
	global.nodes["ysort"].add_child(stored_attack)
	yield(stored_attack, "tree_entered")
	stored_attack.global_position = global_position

