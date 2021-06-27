extends Thinker

func primary():
	player.components["stats"].add_status_effect("speed", 15, 1.8)
	sound_player.play_sound("use")
	delete()
