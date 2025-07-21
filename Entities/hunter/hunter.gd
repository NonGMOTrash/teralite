extends Entity

export var warnings: int
export var shot_cooldown: float
export(PackedScene) var PROJECTILE
export var aiming_speed_mult: float = 0.2

var actionable: bool = true
var current_target: Entity
var last_target_pos := Vector2.ZERO
var queued_action: String
var bullets: int = 3
onready var original_speed: float = TOP_SPEED

onready var brain := $brain
onready var held_item := $held_item
onready var stats := $stats
onready var animation := $AnimationPlayer
onready var reticle := $reticle
onready var shot_timer: Timer = $shot_timer

func _ready() -> void:
	held_item.animation.connect("animation_finished", self, "attack")
	reticle.visible = false

func _on_brain_found_target() -> void:
	if actionable == false:
		return
	
	TOP_SPEED = original_speed * aiming_speed_mult
	
	if bullets == 0:
		reticle.visible = false
		queued_action = "reload"
		held_item.animation.clear_queue()
		held_item.animation.play("load", -1, 0.6)
		actionable = false
		return
	
	queued_action = "shoot"
	current_target = brain.get_closest_target()
	reticle.visible = true
	for _i in warnings:
		held_item.animation.queue("warn")
	if current_target.truName == "player":
		var length: float = held_item.animation.get_animation("warn").length * warnings
		get_tree().create_timer(length-0.5).connect("timeout", self, "attack_flash")

func attack(_finished_animation:String):
	if held_item.animation.get_queue().size() > 0:
		return
	
	TOP_SPEED = original_speed
	reticle.visible = false
	
	if queued_action == "shoot":
		if !is_instance_valid(current_target):
			return
		
		var bullet: Projectile = PROJECTILE.instance()
		bullet.marked_allies.append(self)
		marked_allies.append(bullet)
		bullet.setup(self, current_target.global_position)
		refs.ysort.add_child(bullet)
		bullets -= 1
		shot_timer.start()
	elif queued_action == "reload":
		bullets = 3
		actionable = true
		if is_instance_valid(current_target) && current_target in brain.targets:
			_on_brain_found_target()

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")
	
	if is_instance_valid(current_target) and current_target != self:
		last_target_pos = current_target.global_position
		held_item.rotation = global_position.direction_to(current_target.global_position).angle()
		
		if reticle.visible:
			reticle.global_position = current_target.global_position

func _on_brain_lost_target() -> void:
	held_item.animation.stop()
	held_item.sprite.scale = Vector2(1,1)
	TOP_SPEED = original_speed
	reticle.visible = false
	
	if bullets <= 0:
		queued_action = "reload"
		held_item.animation.clear_queue()
		held_item.animation.play("load", -1, 0.6)
		actionable = false
	elif actionable:
		var bullet: Projectile = PROJECTILE.instance()
		bullet.marked_allies.append(self)
		marked_allies.append(bullet)
		bullet.setup(self, last_target_pos)
		refs.ysort.call_deferred("add_child", bullet)
		bullets -= 1
		shot_timer.start()

func _on_shot_timer_timeout():
	actionable = true
	if is_instance_valid(current_target) && current_target in brain.targets:
		_on_brain_found_target()
