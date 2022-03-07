extends Projectile

export var bounces: int

var old_velocity: Vector2

onready var sound_player: Node = $sound

func _physics_process(delta: float) -> void:
	if not is_on_wall():
		old_velocity = velocity

func collided():
	if bounces == 0:
		.collided()
		return
	
	# this is stupid but it seems to work
	# better solution would be to just use move_and_collide, but my stupid use of inheritence has
	# prevented my from doing that
	var ss := get_world_2d().direct_space_state
	var ray := ss.intersect_ray(global_position + Vector2(5,0), global_position + Vector2(-5,0),
			[], 1)
	if ray:
		velocity = Vector2(-old_velocity.x, old_velocity.y)
	else:
		velocity = Vector2(old_velocity.x, -old_velocity.y)
	
	bounces -= 1
	sound_player.play_sound("bounce")
