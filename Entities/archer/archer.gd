extends Entity

onready var sprite = $sprite
onready var brain = $brain
onready var animation = $AnimationPlayer
onready var held_item = $held_item

export(PackedScene) var PROJECTILE
export(String) var warn_animation: String
export(int, 1, 5) var warn_times:int 

var targit: Entity
var targit_path: NodePath

func _ready():
	held_item.animation.connect("animation_finished", self, "attack")

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	elif input_vector != Vector2.ZERO:
		animation.play("walk")

func attack(finished_animation:String):
	if finished_animation != warn_animation or held_item.animation.get_queue().size() > 0:
		return
	
	held_item.sprite.frame = 0
	
	var pos: Vector2
	if (
		targit != null and 
		get_node_or_null(targit_path) != null
	): 
		pos = targit.global_position
	else: 
		pos = global_position + (input_vector * 5) + Vector2(rand_range(-0.1, 0.1), rand_range(-0.1, 0.1))
	
	var projectile = PROJECTILE.instance()
	projectile.setup(self, pos)
	refs.ysort.get_ref().add_child(projectile)

func _on_action_lobe_action(action, target: Entity) -> void:
	targit = target
	targit_path = target.get_path()
	
	if warn_times == 0:
		attack(warn_animation)
	else:
		for _i in range(0, warn_times):
			held_item.animation.queue(warn_animation)
