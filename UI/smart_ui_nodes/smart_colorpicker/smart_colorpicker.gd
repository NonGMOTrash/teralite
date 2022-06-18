extends ColorPickerButton

onready var label: Label = $label

func _ready() -> void:
	label.text = self.text
	text = ""

func _on_smart_colorpicker_picker_created() -> void:
	var picker: ColorPicker = get_child(1).get_child(0)
	# hides everything except the actual hue selection square
	for i in picker.get_child_count():
		if i == 0:
			# shrinks the hue selection square to a reasonable size
			var square: Control = picker.get_child(0).get_child(0)
			var slider: Control = picker.get_child(0).get_child(1)
			square.rect_min_size = Vector2(100, 100)
			square.margin_bottom = 100
			square.margin_right = 100
			slider.rect_min_size = Vector2(20, 100)
			slider.margin_bottom = 100
			slider.margin_right = 20
			
			continue
		
		picker.get_child(i).visible = false
