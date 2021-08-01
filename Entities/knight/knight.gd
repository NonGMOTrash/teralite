extends Entity

export(PackedScene) var MELEE

onready var attack_cooldown = $attack_cooldown
onready var brain = $brain
onready var held_item = $held_item
onready var move_animation = $move_animations

export(float, 0.01, 5.0) var attack_cooldown_time = 0.85

func _ready():
	attack_cooldown.wait_time = attack_cooldown_time
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float):
	if input_vector != Vector2.ZERO:
		move_animation.play("walk")
	else:
		move_animation.play("stand")

func attack(finished_animation):
	if finished_animation == "warn" and held_item.animation.get_queue().size() > 0:
		return
	
	var closest_target = brain.get_closest_target()
	var target_pos = Vector2.ZERO
	if closest_target != null:
		target_pos = closest_target.global_position
	
	var melee := MELEE.instance() as Melee
	melee.setup(self, target_pos)
	add_child(melee)
	melee.SOURCE_PATH = self.get_path()
	attack_cooldown.start()

func _on_action_lobe_action(action, target) -> void:
	if attack_cooldown.time_left > 0: return
	held_item.animation.play("warn")
	held_item.animation.queue("warn")
