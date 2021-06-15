extends Node
class_name Status_Effect

onready var duration = $duration
onready var trigger = $trigger

export(float, 0.01, 999) var level := 1.0
export(float, 0.01, 999) var INIT_DURATION := 0.01
export(bool) var USE_TRIGGER := true
export(float, 0.01, 999) var TRIGGER_TIME := 2.5
export(float, 0.01, 999) var DEFAULT_DURATION := 5.0

func _ready() -> void:
	get_parent().status_effects[name] = self
	
	duration.wait_time = DEFAULT_DURATION # generic default, should never be used
	var x = floor(level)
	if x < 1: x = 1
	trigger.wait_time = TRIGGER_TIME / x
	duration.wait_time = INIT_DURATION
	duration.start()
	
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
	var x = floor(level)
	if x == 0: x += 0.01
	trigger.wait_time = TRIGGER_TIME / x
	trigger.start()

func _on_duration_timeout() -> void:
	depleted()
	get_parent().status_effects[get_name()] = null
	queue_free()

func _on_trigger_timeout() -> void:
	triggered()

func depleted(): pass

func triggered(): pass
