extends Node

enum MODES {ONESHOT, STANDBY, REPEATING}

export var FREE_WHEN_EMPTY = true # if true, queue_free() if all the sounds are gone

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
			
		else:
			push_warning("sound player's child ("+child.get_name()+") was not a Sound or Global_Sound")

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
	
	if get_parent() is Entity:
		audioplayer.global_position = get_parent().global_position

func _on_sound_player_tree_exiting() -> void:
	# make all sounds non-repeating delete themselves after they finished
	for sound in sounds.values():
		if not sound.is_connected("finished", sound, "queue_free") and not sound.MODE == sound.MODES.REPEATING:
			sound.connect("finished", sound, "queue_free")
		elif sound.MODE == sound.MODES.STANDBY and sound.playing == false:
			sound.queue_free()
