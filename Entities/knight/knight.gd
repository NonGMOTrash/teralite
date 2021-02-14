extends Entity

onready var attack_cooldown = $attack_cooldown
onready var brain = $brain
onready var animation = $AnimationPlayer

export(float, 0.01, 5.0) var attack_cooldown_time = 0.85

func _ready(): 
	attack_cooldown.wait_time = attack_cooldown_time

func attack():
	var closest_target = brain.closest_target()
	var target_pos = Vector2.ZERO
	if not closest_target is String: 
		target_pos = closest_target.global_position
	
	var slash = global.aquire("Slash")
	slash.setup(self, target_pos)
	add_child(slash) 
	slash.SOURCE_PATH = self.get_path()
	attack_cooldown.start()
	animation.play("attack")

func _on_action_lobe_action(action, target) -> void:
	if attack_cooldown.time_left > 0: return
	animation.play("warning")
