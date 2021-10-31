extends Entity

const SWORD := preload("res://Entities/Item_Pickups/sword/sword.png")

onready var attack_cooldown = $attack_cooldown
onready var brain = $brain
onready var held_item = $held_item
onready var move_animation = $move_animations

export(PackedScene) var MELEE
export(PackedScene) var PROJECTILE
export(float, 0.01, 5.0) var melee_cooldown = 0.85
export(float, 0.1, 5.0) var shoot_cooldown = 2.1

func _ready():
	attack_cooldown.wait_time = melee_cooldown
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float):
	if input_vector != Vector2.ZERO:
		move_animation.play("walk")
	else:
		move_animation.play("stand")

func attack(finished_animation):
	if held_item.animation.get_queue().size() > 0:
		return
	
	var closest_target = brain.get_closest_target()
	var target_pos = Vector2.ZERO
	if closest_target != null:
		target_pos = closest_target.global_position
	
	if finished_animation == "warn":
		var melee: Melee = MELEE.instance()
		melee.setup(self, target_pos)
		add_child(melee)
		melee.SOURCE_PATH = self.get_path()
		attack_cooldown.wait_time = melee_cooldown
	elif finished_animation == "bow_charge":
		var projectile: Projectile = PROJECTILE.instance()
		projectile.setup(self, target_pos)
		refs.ysort.get_ref().add_child(projectile)
		projectile.SOURCE_PATH = self.get_path()
		attack_cooldown.wait_time = shoot_cooldown
	
	attack_cooldown.start()

func _on_action_lobe_action(action, target) -> void:
	if attack_cooldown.time_left > 0: return
	elif action == "slash":
		brain.movement_lobe.general_springs["hostile"] = "close"
		held_item.sprite.frame = 0
		held_item.sprite.hframes = 1
		held_item.sprite.vframes = 1
		held_item.sprite.texture = SWORD
		held_item.animation.play("warn")
		held_item.animation.queue("warn")
	elif action == "shoot":
		brain.movement_lobe.general_springs["hostile"] = "far"
		held_item.animation.play("bow_charge")
