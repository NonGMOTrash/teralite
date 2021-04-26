extends "res://Entities/Items Pickups/item.gd"

const LEVEL_COMPLETED = preload("res://UI/level_completed/level_completed.tscn")

func on_pickup(player):
	var destination: PackedScene
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
	
	var stopwatch = global.nodes["stopwatch"]
	if stopwatch == null: 
		push_warning("could not find stopwatch")
	else:
		global.level_times[lvl] = stopwatch.time
	
	if not lvl in global.level_deaths:
		global.level_deaths[lvl] = 0
	
	if lvl == "A-14":
		destination = load("res://Levels/thx.tscn")
		return
	
	match get_tree().current_scene.WORLD:
		"A":
			destination = load("res://Levels/A/A_hub.tscn")
		_:
			push_error("level has invalid WORLD: '%s'" % get_tree().current_scene.WORLD)
			destination = load("res://Levels/A/A_hub.tscn")
	
	var level_completed = LEVEL_COMPLETED.instance()
	
	level_completed.destination = destination
	
	level_completed.level_name = lvl
	match lvl:
		"A-1": level_completed.level_name = "Redwood"
		"A-2": level_completed.level_name = "Midpoint"
		"A-3": level_completed.level_name = "Spiral"
		"A-4": level_completed.level_name = "Brick"
		"A-5": level_completed.level_name = "Barricade"
		"A-6": level_completed.level_name = "Sprint"
		"A-7": level_completed.level_name = "Quickstep"
		"A-8": level_completed.level_name = "Enterance"
		"A-9": level_completed.level_name = "Timber"
		"A-10": level_completed.level_name = "Gauntlet"
		"A-11": level_completed.level_name = "Army"
		"A-12": level_completed.level_name = "Ambushed"
		"A-13": level_completed.level_name = "Caged"
		"A-14": level_completed.level_name = "Monarch"
		"A-15": level_completed.level_name = "Duo"
		"A-secret": level_completed.level_name = "Shadow"
		
	
	level_completed.time_value = stopwatch.time
	
	var p_stats = player.components["stats"]
	level_completed.health_value = (p_stats.HEALTH + p_stats.BONUS_HEALTH) / (p_stats.MAX_HEALTH + 0.0)
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(level_completed)
