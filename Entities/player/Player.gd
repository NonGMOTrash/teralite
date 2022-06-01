extends Entity

const CURSOR_EMPTY = preload("res://UI/cursors/cursor_empty.png")

export(PackedScene) var dash_effect
export(PackedScene) var player_death

var damage_taken = 0
var death_message: String = "death message missing :("
var damage_pause_count: int = 0

export var dash_strength = 300
export var dash_buffer = 8

var inventory = [
	null, # slot 0 (right)
	null, # slot 1 (middle)
	null, # slot 2 (left)
	null, # passive 1
	null, # passive 2
	null  # passive 3
]

var item_name = ""
var item_bar_max = 0.0
var item_bar_value = 0.0
var item_info_text = ""
var buffered_dash: Vector2

signal swapped_item(new_item)
signal updated_death_message

onready var hurtbox = $hurtbox
onready var iTimer = $hurtbox/Timer
onready var sprite = $sprite
onready var stats = $stats
onready var animation = $AnimationPlayer
onready var dash_cooldown = $dash_cooldown
onready var health_bar = $healthBar
onready var sound_player = $foot_stepper
onready var held_item = $held_item
onready var damage_pause_cooldown := $damage_pause_cooldown

var force_death_msg := false
var can_dash := true

func _on_player_tree_entered() -> void:
	if name == "player":
		refs.camera.startat(global_position)

func _ready():
	dash_buffer *= (1.0/60.0)
	global.selection = 0
	iTimer.start()
	if get_name() == "player":
		refs.update_ref("player", self)
	else:
		health_bar.update_bar(0, 0, 0)
		health_bar.visible = true
	
	var camera = refs.camera
	camera.smoothing_enabled = false
	camera.global_position = global_position
	camera.smoothing_enabled = true
	
	if get_parent().owner == null: return
	
	global.emit_signal("update_health")
	
	connect("swapped_item", self, "swapped_item")
	swapped_item(null)

func _physics_process(_delta):
	if global.get_look_pos().x > global_position.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	if global.get_look_pos().y > global_position.y:
		if sprite.texture != sprite.front_texture:
			sprite.texture = sprite.front_texture
	else:
		if sprite.texture != sprite.back_texture:
			sprite.texture = sprite.back_texture
	
	if not animation.current_animation == "dash":
		if input_vector == Vector2.ZERO:
			animation.play("stand")
		elif rooted == false:
			animation.play("run")

	if hurtbox.iTimer.time_left > 0:
		sprite.get_material().set_shader_param("active", true)
	else:
		sprite.get_material().set_shader_param("active", false)

func dash(direction: Vector2 = input_vector) -> void:
	if direction != Vector2.ZERO:
		animation.play("dash")
		apply_force(dash_strength * direction.normalized())
		dash_cooldown.start()

		# particle effect
		var effect = dash_effect.instance()
		effect.rotation_degrees = rad2deg(direction.angle())
		refs.ysort.call_deferred("add_child", effect)
		yield(effect, "ready")
		effect.global_position = global_position + Vector2(0, 6)

	buffered_dash = Vector2.ZERO

func _input(_event: InputEvent) -> void:
	# dash
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			if dash_cooldown.time_left == 0:
				dash()
			elif dash_cooldown.time_left <= dash_buffer:
				buffered_dash = input_vector

	# for item switching:
	if get_name() == "player":
		if Input.is_action_just_pressed("swap_right"):
			global.selection += 1
			if global.selection > 2: global.selection = 0
			emit_signal("swapped_item", inventory[global.selection])
		
		if Input.is_action_just_pressed("swap_left"):
			global.selection -= 1
			if global.selection < 0: global.selection = 2
			emit_signal("swapped_item", inventory[global.selection])
		
		if Input.is_action_just_pressed("hotkey_left"):
			global.selection = 0
			emit_signal("swapped_item", inventory[global.selection])
		
		if Input.is_action_just_pressed("hotkey_mid"):
			global.selection = 1
			emit_signal("swapped_item", inventory[global.selection])
		
		if Input.is_action_just_pressed("hotkey_right"):
			global.selection = 2
			emit_signal("swapped_item", inventory[global.selection])
		
		if inventory[global.selection] == null:
				Input.set_custom_mouse_cursor(CURSOR_EMPTY, Input.CURSOR_ARROW, Vector2(22.5, 22.5))

func swapped_item(new_item):
	if new_item == null:
		global.emit_signal("update_item_info", # set a condition to null to hide it
			null, # current item
			null, # extra info
			null, # item bar max
			null, # item bar value
			null # bar timer duration
		)
		held_item.sprite.texture = null
		held_item.reversed = false

