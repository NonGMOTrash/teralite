extends Item

export var top_speed_boost: int
export var acceleration_boost: int
export var slowdown_boost: int

func on_pickup(player: Entity):
	player.TOP_SPEED += top_speed_boost
	player.ACCELERATION += acceleration_boost
	player.SLOWDOWN += slowdown_boost
