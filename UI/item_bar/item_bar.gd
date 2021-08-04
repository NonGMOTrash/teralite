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

func _ready():
	refs.item_bar = weakref(self)
	global.connect("update_item_bar", self, "update_icons")
	if global.settings["hide_bar"] == false: bar.visible = true
	visible = true

func _input(_event: InputEvent):
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

func update_icons(inventory):
	for i in 6:
		match_icon(i, inventory[i])
	
	if (
		global.settings["hide_bar"] == true and
		inventory[0] == null and
		inventory[1] == null and
		inventory[2] == null
	):
		bar.visible = false
	else:
		bar.visible = true

func match_icon(slot, item):
	if item == null:
		replace_icon(slot, null)
	else:
		if not res.data.has(item+"_texture"):
			push_warning("res.gd does not have %s_texture" % item)
			replace_icon(slot, GENERIC)
		else:
			replace_icon(slot, res.aquire_texture(item+"_texture"))
#	match item:
#		null:
#			replace_icon(slot, null)
#		"pistol":
#			replace_icon(slot, PISTOL)
#		"white_armor":
#			replace_icon(slot, WHITE_ARMOR)
#		"sword":
#			replace_icon(slot, SWORD)
#		"bow":
#			replace_icon(slot, BOW)

func replace_icon(slot, texture: Texture):
	if slot == 0:
		left_icon.texture = texture
	elif slot == 1:
		mid_icon.texture = texture
	elif slot == 2:
		right_icon.texture = texture
	elif slot == 3:
		passive1.texture = texture
	elif slot == 4:
		passive2.texture = texture
	elif slot == 5:
		passive3.texture = texture
