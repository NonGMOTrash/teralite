extends Thinker

export var flame_speed: float
export var flame_duration: float

onready var cooldown: Timer = $cooldown

func _ready() -> void:
	$sound_player/shoot.TRACKING_TARGET = player.get_path()

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	var flame := res.aquire_entity("fire")
	var direction := player.global_position.direction_to(global.get_look_pos()).normalized()
	flame.global_position = player.global_position + (direction * 16)
	flame.apply_force(direction * flame_speed + player.velocity * 0.4)
	refs.ysort.get_ref().add_child(flame)
	cooldown.start()
	yield(flame, "tree_entered")
	flame.fuel.wait_time = flame_duration

func _input(event: InputEvent):
	if global.selection != slot:
		return
	
	if Input.is_action_just_pressed("primary_action"):
		sound_player.play_sound("start")
		sound_player.play_sound("shoot")
	elif Input.is_action_just_released("primary_action"):
		sound_player.play_sound("stop")
		sound_player.stop_sound("shoot")
