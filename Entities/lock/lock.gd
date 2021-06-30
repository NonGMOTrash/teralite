extends Entity

onready var animation := $AnimationPlayer

func unlock():
	animation.play("unlock")
	$sound_player.play_sound("unlock")
