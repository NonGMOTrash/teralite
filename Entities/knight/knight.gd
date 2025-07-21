extends Entity

# NOTE: this script is also used by:
# rogue
# warden

export(PackedScene) var MELEE

onready var brain = $brain
onready var held_item = $held_item
onready var move_animation = $move_animations

func _ready():
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float):
	if input_vector != Vector2.ZERO:
		move_animation.play("walk")
	else:
		move_animation.play("stand")

func attack(_finished_animation):
	held_item.sprite.rotation_degrees = 0
	
	var closest_target: Entity = brain.get_closest_target()
	var target_pos = Vector2.ZERO
	if closest_target != null:
		target_pos = closest_target.global_position
	
	var melee := MELEE.instance() as Melee
	melee.setup(self, target_pos)
	add_child(melee)
	melee.SOURCE_PATH = self.get_path()

func _on_action_lobe_action(action, target) -> void:
	if target.truName == "player":
		attack_flash()
	
	if truName == "warden":
		if held_item.sprite.flip_v:
			held_item.animation.play("startup_thrust_flip")
			held_item.sprite.rotation_degrees = 45
		else:
			held_item.animation.play("startup_thrust")
			held_item.sprite.rotation_degrees = -45
	else:
		if held_item.sprite.flip_v:
			held_item.animation.play("startup_swing_flip")
		else:
			held_item.animation.play("startup_swing")
