extends Thinker

const HEAT_COLOR := Color(0.94, 0.35, 0.35)

export var BLAST: PackedScene
export var MAX_HEAT: int
export var COOL_SPEED: float

var heat: int = 0

onready var cooldown_timer: Timer = $cooldown_timer
onready var shot_timer: Timer = $shot_timer
onready var spawner: Node = $spawner

func _ready() -> void:
	pass

func get_ready() -> bool:
	if heat >= MAX_HEAT or cooldown_timer.time_left != 0: 
		return false
	else:
		return true

func primary():
	.primary()
	
	var blast: Projectile = BLAST.instance()
	blast.setup(player, global.get_look_pos())
	refs.ysort.get_ref().add_child(blast)
	
	heat += 1
	shot_timer.wait_time = 1.2
	shot_timer.start()
	cooldown_timer.start()
	
	spawner.spawn()
	
	if heat >= MAX_HEAT:
		sound_player.play_sound("overheat")

func _physics_process(_delta: float) -> void:
	if heat > 0 and shot_timer.time_left == 0:
		heat -= 1
		shot_timer.wait_time = 1.0 / COOL_SPEED
		shot_timer.start()
	
	if global.selection != slot:
		return
	
	var held_item: Node2D = player.components["held_item"]
	held_item.modulate = lerp(Color.white, HEAT_COLOR, float(heat) / MAX_HEAT)
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info 
		MAX_HEAT, # item bar max 
		heat + 0.01, # item bar value 
		null # bar timer duration
	)

func unselected():
	player.components["held_item"].modulate = Color.white
