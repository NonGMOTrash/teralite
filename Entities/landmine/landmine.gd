extends Entity

onready var detection: Area2D = $detection
onready var delay: Timer = $delay
onready var arm_delay: Timer = $arm_delay
onready var sound: Node = $sound_player

func _init() -> void:
	res.aquire_entity("explosion")

func _on_detection_body_entered(body: Node) -> void:
	if arm_delay.time_left == 0 and global.get_relation(self, body) != "friendly" and !body.INANIMATE:
		sound.play_sound("warning")
		delay.start()

func _on_arm_delay_timeout() -> void:
	for body in detection.get_overlapping_bodies():
		if body is Entity and global.get_relation(self, body) != "friendly" and !body.INANIMATE:
			sound.play_sound("warning")
			delay.start()

func _on_delay_timeout() -> void:
	var explosion := res.aquire_entity("explosion")
	explosion.position = global_position
	refs.ysort.get_ref().add_child(explosion)
	queue_free()
