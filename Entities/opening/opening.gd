extends Entity

const EIGHT_DIRECTIONS := [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),
		Vector2(-1,1),Vector2(0,1),Vector2(1,1)]

export var entity: PackedScene
export var times: int = 1
export var rate: float = 10
export var delay: float = 2
export var eight_directional := false
export var symbol_frame := 0

onready var rate_timer: Timer = $rate_timer
onready var animation: AnimationPlayer = $AnimationPlayer
onready var max_times: int = times
onready var symbol: Sprite = $symbol

var target_pos: Vector2
var tracking_target: Entity
var started_spawning := false

func _ready() -> void:
	rate_timer.wait_time = delay
	rate_timer.start()
	symbol.frame = symbol_frame

func _on_rate_timer_timeout() -> void:
	if started_spawning == false:
		rate_timer.wait_time = 1 / rate
		rate_timer.start()
		started_spawning = true
		return
	
	var new_entity: Entity = entity.instance()
	
	if new_entity is Attack:
		if is_instance_valid(tracking_target):
			new_entity.setup(self, tracking_target.global_position)
		elif eight_directional:
			new_entity.setup(self, global_position + EIGHT_DIRECTIONS[max_times - times])
		else:
			new_entity.setup(self, target_pos)
	else:
		new_entity.position = global_position
	
	refs.ysort.add_child(new_entity)
	new_entity.faction = "future"
	
	times -= 1
	if times == 0:
		animation.play("close")
		rate_timer.stop()
