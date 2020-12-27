extends Node2D

onready var parent = self.owner

func _on_playerControlled_tree_entered() -> void:
	get_parent().components["player_controlled"] = self

func _input(_event):
	parent.input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	parent.input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
