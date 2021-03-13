extends Node

enum MODES {ONESHOT, STANDBY, REPEATING}

export var FREE_WHEN_EMPTY = false # if true, queue_free() if all the sounds are gone

var sounds = {
	#"soundname": node
}

func _on_sound_player_tree_entered() -> void:
	if get_parent() is Entity:
		get_parent().components["sound_player"] = self

func _ready():
	if get_child_count() == 0 and FREE_WHEN_EMPTY == true: 
		queue_free()
		return
	
	for child in get_children():
		if child is Sound or child is Global_Sound:
			sounds[child.get_name()] = child
			
			child.stop()
			
			if child.MODE != MODES.STANDBY:
				child.connect("finished", self, "sound_finished", [child.name])
			
			remove_child(child)
			
			if child.SCENE_PERSIST == true:
				global.add_child(child)
			else:
				get_tree().current_scene.add_child(child)
			
			if child.autoplay == true:
				child.play()

func sound_finished(sound_name):
	var sound = sounds[sound_name]
	
	if sound.MODE == MODES.ONESHOT:
		sound.queue_free()
		sounds.erase(sound_name)
	elif sound.MODE == MODES.REPEAT:
		sound.play()
	
	if FREE_WHEN_EMPTY == true and sounds.size() == 0:
		queue_free()

func add_sound(audioplayer:Node):
	
	if not audioplayer is Sound and not audioplayer is Global_Sound:
		push_error("sound_player add_sound was given a node that wasn't a Sound or Global_Sound")
	 
	if audioplayer.stream == null:
		push_error("a Sound / Global_Sound added to sound_player did not have a AudioStream")
		return
	
	if audioplayer.SCENE_PERSIST == true:
		global.add_child(audioplayer)
	else:
		get_tree().current_scene.add_child(audioplayer)
	
	if audioplayer.autoplay == true:
		audioplayer.play()
	
	if audioplayer in sounds: breakpoint
	if audioplayer is Sound:
		var src = get_parent()
		if audioplayer in sounds: breakpoint
		if src is Thinker: src = src.get_parent()
		if audioplayer in sounds: breakpoint
		if src is Entity:
			audioplayer.global_position = src.global_position
			if audioplayer in sounds: breakpoint

func create_sound(
	stream: AudioStream, 
	global_sound = false,
	mode = Sound.MODES.ONESHOT, 
	auto_play = true, 
	scene_persist = false, 
	auto_set_physical = true,
	volume = 0.0
	):
		var sfx 
		if global_sound == false: sfx = Sound.new()
		else: sfx = Global_Sound.new()
		sfx.stream = stream
		sfx.MODE = mode
		sfx.AUTO_PLAY = auto_play
		sfx.SCENE_PERSIST = scene_persist
		if global_sound == false:
			sfx.AUTO_SET_PHYSICAL = auto_set_physical
		sfx.volume_db = volume
		add_sound(sfx)

func _on_sound_player_tree_exiting() -> void:
	# make all sounds non-repeating delete themselves after they finished
	for sound in sounds.values():
		if not sound.is_connected("finished", sound, "queue_free") and not sound.MODE == sound.MODES.REPEATING:
			sound.connect("finished", sound, "queue_free")
		elif sound.MODE == sound.MODES.STANDBY and sound.playing == false:
			sound.queue_free()