extends Thinker

export var attack_cooldown := 0.45
export var counter_duration := 0.6
export var counter_slowness_lvl := 1.0
export var counter_cooldown := 0.2

onready var cooldown := $cooldown as Timer
onready var counter := $counter as Area2D
onready var animation := $AnimationPlayer as AnimationPlayer
onready var player_hurtbox := get_parent().components["hurtbox"] as Area2D
onready var player_sprite := get_parent().components["entity_sprite"] as Sprite

var can_counter := false

func _init():
	res.allocate("slash")

func _physics_process(_delta):
	counter.global_position = player.global_position + player.velocity

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	quick_spawn("slash")
	cooldown.wait_time = attack_cooldown
	cooldown.start()

func secondary():
	.secondary()

	cooldown.wait_time = animation.get_animation("counter").length + counter_cooldown
	cooldown.start()

	player.components["stats"].add_status_effect(
		"slowness", # effect
		animation.get_animation("counter").length, # duration
		counter_slowness_lvl # level
	)

	var hitboxes = counter.get_overlapping_areas()
	if hitboxes.size() == 0:
		animation.play("counter")
	else:
		var closest_hitbox: Area2D
		var distance: float = INF
		for hitbox in hitboxes:
			if counter.global_position.distance_to(hitbox.global_position) < distance:
				closest_hitbox = hitbox
				distance = counter.global_position.distance_to(hitbox.global_position)

		can_counter = true
		_on_counter_area_entered(closest_hitbox)

	sound_player.play_sound("counter_ready")
	player_sprite.play_effect("invincibility", 0.25/0.4)

func set_counter_window(to: bool):
	can_counter = to
	player_hurtbox.set_deferred("monitorable", not to)
	player_hurtbox.set_deferred("monitoring", not to)

func _on_counter_area_entered(area: Area2D) -> void:
	if can_counter == false:
		return

	can_counter = false

	var area_entity: Entity = area.get_parent()
	if area_entity is Attack:
		area_entity.death()

	var slash = res.aquire_melee("slash")
	slash.setup(player, area.global_position)
	global.nodes["ysort"].call_deferred("add_child", slash)

	sound_player.play_sound("counter_success")

	cooldown.wait_time = 0.1
	cooldown.start()

	player.components["stats"].add_status_effect(
		"slowness", # effect
		-animation.get_animation("counter").length, # duration
		-counter_slowness_lvl # level
	)
