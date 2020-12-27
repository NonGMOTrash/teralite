extends Node2D
class_name Prop

export var random_flip_h = true
export var random_flip_v = false

var random

func _ready() -> void:
	z_index += 201
	if random_flip_h == false or random_flip_v == false:
		return
	
	for i in get_child_count():
		# for random fliping PROBLEM_NOTE: this doesn't work
		var child = get_children()[i]
		if child is Sprite or child is AnimatedSprite:
			if random_flip_h == true and randi() % 2 + 1 == 1:
				child.flip_h = not child.flip_h
			if random_flip_v == true and randi() % 2 + 1 == 1:
				child.flip_v = not child.flip_v
