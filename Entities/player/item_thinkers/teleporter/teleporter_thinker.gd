extends Thinker

const TELEPORTATION := preload("res://Effects/teleportation/teleportation.tscn")
const HITBOX := preload("res://Components/hitbox/hitbox.tscn")

export var tele_distance: int
export var telefrag_radius: float

onready var cooldown: Timer = $cooldown
onready var telefrag: Area2D = HITBOX.instance()
onready var telefrag_window: Timer = $telefrag_window

func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = telefrag_radius
	telefrag.get_child(0).shape = shape
	telefrag.TRUE_DAMAGE = 99
	telefrag.TEAM_ATTACK = false
	telefrag.CLANKS = false

func get_ready() -> bool:
	return (cooldown.time_left == 0)

func primary():
	var tele_pos: Vector2 = player.global_position
	tele_pos += tele_pos.direction_to(global.get_look_pos()).normalized() * tele_distance
	
	# prevents you from teleporting inside a wall
	var nav: TileMap = refs.navigation
	var forward_warps: int = 2
	while nav.get_cellv(nav.world_to_map(tele_pos)) == -1:
		if forward_warps > 0:
			tele_pos = tele_pos.move_toward(player.global_position, -16)
			forward_warps -= 1
			if forward_warps == 0:
				tele_pos = player.global_position
				tele_pos += tele_pos.direction_to(global.get_look_pos()).normalized() * tele_distance
		else:
			tele_pos = tele_pos.move_toward(player.global_position, 16)
			if tele_pos.distance_to(player.global_position) <= 6:
				break
	
	var effect: Effect = TELEPORTATION.instance()
	effect.global_position = player.global_position
	refs.ysort.add_child(effect)
	
	player.global_position = tele_pos
	player.animation.play("dash")
	sound_player.play_sound("sound")
	cooldown.start()
	
	player.add_child(telefrag)
	telefrag_window.start()
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info 
		cooldown.wait_time, # item bar max 
		cooldown.time_left, # item bar value 
		cooldown.wait_time # bar timer duration
	)

func _on_telefrag_window_timeout() -> void:
	player.remove_child(telefrag)

func _on_cooldown_timeout() -> void:
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
