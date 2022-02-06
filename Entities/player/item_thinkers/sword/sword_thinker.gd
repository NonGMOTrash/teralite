extends Thinker

export var attack_cooldown := 0.45
export var counter_duration := 0.6
export var counter_slowness_lvl := 1.0
export var counter_cooldown := 0.2
export var SLASH: PackedScene

onready var cooldown := $cooldown as Timer
onready var counter := $counter as Area2D
onready var animation := $AnimationPlayer as AnimationPlayer
onready var player_hurtbox: Area2D = player.components["hurtbox"]
onready var player_sprite: Sprite = player.components["entity_sprite"]

var can_counter := false

func _physics_process(_delta):
	counter.global_position = player.global_position + player.input_vector.normalized() * 4

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	var slash: Melee = SLASH.instance()
	slash.setup(player, global.get_look_pos())
	refs.ysort.get_ref().add_child(slash)
	cooldown.wait_time = attack_cooldown
	cooldown.start()

func secondary():
	.secondary()
	
	cooldown.wait_time = animation.get_animation("counter").length + counter_cooldown
	cooldown.start()
	
	var hitboxes = counter.get_overlapping_areas()
	if hitboxes.size() == 0:
		animation.play("counter")
		player.components["stats"].add_status_effect(
			"slowness", # effect
			animation.get_animation("counter").length, # duration
			counter_slowness_lvl # level
		)
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
	player_sprite.play_effect("invincibility", 0.625)

func set_counter_window(to: bool):
	can_counter = to
	player.can_dash = not to
	player_hurtbox.set_deferred("monitorable", not to)
	player_hurtbox.set_deferred("monitoring", not to)
	
	if to == true:
		var hitbox = player_hurtbox.get_overlapping_areas()
		if hitbox.size() == 0:
			return
		else:
			hitbox = hitbox[0] as Area2D
			player_hurtbox._on_hurtbox_area_entered(hitbox)
			hitbox._on_hitbox_area_entered(player_hurtbox)

func _on_counter_area_entered(area: Area2D) -> void:
	var area_entity: Entity = area.get_parent()
	
	if can_counter == false or (area_entity is Attack and area_entity.SOURCE == player):
		return
	
	can_counter = false
	
	if area_entity is Attack and area_entity.components["stats"].TRUE_DAMAGE <= 0:
		area_entity.velocity *= -3
		area_entity.components["stats"].change_health(-5, 0)
	
	var slash: Melee = SLASH.instance()
	slash.setup(player, area.global_position)
	refs.ysort.get_ref().call_deferred("add_child", slash)
	
	sound_player.skip_sound()
	sound_player.play_sound("counter_success")
	
	cooldown.wait_time = counter_cooldown
	cooldown.start()
	
	player.components["stats"].add_status_effect(
		"slowness", # effect
		-animation.get_animation("counter").length, # duration
		-counter_slowness_lvl # level
	)
