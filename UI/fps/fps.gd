extends Label

export var good_color: Color
export var okay_color: Color
export var bad_color: Color
export var horrible_color: Color

func _on_fps_tree_entered() -> void:
	refs.update_ref("fps", self)

func _ready() -> void:
	visible = global.settings["show_fps"]

func _process(delta: float) -> void:
	var fps: float = Engine.get_frames_per_second()
	text = str(fps)
	
	if fps >= 60.0:
		set_deferred("custom_colors/font_color", good_color)
	elif fps >= 30.0:
		set_deferred("custom_colors/font_color", okay_color)
	elif fps >= 24.0:
		set_deferred("custom_colors/font_color", bad_color)
	else:
		set_deferred("custom_colors/font_color", horrible_color)
