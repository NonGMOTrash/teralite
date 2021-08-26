extends PanelContainer

onready var main := $main
onready var delete_confirmation := $delete_confirmation

onready var icon := $main/HBoxContainer/icon
onready var save_name := $main/HBoxContainer/name
onready var version := $main/HBoxContainer/version
onready var stars := $main/HBoxContainer2/stars
onready var deaths := $main/HBoxContainer2/deaths
onready var time := $main/HBoxContainer2/time
onready var saves_list: GridContainer = get_parent()

signal play(save_name)
signal delete

func _ready() -> void:
	name = save_name.text
	assert(saves_list.name == "saves_list")

func _on_play_pressed() -> void:
	emit_signal("play", name)
	global.load_save(save_name.text)

func _on_delete_pressed() -> void:
	main.visible = false
	delete_confirmation.visible = true

func _on_cancel_pressed() -> void:
	main.visible = true
	delete_confirmation.visible = false

func _on_final_delete_pressed() -> void:
	emit_signal("delete")
	global.delete_save(save_name.text)
	queue_free()
