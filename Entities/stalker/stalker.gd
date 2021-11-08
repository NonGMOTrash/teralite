extends Entity

const INVIS := Color(0, 0, 0, 0)
const VISIBLE := Color(1, 1, 1, 1)
const TRANS := Tween.TRANS_LINEAR
const EAZE := Tween.EASE_IN

export var REVEAL_SPEED_BOOST: float
var original_top_speed = TOP_SPEED
var original_acceleration = ACCELERATION

onready var reveal: AnimationPlayer = $reveal
onready var brain: Node2D = $brain
onready var sprite: Sprite = $entity_sprite

func _ready() -> void:
	modulate.a = 0

func _on_hurtbox_got_hit(by_area, type) -> void:
	reveal.play("animation")

func _on_hitbox_hit(area, type) -> void:
	reveal.play("animation")

func set_speed(mode: String):
	if mode == "invis":
		TOP_SPEED = original_top_speed * REVEAL_SPEED_BOOST
		ACCELERATION = original_acceleration * REVEAL_SPEED_BOOST
	else:
		TOP_SPEED = original_top_speed * REVEAL_SPEED_BOOST
		ACCELERATION = original_acceleration * REVEAL_SPEED_BOOST

