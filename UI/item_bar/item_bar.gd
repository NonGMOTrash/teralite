extends Control

onready var bar = $bar
onready var left_icon = $bar/left_icon
onready var mid_icon = $bar/mid_icon
onready var right_icon = $bar/right_icon
onready var passive1 = $HBoxContainer/passive1
onready var passive2 = $HBoxContainer/passive2
onready var passive3 = $HBoxContainer/passive3

const ITEM_BAR_0 = preload("res://UI/item_bar/item_bar_0.png")
const ITEM_BAR_1 = preload("res://UI/item_bar/item_bar_1.png")
const ITEM_BAR_2 = preload("res://UI/item_bar/item_bar_2.png")
const GENERIC = preload("res://Misc/generic.png")
const NORMAL_COLOR := Color8(46, 34, 47)
const SELECTED_COLOR := Color8(249, 194, 43)

func _init() -> void:
	refs.update_ref("item_bar", self)

func _ready():
	if global.settings["hide_bar"] == true:
		bar.visible = false
	visible = true

func _input(_event: InputEvent):
	var player: Entity = refs.player
	if (
		global.settings["hide_bar"] == true and
		player.inventory[0] == null and
		player.inventory[1] == null and
		player.inventory[2] == null
	):
		bar.visible = false
	else:
		bar.visible = true
	
	match global.selection:
		0:
			bar.texture = ITEM_BAR_0
			left_icon.get_material().set_shader_param("color", SELECTED_COLOR)
			mid_icon.get_material().set_shader_param("color", NORMAL_COLOR)
			right_icon.get_material().set_shader_param("color", NORMAL_COLOR)
		1:
			bar.texture = ITEM_BAR_1
			left_icon.get_material().set_shader_param("color", NORMAL_COLOR)
			mid_icon.get_material().set_shader_param("color", SELECTED_COLOR)
			right_icon.get_material().set_shader_param("color", NORMAL_COLOR)
		2:
			bar.texture = ITEM_BAR_2
			left_icon.get_material().set_shader_param("color", NORMAL_COLOR)
			mid_icon.get_material().set_shader_param("color", NORMAL_COLOR)
			right_icon.get_material().set_shader_param("color", SELECTED_COLOR)

func replace_icon(slot: int, texture: Texture):
	if is_queued_for_deletion():
		return
	
	match slot:
		0: left_icon.texture = texture
		1: mid_icon.texture = texture
		2: right_icon.texture = texture
		3: passive1.texture = texture
		4: passive2.texture = texture
		5: passive3.texture = texture
