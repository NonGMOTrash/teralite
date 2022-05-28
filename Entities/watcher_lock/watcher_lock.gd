extends Entity

enum S {
	DOWN,
	UP
}

export(S) var state:int

onready var brain := $brain
onready var animation := $AnimationPlayer
onready var sound_player := $sound_player
onready var cooldown := $cooldown

func _on_brain_think() -> void:
	if state == S.UP and brain.targets.size() == 0:
		# lower
		if cooldown.time_left != 0:
			cooldown.start()
			return
		animation.play_backwards("rise")
		sound_player.play_sound("lower")
	elif state == S.DOWN and brain.targets.size() != 0:
		# rise
		animation.play("rise")
		sound_player.play_sound("rise")


var chaser: Entity
func _process(_delta: float) -> void:
	chaser = refs.ysort.find_node("chaser", true)
	if chaser:
		brain.add_target(chaser)
