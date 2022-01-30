# PROBLEM_NOTE: this component should probably be deleted and made to be part of the player scene
extends Node2D

onready var parent = self.owner

var draw_cursor := false

func _draw() -> void:
	pass#draw_texture(Input.get_current_cursor_shape())

func _on_playerControlled_tree_entered() -> void:
	get_parent().components["player_controlled"] = self

func _input(_event):	
	parent.input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	parent.input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	var joy_vector := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joy_vector != Vector2.ZERO:
		global.look_pos = parent.global_position + joy_vector * 32
		draw_cursor = true
	elif parent.input_vector != Vector2.ZERO:
		global.look_pos = parent.global_position + parent.input_vector * 32
		draw_cursor = false
