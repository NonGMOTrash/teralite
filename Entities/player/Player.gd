extends Entity

const OW = preload("res://Misc/damage.wav")

var perfect = true

export var dash_strength = 300

export var INPUT_BUFFER_FRAMES = 8
var primary_bufferframes = 0
var secondary_bufferframes = 0
var dash_bufferframes = 0

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

signal swapped_item(new_item)

# get access to other nodes or components -----------------------------------------------------------------------------
onready var hurtbox = $hurtbox
onready var iTimer = $hurtbox/Timer
onready var sprite = $sprite
onready var stats = $stats
onready var animation = $AnimationPlayer
onready var dash_cooldown = $dash_cooldown
onready var health_bar = $healthBar
onready var sound_player = $sound_player

# basic funcions -------------------------------------------------------------------------------------------
func _ready():
	global.selection = 0
	iTimer.start()
	if get_name() == "player":
		global.nodes["player"] = get_path()
	else:
		health_bar.update_bar("hurt")
		health_bar.visible = true
	
	if get_parent().owner == null: return
	
	global.emit_signal("update_health")
	global.update_cursor()
	
	connect("swapped_item", self, "swapped_item")
	swapped_item(null)

func _physics_process(_delta):
	if not animation.current_animation == "dash":
		if input_vector == Vector2.ZERO: animation.play("stand")
		else: animation.play("run")
	
	if hurtbox.iTimer.time_left > 0:
		sprite.get_material().set_shader_param("active", true)
	else:
		sprite.get_material().set_shader_param("active", false)
	
	primary_bufferframes = move_toward(primary_bufferframes, 0, 1)
	secondary_bufferframes = move_toward(secondary_bufferframes, 0, 1)
	dash_bufferframes = move_toward(dash_bufferframes, 0, 1)

func _input(_event: InputEvent) -> void: 
	# dash
	if Input.is_action_just_pressed("dash") && dash_cooldown.time_left == 0:
		if input_vector != Vector2.ZERO:
			animation.play("dash")
			apply_force(dash_strength * input_vector.normalized())
			dash_cooldown.start()
		else:
			pass
			#forces.push_back({"direction": Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)), "power": 0})
	
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

func death():
	for i in 6:
		if inventory[i] != null:
			var item = global.aquire(inventory[i])
			item.SOURCE = self
			item.global_position = global_position
			item.velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() * 100
			get_parent().call_deferred("add_child", item)
	
	emit_signal("death")
	
	if global.settings["auto_restart"] == true:
		if not global.level_deaths.has(get_tree().current_scene.get_name()):
			global.level_deaths[get_tree().current_scene.get_name()] = 0
		global.level_deaths[get_tree().current_scene.get_name()] += 1
		get_tree().reload_current_scene()
		return
	
	if self.get_name() == "player": 
		var stop = false
		
		for i in get_parent().get_child_count(): # PROBLEM_NOTE: kinda bad way to do this, use a group
			var child = get_parent().get_children()[i]
			if child is Entity and not child == self and child.is_queued_for_deletion() == false:
				if child.truName == "player":
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
					
					stop = true
					queue_free()
					return
		
		if stop == true: return
		
		if not global.level_deaths.has(get_tree().current_scene.get_name()):
			global.level_deaths[get_tree().current_scene.get_name()] = 0
		global.level_deaths[get_tree().current_scene.get_name()] += 1
		get_tree().reload_current_scene()
	else:
		queue_free()

func _on_stats_health_changed(type) -> void:
	if type != "heal" and type != "blocked": 
		global.nodes["camera"].shake(5, 15, 0.2)
		OS.delay_msec(10)
		
		# PROBLEM_NOTE: this is a terrible way to do the sound
		var sfx = Sound.new()
		sfx.stream = OW
		components["sound_player"].add_sound(sfx)
		
		perfect = false
		if global.settings["auto_restart"] == true: 
			death()
	
	global.emit_signal("update_health")
