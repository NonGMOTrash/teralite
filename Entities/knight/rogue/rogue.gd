extends "res://Entities/knight/knight.gd"

func attack():
	var closest_target = brain.closest_target()
	var target_pos = Vector2.ZERO
	if not closest_target is String: 
		target_pos = closest_target.global_position
	
	var stab = global.aquire("Stab")
	stab.setup(self, target_pos)
	add_child(stab) 
	stab.SOURCE_PATH = self.get_path()
	attack_cooldown.start()
