extends Entity

enum S {
	DOWN,
	UP
}

export(S) var state:int

onready var brain := $brain
onready var animation := $AnimationPlayer
onready var sound_player := $sound_player

func _on_brain_think() -> void:
	if state == S.UP and brain.targets.size() == 0:
		animation.play_backwards("rise")
		sound_player.play_sound("rise")
	elif state == S.DOWN and brain.targets.size() != 0:
		animation.play("rise")
		sound_player.play_sound("lower")
