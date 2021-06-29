extends Thinker

export var bonus_healing: int
export var regen_duration: float
export var regen_lvl: float

var used := false

func _init() -> void:
	res.allocate("gold_apple")

func get_ready() -> bool:
	return not used

func primary():
	.primary()
	used = true
	var stats: Node = player.components["stats"]
	stats.change_health(0, bonus_healing, "heal")
	stats.add_status_effect("regeneration", regen_duration, regen_lvl)
	sound_player.play_sound("eat")
	delete()
