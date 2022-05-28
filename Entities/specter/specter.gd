extends Entity

const SPECTER_CLONE_PATH: String = "res://Entities/specter/specter_clone/specter_clone.tscn"

export var dup_limit: int = 4

onready var dup_timer = $dup_timer
onready var sprite = $sprite
onready var animation = $AnimationPlayer

var original_top_speed: int
var original_copy: PackedScene = load(SPECTER_CLONE_PATH)

func _ready() -> void:
	original_top_speed = TOP_SPEED
	TOP_SPEED = 0

func _on_dup_timer_timeout() -> void:
	if dup_limit < 1:
		dup_timer.stop()
		return
	
	dup_limit -= 1
	var clone: Entity = original_copy.instance()
	clone.global_position = (
			global_position + Vector2(rand_range(-1,1),rand_range(-1,1)).normalized() * 16)
	clone.dup_limit = dup_limit
	refs.ysort.call_deferred("add_child", clone)
	TOP_SPEED = 0
	animation.play("duplicate")
	
	#yield(clone, "ready")
	#breakpoint

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	TOP_SPEED = original_top_speed
