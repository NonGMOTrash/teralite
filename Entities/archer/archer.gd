extends Entity

onready var attack_cooldown = $attack_cooldown
onready var sprite = $sprite
onready var brain = $brain
onready var animation = $AnimationPlayer

export(float, 0.01, 5.0) var attack_cooldown_time = 0.85

func _ready():
	attack_cooldown.wait_time = attack_cooldown_time

func _on_brain_entity_input(input) -> void:
	if attack_cooldown.time_left > 0: return
	animation.play("attack")

func attack():
	var target_pos
	if brain.target != null: target_pos = brain.target.global_position
	else: target_pos = brain.last_seen
	
	var arrow = global.aquire("Arrow")
	arrow.setup(self, target_pos)
	get_parent().add_child(arrow)
	attack_cooldown.start()
