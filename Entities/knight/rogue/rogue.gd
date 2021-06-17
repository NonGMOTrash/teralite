extends "res://Entities/knight/knight.gd"

const SWIPE = preload("res://Entities/Attacks/Melee/swipe/swipe.tscn")

func attack():
	var closest_target = brain.get_closest_target()
	var target_pos = Vector2.ZERO
	if not closest_target is String: 
		target_pos = closest_target.global_position
	
	var swipe = SWIPE.instance()
	swipe.setup(self, target_pos)
	add_child(swipe) 
	swipe.SOURCE_PATH = self.get_path()
	attack_cooldown.start()
