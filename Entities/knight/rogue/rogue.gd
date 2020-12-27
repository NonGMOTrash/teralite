extends "res://Entities/knight/knight.gd"

func attack():
	var target_pos
	if brain.target != null: target_pos = brain.target.global_position
	else: target_pos = brain.last_seen
	
	var stab = global.aquire("Stab")
	stab.setup(self, target_pos)
	get_parent().add_child(stab) 
