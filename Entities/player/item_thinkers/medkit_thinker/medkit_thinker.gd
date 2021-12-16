extends Thinker

const CURSOR1: Texture = preload("res://UI/cursors/cursor_medkit.png")
const CURSOR2: Texture = preload("res://UI/cursors/cursor_medkit2.png")

export var instant_healing: int
export var regen_level: float
export var regen_duration: float
export var delay: float
export var delay_slowness: float

onready var timer := $Timer

var ready := false

func _ready() -> void:
	timer.wait_time = delay
	ready = true

func primary():
	if ready == true:
		ready = false
		player.components["stats"].add_status_effect("slowness", delay, delay_slowness)
		timer.start()
		update_cursor(CURSOR2)
		sound_player.play_sound("use")
		global.emit_signal("update_item_info", # set a condition to null to hide it
			display_name, # current item
			null, # extra info
			timer.wait_time, # item bar max
			timer.time_left, # item bar value
			delay # bar timer duration
		)

func _on_Timer_timeout() -> void:
	player.components["stats"].change_health(instant_healing, 0, "heal")
	player.components["stats"].add_status_effect("regeneration", regen_duration, regen_level)
	player.components["stats"].add_status_effect("infection", -99, -99)
	player.components["stats"].add_status_effect("bleed", -99, -99)
	player.components["stats"].add_status_effect("poison", -99, -99)
	delete()

func unselected():
	timer.stop()
	ready = true
	sound_player.skip_sound("use")
