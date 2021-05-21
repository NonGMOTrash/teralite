extends Control

const A_HUB = "res://Levels/A/A-Hub.tscn"

onready var header = $area/header/label
onready var time = $area/stats/time/value
onready var damage = $area/stats/damage/value

onready var lvl = get_tree().current_scene.name

func _init():
	visible = false

func _ready():
	global.nodes["level_completed"] = self

func get_player():
	return get_node_or_null(global.nodes["player"])

func start():
	$AnimationPlayer.play("animation")
	visible = true
	
	global.nodes["stopwatch"].visible = false
	global.nodes["item_info"].visible = false
	global.nodes["item_bar"].visible = false
	global.nodes["health_ui"].visible = false
	
	header.text = "%s Completed" % lvl
	
	if get_player() == null:
		damage.text = "? (this is a bug, pls report)"
	else:
		#var p_stats = get_player().components["stats"]
		#damage.text = str(
		#	((p_stats.HEALTH + p_stats.BONUS_HEALTH) / (p_stats.MAX_HEALTH + 0.0)) * 100
		#) + "%"
		damage.text = str(get_player().damage_taken)
		if damage.text == "0":
			damage.set("custom_colors/font_color", Color8(242, 211, 53))
	
	var time_value = global.nodes["stopwatch"].time
	var minute = int(floor(time_value / 60))
	var second = int(floor(time_value - (minute * 60)))
	var tenth = stepify(time_value - ((minute*60) + second), 0.1) * 10
	if tenth == 10: tenth = 0
	if second < 10: 
		second = str(second)
		second = "0"+second
	time.text = (
		str(minute) +
		":" +
		str(second) +
		"." +
		str(tenth)
		)
	if global.level_times.has(lvl):
		if time_value < global.level_times[lvl]:
			time.set("custom_colors/font_color", Color8(242, 211, 53))

func _input(_event):
	if Input.is_action_just_pressed("interact") and visible == true:
		if lvl == "thx":
			get_tree().change_scene_to(load("res://Levels/A/A-Hub.tscn"))
			return
		
		if not global.cleared_levels.has(lvl): 
			global.stars += 1
			global.cleared_levels.push_back(str(lvl))
		if (
			not global.perfected_levels.has(lvl) 
			and get_player() != null
			and get_player().damage_taken == 0
			): 
				global.perfected_levels.push_back(str(lvl))
		
		var stopwatch = global.nodes["stopwatch"]
		if stopwatch == null: 
			push_warning("could not find stopwatch")
		else:
			global.level_times[lvl] = stopwatch.time
		
		if not lvl in global.level_deaths:
			global.level_deaths[lvl] = 0
		
		if lvl == "Monarch":
			get_tree().change_scene_to_(load("res://Levels/thx.tscn"))
		else:
			match get_tree().current_scene.WORLD:
				"A":
					get_tree().change_scene_to(load("res://Levels/A/A-Hub.tscn"))
				_:
					push_error("level has invalid WORLD: '%s'" % get_tree().current_scene.WORLD)
					get_tree().change_scene_to(load("res://Levels/A/A-Hub.tscn"))
