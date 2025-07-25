extends Thinker

export var activation_radius: float

onready var activation := $activation
onready var activation_collision := $activation/CollisionShape2D

var ready := false

func _ready() -> void:
	activation_collision.shape.radius = activation_radius
	ready = true

func _physics_process(delta: float) -> void:
	activation.global_position = player.components["held_item"].anchor.global_position

func _on_activation_body_entered(body: Node) -> void:
	if not body is Entity or global.selection != slot:
		return
	
	if body.truName == "lock":
		body.unlock()
		delete()

func selected():
	.selected()
	if ready == false:
		return
	
	for body in activation.get_overlapping_bodies():
		if body is Entity && body.truName == "lock" && !body.unlocked:
			_on_activation_body_entered(body)
			break

func primary():
	if ready == false:
		return
	
	for body in activation.get_overlapping_bodies():
		if body is Entity and body.truName == "lock":
			_on_activation_body_entered(body)
			break
