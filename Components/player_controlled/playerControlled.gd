# PROBLEM_NOTE: this component should probably be deleted and made to be part of the player scene
extends Node2D

const CURSOR_EMPTY := preload("res://UI/cursors/cursor_empty.png")
const CROSSHAIR_RANGE: float = 60.0

onready var parent: Entity = self.owner
onready var controller_crosshair: Sprite = $controller_crosshair

var time_since_last_look: float = 0.0

func _draw() -> void:
	pass#draw_texture(Input.get_current_cursor_shape())

func _on_playerControlled_tree_entered() -> void:
	get_parent().components["player_controlled"] = self

func _input(_event):	
	parent.input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	parent.input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	controller_crosshair.visible = global.joy_connected
	if !global.joy_connected:
		return
	
	var joy_vector := Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
	if joy_vector != Vector2.ZERO:
		global.controller_look_direction = joy_vector
		time_since_last_look = 0
	else:
		if time_since_last_look < 4:
			time_since_last_look += get_physics_process_delta_time()
		else:
			global.controller_look_direction = parent.input_vector
	
	if global.controller_look_direction != Vector2.ZERO:
		controller_crosshair.visible = true
		controller_crosshair.position = global.controller_look_direction * CROSSHAIR_RANGE
	else:
		controller_crosshair.visible = false
	
	if parent.inventory[global.selection] == null:
		controller_crosshair.texture = CURSOR_EMPTY
