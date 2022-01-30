extends HSlider

enum PTYPES {
	NONE = -1,
	PERCENT,
	NUMBER,
}

export var TEXT := "slider"
export(PTYPES) var PROGRESS := PTYPES.PERCENT

onready var label: Label = $label

var original_text: String

func _ready() -> void:
	label.text = TEXT
	_on_smart_slider_value_changed(value)

func _on_smart_slider_value_changed(value: float) -> void:
	if PROGRESS == PTYPES.NONE:
		return
	
	if PROGRESS == PTYPES.PERCENT:
		label.text = TEXT + " (%s" % (value / max_value * 100) + "%)"
	elif PROGRESS == PTYPES.NUMBER:
		label.text = TEXT + " (%s)" % value

