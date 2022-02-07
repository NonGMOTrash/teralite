extends CanvasLayer

onready var rect_a: ColorRect = $rect_a
onready var timer_a: Timer = $rect_a/timer_a
onready var rect_b: ColorRect = $rect_b
onready var timer_b: Timer = $rect_b/timer_b
onready var rect_c: ColorRect = $rect_c
onready var timer_c: Timer = $rect_c/timer_c

func _init() -> void:
	refs.update_ref("vignette", self)

func stats_status_recieved(status: String):
	var rect: ColorRect
	var timer: Timer
	if rect_a.visible == false:
		rect = rect_a
		timer = timer_a
	elif rect_b.visible == false:
		rect = rect_b
		timer = timer_b
	elif rect_c.visible == false:
		rect = rect_c
		timer = timer_c
	else:
		return
	
	match status:
		"bleed":
			rect.material.set_shader_param("color", Color(1, 0, 0))
			timer.wait_time = refs.player.components["stats"].status_effects["bleed"].duration.time_left
			timer.start()
			rect.visible = true
		"poison":
			rect.material.set_shader_param("color", Color(0, 1, 0))
			timer.wait_time = refs.player.components["stats"].status_effects["poison"].duration.time_left
			timer.start()
			rect.visible = true
		"burning":
			rect.material.set_shader_param("color", Color(2, 1, 0))
			timer.wait_time = refs.player.components["stats"].status_effects["burning"].duration.time_left
			timer.start()
			rect.visible = true

func _on_timer_a_timeout() -> void:
	rect_a.visible = false

func _on_timer_b_timeout() -> void:
	rect_b.visible = false

func _on_timer_c_timeout() -> void:
	rect_c.visible = false
