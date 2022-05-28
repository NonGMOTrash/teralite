extends Entity

const OPENING := preload("res://Entities/opening/opening.tscn")
const EXPLOSION := preload("res://Entities/explosion/explosion.tscn")
const BULLET := preload("res://Entities/Attacks/Projectile/small_bullet/small_bullet.tscn")
const DRONE := preload("res://Entities/drone/drone.tscn")
const KEYBLAST := preload("res://Entities/Attacks/Projectile/keyblast/keyblast.tscn")
const KING := preload("res://Entities/king/king.tscn")
const QUEEN := preload("res://Entities/queen/queen.tscn")
const POISON_DROP := preload("res://Entities/Attacks/Projectile/poison_drop/poison_drop.tscn")
const ROGUE := preload("res://Entities/knight/rogue/rogue.tscn")
const ROCKET_SCORPIAN := preload("res://Entities/rocket_scorpian/rocket_scorpian.tscn")

onready var animation: AnimationPlayer = $AnimationPlayer
onready var stats: Node = $stats
onready var eye: Sprite = $eye
onready var brain: Node2D = $brain
onready var sound: Node = $sound_player

export var eye_shaking := false

var stored_target: Entity
var played_spotted_sound := false

func _ready() -> void:
	brain.SIGHT_RANGE = 999
	brain.sight.scale = Vector2(999, 999)

func _on_action_lobe_action(action, target) -> void:
	if animation.current_animation == "death":
		return
	
	stored_target = target
	animation.play_backwards("open")
	animation.queue(action)
	
	match action:
		"spawn_explosions":
			for _i in range(9):
				var opening := OPENING.instance()
				opening.entity = EXPLOSION
				opening.symbol_frame = 4
				opening.position = get_opening_pos(200, 64)
				refs.ysort.add_child(opening)
		"spawn_bullets":
			var opening := OPENING.instance()
			opening.entity = BULLET
			opening.symbol_frame = 3
			opening.position = stored_target.global_position
			var dist2tar: float = opening.position.distance_to(stored_target.global_position)
			var tries: int = 10
			while dist2tar < opening.position.distance_to(self.global_position):
				opening.position = stored_target.global_position + Vector2(
						rand_range(-120, 120), rand_range(-80, 80))
				dist2tar = opening.position.distance_to(stored_target.global_position)
				prints(dist2tar, opening.position.distance_to(self.global_position))
				tries -= 1
				if tries == 0:
					break
			opening.times = 6
			opening.rate = 6
			opening.tracking_target = stored_target
			refs.ysort.add_child(opening)
		"spawn_drones":
			for _i in range(4):
				var opening := OPENING.instance()
				opening.entity = DRONE
				opening.symbol_frame = 2
				opening.position = get_opening_pos(64, 32, 2)
				opening.target_pos = global_position
				refs.ysort.add_child(opening)
		"spawn_keyblasts": 
			var direction := Vector2(rand_range(-1, 1), rand_range(-1,1)).normalized()
			var pdirection := Vector2(direction.y, -direction.x) # perpendicular
			var line_pos: Vector2 = global_position + 50 * direction
			for i in range(8):
				var opening := OPENING.instance()
				opening.entity = KEYBLAST #     \/ +1 for extra space in the middle
				opening.symbol_frame = 1
				opening.position = line_pos + ((i+1) * 24 * pdirection)
				opening.target_pos = opening.position + (-direction * 100)
				opening.delay = 1.3
				refs.ysort.add_child(opening)
			for i in range(8):
				var opening := OPENING.instance()
				opening.entity = KEYBLAST
				opening.symbol_frame = 1
				opening.position = line_pos - ((i+1) * 24 * pdirection)
				opening.target_pos = opening.position + (-direction * 100)
				opening.delay = 1.3
				refs.ysort.add_child(opening)
		"spawn_monarchs":
			var opening_a := OPENING.instance()
			opening_a.entity = KING
			opening_a.symbol_frame = 5
			opening_a.position = get_opening_pos(32, 8, 5)
			refs.ysort.add_child(opening_a)
			var opening_b := OPENING.instance()
			opening_b.entity = QUEEN
			opening_b.symbol_frame = 5
			opening_b.position = get_opening_pos(64, 8, 5)
			refs.ysort.add_child(opening_b)
		"spawn_poison":
			for _i in range(7):
				var opening := OPENING.instance()
				opening.entity = POISON_DROP
				opening.symbol_frame = 7
				opening.position = get_opening_pos(175, 32)
				opening.eight_directional = true
				opening.times = 8
				opening.rate = 999
				refs.ysort.add_child(opening)
		"spawn_rogues":
			for _i in range(9):
				var opening := OPENING.instance()
				opening.entity = ROGUE
				opening.symbol_frame = 0
				opening.position = get_opening_pos(200, 32)
				refs.ysort.add_child(opening)
		"spawn_scorpian":
			var opening := OPENING.instance()
			opening.entity = ROCKET_SCORPIAN
			opening.symbol_frame = 6
			opening.position = get_opening_pos(100, 64)
			refs.ysort.add_child(opening)

func get_opening_pos(leap_dist:float = 100, min_spacing:float = 32, min_leaps:int = 1) -> Vector2:
	var pos: Vector2 = global_position
	var leaps: int = 0
	while (
		leaps < min_leaps or
		pos.distance_to(global_position) < min_spacing or
		pos.distance_to(stored_target.global_position) < min_spacing
	):
		pos += Vector2(rand_range(-leap_dist, leap_dist), rand_range(leap_dist, -leap_dist))
		leaps += 1
	return pos

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name != "open":
		animation.play("open")

func _on_brain_found_target() -> void:
	if not played_spotted_sound:
		sound.play_sound("spotted")
		played_spotted_sound = true
	
	if brain.targets.size() == 1:
		animation.play("open")

func _on_brain_lost_target() -> void:
	if brain.targets.size() == 0:
		animation.play_backwards("open")

func _process(delta: float) -> void:
	if eye_shaking:
		eye.offset = Vector2(rand_range(-0.4, 0.4), rand_range(-0.2, 0.2))
	else:
		eye.offset = Vector2.ZERO

func death():
	animation.play("death")
	$health_bar.visible = false

func death_real(): # more real than a goblin
	.death()

func explosion():
	var explosion: Entity = EXPLOSION.instance()
	explosion.position = global_position + Vector2(rand_range(-25, 25), rand_range(-25, 25))
	refs.ysort.add_child(explosion)
