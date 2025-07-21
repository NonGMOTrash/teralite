extends Entity

# NOTE: also used by
# mage

onready var sprite = $sprite
onready var brain = $brain
onready var animation: AnimationPlayer = $AnimationPlayer
onready var held_item = $held_item

export(PackedScene) var PROJECTILE

var targit: Entity
var targit_path: NodePath
var targit_position: Vector2

func _ready():
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	elif input_vector != Vector2.ZERO:
		animation.play("walk")
	
	if is_instance_valid(targit):
		targit_position = targit.global_position

func attack(_finished_animation:String):
	held_item.sprite.frame = 0
	
	var projectile = PROJECTILE.instance()
	projectile.setup(self, targit_position)
	refs.ysort.add_child(projectile)

func _on_action_lobe_action(action, target: Entity) -> void:
	targit = target
	targit_path = target.get_path()
	
	if target.truName == "player":
		if truName == "archer":
			var length: float = held_item.animation.get_animation("bow_charge").length
			get_tree().create_timer(length-0.5).connect("timeout", self, "attack_flash")
		elif truName == "mage":
			attack_flash()
	
	if truName == "archer":
		held_item.animation.play("bow_charge")
	elif truName == "mage":
		if held_item.sprite.flip_v:
			held_item.animation.play("startup_swing_flip")
		else:
			held_item.animation.play("startup_swing")