func death():
	if dead == true:
		return
	
	dead = true
	emit_signal("death")
	
	if force_death_msg == false:
		yield(self, "updated_death_message")
	
	if name == "player":
		var found_replacement = false
		
		for child in get_parent().get_children(): # PROBLEM_NOTE: kinda bad way to do this, use a group
			if child is Entity and not child == self and child.is_queued_for_deletion() == false:
				if child.truName == "player":
					
					if global.settings.get("auto_restart") == true:
						child.death()
						continue
					
					name = "dedplayer"
					child.name = "player"
					child.components["health_bar"].visible = false
					refs.update_ref("player", child)
					global.emit_signal("update_health")
					global.emit_signal("update_item_bar", child.inventory)
					global.emit_signal("update_item_info", # set a condition to null to hide it
						child.inventory[global.selection], # current item
						null, # extra info
						null, # item bar max
						null, # item bar value
						null # bar timer duration
					)
					
					var my_death = player_death.instance()
					if name == "player":
						my_death.simple_mode = false
					my_death.flip_h = sprite.flip_h
					my_death.death_message = death_message
					get_parent().add_child(my_death)
					my_death.global_position = global_position
					
					found_replacement = true
					queue_free()
					return
		
		if found_replacement == true: return
		
		if not global.level_deaths.has(get_tree().current_scene.get_name()):
			global.level_deaths[get_tree().current_scene.get_name()] = 0
		global.level_deaths[get_tree().current_scene.get_name()] += 1
		
		# hide ui
		refs.stopwatch.set_pause(true)
		
		var elements = [
			refs.health_ui,
			refs.item_bar,
			refs.item_info,
		]
		
		for element in elements:
			if element != null:
				element.visible = false
	
	var my_death = player_death.instance()
	if name == "player" and refs.level_completion.visible == false:
		my_death.simple_mode = false
	my_death.flip_h = sprite.flip_h
	my_death.death_message = death_message
	get_parent().add_child(my_death)
	my_death.global_position = global_position
	
	queue_free()

func _on_stats_health_changed(_type, result, net) -> void:
	if result != "heal" and result != "block":
		if result == "hurt" and name == "player" and damage_pause_count < 2:
			refs.camera.shake(5, 15, 0.2)
			#OS.delay_msec((2/60.0) * 1000)
			damage_pause_count += 1
			damage_pause_cooldown.start()
		
		if net < 0:
			damage_taken += abs(net)
		
		if global.settings["perfection_mode"] == true:
			death()
		
	global.emit_signal("update_health")

func _on_hurtbox_got_hit(by_area, _type) -> void:
	force_death_msg = false
	var entity: Entity = by_area.get_parent()
	var entity_name: String = entity.truName
	var source: Entity
	var source_name: String
	if entity is Attack and is_instance_valid(entity.SOURCE):#get_node_or_null(entity.SOURCE_PATH) != null:
		source = entity.SOURCE
		source_name = source.truName
	
	if entity_name == "player" or source_name == "player":
		death_message = "you killed yourself :("
	elif entity.truName == "player":
		death_message = "betrayal!"
	elif source != null and source.truName == "player":
		death_message = "betrayal!"
	elif "spikes" in entity_name:
		death_message = "impaled by some spikes"
	elif entity_name == "explosion":
		death_message = "blown to pieces"
	else:
		match entity_name:
			"crate": death_message = "killed by a crate, somehow..."
			"chaser": death_message = "killed by a chaser"
			"brute_chaser": death_message = "killed by a brute chaster"
			"gold_chaser": death_message = "killed by a golden chaser"
			"ultra_chaser": death_message = "killed by an ultra chaser"
			"fire": death_message = "burned"
			"slash": death_message = "slashed by a %s" % source_name
			"swipe": death_message = "severed by a %s" % source_name
			"poke": death_message = "speared by a %s" % source_name
			"stab": death_message = "stabbed by a %s" % source_name
			"arrow": death_message = "shot by a %s" % source_name
			"bolt": death_message = "shot by a %s" % source_name
			"magic": death_message = "killed by a %s's magic" % source_name
			"blow_dart": death_message = "incapicitated by %s's blowgun" % source_name
			"slime": death_message = "killed by a slime"
			"bullet": death_message = "shot by a %s" % source_name
			"shotgun_shell": death_message = "shot by a %s" % source_name
			"big_bullet": death_message = "shot by a %s" % source_name
			"bullet": death_message = "shot by a %s" % source_name
			"syringe": death_message = "infected by a %s" % source_name
			"rocket": death_message = "blown up by a %s" % source_name
			"zombie": death_message = "joined the horde"
			"heart_mimic": death_message = "killed by a %s" % source_name
			"stalker": death_message = "trampled by a %s" % source_name
			"rocket_scorpian": death_message = "mauled by a rocket scorpian"
			"king": death_message = "crushed by a %s" % source_name
			"laser": death_message = "shot by a %s" % source_name
			"energy": death_message = "shot by a %s" % source_name
			"keyblast": death_message = "shot by a %s" % source_name
			_: death_message = "(death message error)"
	
	death_message = death_message.replace("_", " ")
	
	emit_signal("updated_death_message")

func _on_dash_cooldown_timeout() -> void:
	if buffered_dash != Vector2.ZERO:
		dash(buffered_dash)

func _on_damge_pause_cooldown_timeout() -> void:
	damage_pause_count -= 1
	if damage_pause_count > 0:
		damage_pause_cooldown.start()

