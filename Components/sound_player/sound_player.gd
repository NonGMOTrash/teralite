extends Node

enum MODES {ONESHOT, STANDBY, REPEATING}

# PROBLEM_NOTE: would be better to have different free modes: MANUAL, WHEN_EMPTY, AFTER_USE
export var FREE_WHEN_EMPTY = false # if true, queue_free() if all the sounds are gone

var sounds := {
	#"soundname": node
}

func _on_sound_player_tree_entered():
	if get_parent() is Entity:
		get_parent().components["sound_player"] = self

func _ready():
	if get_child_count() == 0 and FREE_WHEN_EMPTY == true:
		queue_free()
		return

	for child in get_children():
		if not child is Sound and not child is Global_Sound:
			continue

		sounds[child.get_name()] = child

		child.stop()

		if child.MODE != MODES.STANDBY:
			child.connect("finished", self, "sound_finished", [child.name])

		remove_child(child)

		if child.SCENE_PERSIST == true:
			global.add_child(child)
		else:
			get_tree().current_scene.call_deferred("add_child", child)

		if child.autoplay == true:
			child.play()

		yield(child, "tree_entered")

		if child is Sound:
			child.global_position = get_position_for(child)

func sound_finished(sound_name):
	var sound = sounds[sound_name]

	if sound.MODE == MODES.ONESHOT:
		sound.queue_free()
		sounds.erase(sound_name)
	elif sound.MODE == MODES.REPEATING:
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

	if audioplayer is Sound and not audioplayer is Global_Sound:
		audioplayer.global_position = get_position_for(audioplayer)

func create_sound(
	stream: AudioStream,
	global_sound = false,
	mode = Sound.MODES.ONESHOT,
	auto_play = true,
	scene_persist = false,
	auto_set_physical = true,
	volume = 0.0,
	audio_bus = "sound"
	):
		var sfx
		if global_sound == false:
			sfx = Sound.new()
		else:
			sfx = Global_Sound.new()
		sfx.stream = stream
		sfx.MODE = mode
		sfx.AUTO_PLAY = auto_play
		sfx.SCENE_PERSIST = scene_persist
		if global_sound == false:
			sfx.AUTO_SET_PHYSICAL = auto_set_physical
		sfx.volume_db = volume
		sfx.bus = audio_bus
		add_sound(sfx)

func play_sound(sound_name:String) -> void:
	var sfx = sounds.get(sound_name)
	if sfx != null:
		sfx.play()
		if sfx is Sound:
			sfx.global_position = get_position_for(sfx)
	else:
		push_error("could not find sound effect '"+sound_name+"' in sound_player")

func stop_sound(sound_name:String) -> void:
	var sfx = sounds.get(sound_name)
	if sfx != null:
		sfx.stop()
		if sfx is Sound:
			sfx.global_position = get_position_for(sfx)
	else:
		push_error("could not find sound effect '"+sound_name+"' in sound_player")

func get_position_for(sound:Sound) -> Vector2:
	var src = get_parent()
	if not src is Entity: src = src.get_parent()
	if src is Entity:
		return src.global_position
	else:
		push_warning("src was not an Entity")
		return Vector2.ZERO

func skip_sound(sound:Sound = null):
	if sound == null:
		sound = sounds.values()[0]
	sound.stop()

func _on_sound_player_tree_exiting() -> void:
	# make all sounds  delete themselves after they finished
	for sound in sounds.values():
		if sound.is_inside_tree() == false or sound.MODE == sound.MODES.REPEATING:
			sound.queue_free()
			continue
		
		if not sound.is_connected("finished", sound, "queue_free"):
			sound.connect("finished", sound, "queue_free")
		elif sound.MODE == sound.MODES.STANDBY and sound.playing == false:
			sound.queue_free()
