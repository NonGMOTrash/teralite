extends Node
class_name Status_Effect

onready var duration = $duration
onready var trigger = $trigger
onready var stats = get_parent()
onready var entity: Entity = stats.get_parent()

export(float, 0.01, 999) var level := 1.0
export(bool) var decimal_levels := true
export(bool) var USE_TRIGGER := true
export(float, 0.01, 999) var TRIGGER_TIME := 2.5
export(float, 0.01, 999) var DURATION_TIME := 5.0

func _ready() -> void:
	stats.status_effects[name] = self
	
	duration.wait_time = max(DURATION_TIME, 0.01)
	duration.start()
	
	var x = level
	if decimal_levels == false:
		x = floor(level)
		if x < 1: 
			x = 1
	
	trigger.wait_time = max(TRIGGER_TIME / x, 0.01)
	
	if USE_TRIGGER == true:
		trigger.start()
	else:
		trigger.queue_free()

func change_duration(amount: float):
	duration.wait_time = clamp(duration.wait_time + amount, 0.01, 999)
	duration.start()

func change_level(amount: float):
# warning-ignore:narrowing_conversion
	level = level + amount
	if level <= 0: _on_duration_timeout()
	
	var x = level
	if decimal_levels == false:
		x = floor(level)
		if x == 0:
			x = 1
	
	trigger.wait_time = TRIGGER_TIME / x
	trigger.start()

func _on_duration_timeout() -> void:
	depleted()
	stats.status_effects[get_name()] = null
	queue_free()

func _on_trigger_timeout() -> void:
	triggered()

func depleted(): pass

func triggered(): pass
