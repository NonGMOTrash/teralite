extends Entity 

const DASH_EFFECT := preload("res://Effects/dash_effect/dash_effect.tscn")
const SHOTGUN_SHELL := preload("res://Entities/Attacks/Projectile/shotgun_shell/shotgun_shell.tscn")

export var warnings: int
export var dash_strength: int

var actionable := false
var targit: Entity
var targit_path: NodePath
var queued_action: String
var shots: int = 2
var pellets: int = 5
var spread: int = 40

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
	
	if action == "shoot":
		if shots == 0:
			queued_action = "reload"
			held_item.animation.clear_queue()
			held_item.animation.play("spin", -1, 1.1)
			actionable = false
			return
		
		queued_action = "shoot"
		targit = target
		targit_path = target.get_path()
		for _i in warnings:
			held_item.animation.queue("warn")
	elif action == "dash":
		var dash_direction := global_position.direction_to(target.global_position).normalized()
		apply_force(dash_direction * dash_strength)
		
		var dash_effect = DASH_EFFECT.instance()
		dash_effect.rotation_degrees = rad2deg(dash_direction.angle())
		refs.ysort.call_deferred("add_child", dash_effect)
		yield(dash_effect, "ready")
		dash_effect.global_position = global_position + Vector2(0, 6)

func attack(finished_animation:String):
	if held_item.animation.get_queue().size() > 0:
		return
	if queued_action == "shoot":
		var angle_to: float
		if get_node_or_null(targit_path) == null or targit == null or !is_instance_valid(targit):
			return
		else:
			angle_to = global_position.direction_to(targit.global_position).angle()
		
		var angles := []
		var spread_step: float = (spread * 2) / pellets
		var r: float = -(spread / 2) - (spread_step * floor(pellets/2.0))
		for i in pellets:
			r += spread_step
			angles.append(rad2deg(angle_to) + r)
		
		var bullets := []
		for i in pellets:
			bullets.append(SHOTGUN_SHELL.instance() as Projectile)
		
		for i in pellets:
			var angle: float = deg2rad(angles[i])
			var direction := Vector2(cos(angle), sin(angle))
			var this_bullet: Projectile = bullets[i]
			this_bullet.setup(self, targit.global_position)
			this_bullet.DIRECTION = direction
			this_bullet.velocity = Vector2(this_bullet.SPEED, this_bullet.SPEED) * direction
			refs.ysort.call_deferred("add_child", this_bullet)
		shots -= 1
	elif queued_action == "reload":
		shots = 2
		actionable = true

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")

func _on_brain_lost_target() -> void:
	if brain.targets.size() == 0 and shots != 2:
		queued_action = "reload"
		held_item.animation.clear_queue()
		held_item.animation.play("spin", -1, 1.1)
		actionable = false

