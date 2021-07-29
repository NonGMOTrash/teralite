extends Control

const NORMAL_CURSOR := preload("res://UI/cursors/cursor_normal.png")
const YELLOW := Color8(242, 211, 53)

onready var header = $area/header/label
onready var damage = $area/body/damage/Label
onready var damage_comment = $area/body/damage/comment
onready var time = $area/body/time/Label
onready var time_comment = $area/body/time/comment

onready var lvl: String = get_tree().current_scene.name

var perfected := false
var level_completed := false

func _init():
	visible = false

func _ready():
	refs.level_completion = weakref(self)

func start():
	if level_completed == true:
		return
	
	$AnimationPlayer.play("animation")
	visible = true
	level_completed = true
	
	refs.stopwatch.get_ref().visible = false
	refs.stopwatch.get_ref().set_pause(true)
	refs.item_info.get_ref().visible = false
	refs.item_bar.get_ref().visible = false
	refs.health_ui.get_ref().visible = false
	
	header.text = "%s Completed" % lvl
	
	if refs.player.get_ref() == null:
		damage.text = damage.text + "? (this is a bug, pls report)"
	else:
		damage.text = damage.text + str(refs.player.get_ref().damage_taken)
		if refs.player.get_ref().damage_taken == 0:
			damage.set("custom_colors/font_color", YELLOW)
			damage_comment.set("custom_colors/font_color", YELLOW)
			damage_comment.text = "perfect!"
			perfected = true
	
	var time_value = refs.stopwatch.get_ref().time
	var minute = int(floor(time_value / 60))
	var second = int(floor(time_value - (minute * 60)))
	var tenth = stepify(time_value - ((minute*60) + second), 0.1) * 10
	if tenth == 10: tenth = 0
	if second < 10: 
		second = str(second)
		second = "0"+second
	time.text = time.text + (
		str(minute) +
		":" +
		str(second) +
		"." +
		str(tenth)
	)
	if global.level_times.has(lvl):
		if time_value < global.level_times[lvl]:
			time.set("custom_colors/font_color", YELLOW)
			time_comment.set("custom_colors/font_color", YELLOW)
			time_comment.text = "personal best!"
		if lvl in global.DEV_TIMES and time_value < global.DEV_TIMES[lvl]:
			time_comment.set("custom_colors/font_color", Color.cyan)
			time_comment.text = "speedrunner!"
	
	if lvl == "thx": return
	
	if not global.cleared_levels.has(lvl): 
		global.stars += 1
		global.cleared_levels.push_back(lvl)
	if perfected == true:
		global.perfected_levels.push_back(lvl)
	
	var stopwatch = refs.stopwatch.get_ref()
	if stopwatch == null: 
		push_warning("could not find stopwatch")
	elif not lvl in global.level_times or global.level_times[lvl] > stopwatch.time:
		global.level_times[lvl] = stopwatch.time
	
	if not lvl in global.level_deaths:
		global.level_deaths[lvl] = 0
	else:
		global.level_deaths[lvl] += 1
	
	Input.set_custom_mouse_cursor(NORMAL_CURSOR, CURSOR_ARROW, Vector2(0, 0))

func _input(_event):
	if Input.is_action_just_pressed("interact") and visible == true:
		_on_proceed_pressed()

# PROBLEM_NOTE: this is bad because it's checked every frame
func _process(delta: float) -> void:
	if level_completed:
		visible = not refs.pause_menu.get_ref().visible

func _on_proceed_pressed() -> void:
	if lvl == "thx":
		if global.last_hub == null: global.last_hub = "A"
		get_tree().change_scene("res://Levels/%s/%s-Hub.tscn" % [global.last_hub, global.last_hub])
		return
	
	var last_hub = global.last_hub
	
	if lvl == "Duel":
		get_tree().change_scene("res://Levels/thx.tscn")
	elif last_hub == null or last_hub.length() != 1:
			get_tree().change_scene("res://Levels/A/A-Hub.tscn")
	else:
		get_tree().change_scene("res://Levels/%s/%s-Hub.tscn" % [last_hub, last_hub])

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()
