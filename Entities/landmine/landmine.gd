extends Entity

const EXPLOSION := preload("res://Entities/explosion/explosion.tscn")

onready var detection: Area2D = $detection
onready var delay: Timer = $delay
onready var arm_delay: Timer = $arm_delay
onready var sound: Node = $sound_player

func _on_detection_body_entered(body: Node) -> void:
	if (
		arm_delay.time_left == 0 and
		global.get_relation(self, body) != "friendly" and
		body.INANIMATE == false or body.truName == "fire"
	):
		sound.play_sound("warning")
		delay.start()

func _on_arm_delay_timeout() -> void:
	for body in detection.get_overlapping_bodies():
		if (
			arm_delay.time_left == 0 and
			global.get_relation(self, body) != "friendly" and
			body.INANIMATE == false or body.truName == "fire"
		):
			sound.play_sound("warning")
			delay.start()

func _on_delay_timeout() -> void:
	var explosion: Entity = EXPLOSION.instance()
	explosion.position = global_position
	refs.ysort.get_ref().add_child(explosion)
	queue_free()
