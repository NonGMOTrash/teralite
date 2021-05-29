extends Entity

export(PackedScene) var dust_particles
export(PackedScene) var player_death

var damage_taken = 0
var death_message: String = ";-;"

export var dash_strength = 300
export var dash_buffer = 8

var inventory = [
	null, #slot 0 (right)
	null, #slot 1 (middle)
	null, #slot 2 (left)
	null, #passive 1
	null, #passive 2
	null #passive 3
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

var force_death_msg = false

func _ready():
	dash_buffer *= (1.0/60.0)
	global.selection = 0
	iTimer.start()
	if get_name() == "player":
		global.nodes["player"] = get_path()
		# PROBLEM_NOTE: this is inconsistant with other things in global.nodes, most are direct references
		# instead of paths. it is a bit nessesarly for the player though, because the path is needed to check
		# if the player still exists with get_node_or_null(). really glad is_instance_valid() doesn't work '-'
		# i should use weakrefs
	else:
		health_bar.update_bar(0, 0, 0)
		health_bar.visible = true
	
	if get_parent().owner == null: return
	
	global.emit_signal("update_health")
	global.update_cursor()
	
	connect("swapped_item", self, "swapped_item")
	swapped_item(null)

func _physics_process(_delta):
	if get_global_mouse_position().x > global_position.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	if not animation.current_animation == "dash":
		if input_vector == Vector2.ZERO: animation.play("stand")
		else:#if not animation.current_animation == "run": 
			animation.play("run")
#			if sprite.flip_h == false:
#				animation.play("run")
#			else:
#				animation.play_backwards("run")
	
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
		var particles = dust_particles.instance()
		particles.rotation_degrees = rad2deg(direction.angle())
		global.nodes["ysort"].call_deferred("add_child", particles)
		yield(particles, "ready")
		particles.global_position = global_position
	
	buffered_dash = Vector2.ZERO

func _input(_event: InputEvent) -> void: 
	# dash
	if Input.is_action_just_pressed("dash"):
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
			global.update_cursor()
		if Input.is_action_just_pressed("swap_left"): 
			global.selection -= 1
			if global.selection < 0: global.selection = 2
			emit_signal("swapped_item", inventory[global.selection])
			global.update_cursor()
		if Input.is_action_just_pressed("hotkey_left"): 
			global.selection = 0
			emit_signal("swapped_item", inventory[global.selection])
			global.update_cursor()
		if Input.is_action_just_pressed("hotkey_mid"): 
			global.selection = 1
			emit_signal("swapped_item", inventory[global.selection])
			global.update_cursor()
		if Input.is_action_just_pressed("hotkey_right"): 
			global.selection = 2
			emit_signal("swapped_item", inventory[global.selection])
			global.update_cursor()

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
	emit_signal("death")
	
	if force_death_msg == false:
		yield(self, "updated_death_message")
	
	for i in 6:
		if inventory[i] != null:
			var item = res.aquire(inventory[i]).instance()
			item.SOURCE = self
			item.global_position = global_position
			item.velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() * 100
			get_parent().call_deferred("add_child", item)
	
	if name == "player": 
		var found_replacement = false
		
		for child in get_parent().get_children(): # PROBLEM_NOTE: kinda bad way to do this, use a group
			if child is Entity and not child == self and child.is_queued_for_deletion() == false:
				if child.truName == "player":
					
					if global.settings["auto_restart"] == true:
						child.death()
						continue
					
					name = "dedplayer"
					child.name = "player"
					child.components["health_bar"].visible = false
					global.nodes["player"] = child.get_path()
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
		global.nodes["stopwatch"].pause(true)
		
		var elements = []
		elements.append(global.nodes["health_ui"])
		elements.append(global.nodes["item_bar"])
		elements.append(global.nodes["item_info"])
		
		for element in elements:
			if element != null:
				element.visible = false
	
	var my_death = player_death.instance()
	if name == "player" and global.nodes["level_completed"].visible == false:
		my_death.simple_mode = false
	my_death.flip_h = sprite.flip_h
	my_death.death_message = death_message
	get_parent().add_child(my_death)
	my_death.global_position = global_position
	
	queue_free()

func _on_stats_health_changed(_type, result, net) -> void:
	if result != "heal" and result != "blocked": 
		if result == "hurt" and name == "player":
			global.nodes["camera"].shake(5, 15, 0.2)
			OS.delay_msec(34)
		
		if net < 0:
			damage_taken += abs(net)
		
		if global.settings["perfection_mode"] == true: 
			death()
	
	global.emit_signal("update_health")

func _on_hurtbox_got_hit(by_area, _type) -> void:
	force_death_msg = false
	var entity = by_area.get_parent()
	var entity_name = entity.truName
	var source
	var source_name
	if entity is Attack and get_node_or_null(entity.SOURCE_PATH) != null:
		source = entity.SOURCE
		source_name = source.truName
	
	if entity_name == "player" or source_name == "player":
		death_message = "Death by stupidity."
	elif entity.truName == "player":
		death_message = "Death by betrayal."
	elif source != null and source.truName == "player":
		death_message = "Death by betrayal."
	else:
		match entity_name:
			#"player": death_message = "Death by betrayal."
			"crate": death_message = "Death by... a crate? what??"
			"chaser": death_message = "Death by chaser."
			"brute_chaser": death_message = "Death by brute chaser."
			"gold_chaser": death_message = "Death by golden chaser."
			"ultra_chaser": death_message = "Death by ultra chaser."
			"spikes", "red_spikes", "diamond_spikes": death_message = "Death by impalement."
			"fire": death_message = "Death by burning."
			"slash": death_message = "Death by %s's blade." % source_name
			"stab": death_message = "Death by %s's dagger." % source_name
			"arrow": death_message = "Death by %s's arrow." % source_name
			_: death_message = "death message messed up, report pls ;-;"
	
	prints("before:", death_message)
	death_message = death_message.replace("_", " ")
	prints("after:", death_message)
	
	emit_signal("updated_death_message")

func _on_dash_cooldown_timeout() -> void:
	if buffered_dash != Vector2.ZERO:
		dash(buffered_dash)
