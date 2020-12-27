extends "res://Entities/Items Pickups/item.gd"

func on_pickup(player):
	var lvl = get_tree().current_scene.get_name()
	if lvl == "thx": 
		get_tree().change_scene_to(load("res://Levels/A/A_hub.tscn"))
		return

	if not global.cleared_levels.has(lvl): 
		global.stars += 1
		global.cleared_levels.push_back(str(lvl))
	if (
		not global.perfected_levels.has(lvl) 
		and player.perfect == true
		): 
			global.perfected_levels.push_back(str(lvl))
	
	# PROBLEM_NOTE: this is a horrible way to do this
	var stopwatch = get_tree().current_scene
	if stopwatch == null: global.debug_msg(self, 1, "could not find current_scene")
	else: stopwatch = stopwatch.find_node("CanvasLayer")
	if stopwatch == null: global.debug_msg(self, 1, "could not find CanvasLayer")
	else: stopwatch = stopwatch.find_node("stopwatch")
	if stopwatch == null: global.debug_msg(self, 1, "could not find stopwatch")
	elif not global.level_times.has(lvl) or stopwatch.time < global.level_times[lvl]:
		global.level_times[lvl] = stopwatch.time
	
	
	if not lvl in global.level_deaths:
		global.level_deaths[lvl] = 0
	
	if lvl == "A-14":
		get_tree().change_scene_to(load("res://Levels/thx.tscn"))
		return

	get_tree().change_scene_to(load("res://Levels/A/A_hub.tscn"))
