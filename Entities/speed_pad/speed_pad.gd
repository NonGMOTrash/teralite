extends Entity

export var speed_level: float
export var speed_duration: float

onready var sound_player: Node = $sound_player

func _on_boost_body_entered(body: Node) -> void:
	if not body is Entity or body is Attack:
		return
	var stats: Node = body.components["stats"]
	if stats == null:
		return
	
	var speed: Status_Effect = stats.status_effects["speed"]
	if speed == null:
		stats.add_status_effect("speed", speed_level, speed_duration)
		sound_player.play_sound("sound")
	elif speed.duration.time_left < speed_duration:
		speed.duration.wait_time = speed_duration
		speed.duration.start()
		sound_player.play_sound("sound")
