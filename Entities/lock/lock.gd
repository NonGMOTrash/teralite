extends Entity

onready var animation := $AnimationPlayer

var unlocked: bool = true

func unlock():
	unlocked
	animation.play("unlock")
	$sound_player.play_sound("unlock")
