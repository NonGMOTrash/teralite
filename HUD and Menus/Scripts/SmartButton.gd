extends Button

export var selected_color = Color8(242, 211, 53)
export var normal_color = Color8(255, 255, 255)

func _ready() -> void:
	color_set(normal_color)
	
func color_set(color):
	set_deferred("custom_colors/font_color", color)
	set_deferred("custom_colors/font_color_pressed", color)
	set_deferred("custom_colors/font_color_hover", color)

func _on_SmartButton_focus_entered() -> void:
	color_set(selected_color)

func _on_SmartButton_focus_exited() -> void:
	color_set(normal_color)

func _on_SmartButton_mouse_entered() -> void:
	grab_focus()
