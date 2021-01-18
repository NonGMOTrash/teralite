extends Entity

export var dup_limit = 4

onready var dup_timer = $dup_timer
onready var sprite = $sprite

func _ready() -> void:
	pass # Replace with function body.

func _on_dup_timer_timeout() -> void:
	if dup_limit < 1:
		dup_timer.stop()
		return
	dup_limit -= 1
	var clone = load("res://Entities/specter/specter.tscn").instance()#global.aquire("Specter")
	clone.global_position = (
		global_position + Vector2(rand_range(-1,1),rand_range(-1,1)).normalized() * 16
		)
	clone.dup_limit = dup_limit
	get_parent().call_deferred("add_child", clone)
	
	# PROBLEM_NOTE: if you let this go long enough it will just lag the game.
	# i should implement an duplication limit
