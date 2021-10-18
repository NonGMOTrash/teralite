extends Entity

export var warnings: int
export(PackedScene) var PROJECTILE

var actionable := false
var targit: Entity
var targit_path: NodePath
var queued_action: String
var bullets: int = 3

onready var brain := $brain
onready var held_item := $held_item
onready var stats := $stats
onready var animation := $AnimationPlayer

func _ready() -> void:
	held_item.animation.connect("animation_finished", self, "attack")
	actionable = true

func _on_action_lobe_action(action, target) -> void:
	if actionable == false:
		return
	
	if bullets == 0:
		queued_action = "reload"
		held_item.animation.clear_queue()
		held_item.animation.play("load", -1, 0.6)
		actionable = false
		return
	
	queued_action = "shoot"
	targit = target
	targit_path = target.get_path()
	for _i in warnings:
		held_item.animation.queue("warn")

func attack(finished_animation:String):
	print("!!")
	if held_item.animation.get_queue().size() > 0:
		return
	
	if queued_action == "shoot":
		if get_node_or_null(targit_path) == null:
			return
		
		var bullet: Projectile = PROJECTILE.instance()
		bullet.marked_allies.append(self)
		marked_allies.append(bullet)
		bullet.setup(self, targit.global_position)
		refs.ysort.get_ref().add_child(bullet)
		bullets -= 1
	elif queued_action == "reload":
		bullets = 10
		actionable = true

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")

func _on_brain_lost_target() -> void:
	if brain.targets.size() == 0 and bullets != 10:
		queued_action = "reload"
		held_item.animation.clear_queue()
		held_item.animation.play("load", -1, 0.6)
		actionable = false
	
