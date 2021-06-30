extends Thinker

export var activation_radius: float

onready var activation := $activation
onready var activation_collision := $activation/CollisionShape2D

func _ready() -> void:
	activation_collision.shape.radius = activation_radius

func _physics_process(delta: float) -> void:
	activation.global_position = player.components["held_item"].anchor.global_position

func _on_activation_body_entered(body: Node) -> void:
	if not body is Entity or player.inventory[global.selection] != my_item:
		return
	
	if body.truName == "lock":
		body.unlock()
		delete()
