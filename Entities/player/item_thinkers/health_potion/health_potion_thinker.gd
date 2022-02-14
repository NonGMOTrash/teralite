extends Thinker

export(int, 0, 99) var healing: int
export var THROWN_HEALTH_POTION: PackedScene

func primary():
	player.components["stats"].change_health(healing, 0, "heal")
	sound_player.play_sound("drink")
	delete()

func secondary():
	var thrown_health_potion: Projectile = THROWN_HEALTH_POTION.instance()
	thrown_health_potion.setup(player, global.get_look_pos())
	refs.ysort.add_child(thrown_health_potion)
	delete()
