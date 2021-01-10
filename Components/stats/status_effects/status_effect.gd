extends Node
class_name Status_Effect

onready var duration = $duration
onready var trigger = $trigger

export(float, 0.01, 999) var level = 1
export(float, 0.01, 999) var INIT_DURATION = 0.01
export(float, 0.01, 999) var TRIGGER_TIME = 2.5

func _ready() -> void:
	get_parent().status_effects[get_name()] = self
	
	duration.wait_time = 5 # generic default, should never be used
	var x = floor(level)
	if x < 1: x = 1
	trigger.wait_time = TRIGGER_TIME / x
	if INIT_DURATION <= 0: print("INIT_DURATION:",INIT_DURATION)
	duration.wait_time = INIT_DURATION
	duration.start()
	trigger.start()

func change_duration(amount: float):
	duration.wait_time = clamp(duration.wait_time + amount, 0.01, 999)
	duration.start()

func change_level(amount: float):
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

func depleted(): print("depleted")

func triggered(): print("triggered")
