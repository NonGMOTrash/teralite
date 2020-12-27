extends Control

onready var bar = $bar
onready var leftIcon = $bar/leftIcon
onready var midIcon = $bar/midIcon
onready var rightIcon = $bar/rightIcon
onready var passive1 = $HBoxContainer/passive1
onready var passive2 = $HBoxContainer/passive2
onready var passive3 = $HBoxContainer/passive3

# all icons preloaded:
const ITEM_BAR_0 = preload("res://HUD and Menus/item_bar/itemBar0.png")
const ITEM_BAR_1 = preload("res://HUD and Menus/item_bar/itemBar1.png")
const ITEM_BAR_2 = preload("res://HUD and Menus/item_bar/itemBar2.png")

const PISTOL = preload("res://Entities/Items Pickups/pistol/pistol.png")
const WHITE_ARMOR = preload("res://Entities/Items Pickups/white_armor/white_armor.png")
const SWORD = preload("res://Entities/Items Pickups/sword/sword.png")
const BOW = preload("res://Entities/Items Pickups/bow/bow.png")

func _ready():
	global.connect("update_item_bar", self, "update_icons")
	if global.settings["hide_bar"] == false: visible = true

func item_changed():
	global.update_cursor()
	# PROBLEM_NOTE: this should probably be done in the player script

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("swap_right"): item_changed()
	if Input.is_action_just_pressed("swap_left"): item_changed()
	if Input.is_action_just_pressed("hotkey_left"): item_changed()
	if Input.is_action_just_pressed("hotkey_mid"): item_changed()
	if Input.is_action_just_pressed("hotkey_right"): item_changed()
	
	match global.selection:
		0: bar.texture = ITEM_BAR_0
		1: bar.texture = ITEM_BAR_1
		2: bar.texture = ITEM_BAR_2
	
	#global.selection = selection

func update_icons(inventory):
	for i in 6: match_icon(i, inventory[i])
	global.update_cursor()
	if global.settings["hide_bar"] == true and inventory[0]==null and inventory[1]==null and inventory[2]==null:
		visible = false
	else:
		visible = true

func match_icon(slot, item):
	match item:
		null:
			replace_icon(slot, null)
		"pistol":
			replace_icon(slot, PISTOL)
		"white_armor":
			replace_icon(slot, WHITE_ARMOR)
		"sword":
			replace_icon(slot, SWORD)
		"bow":
			replace_icon(slot, BOW)

func replace_icon(slot, texture):
	if slot == 0:
		leftIcon.texture = texture
	elif slot == 1:
		midIcon.texture = texture
	elif slot == 2:
		rightIcon.texture = texture
	elif slot == 3:
		passive1.texture = texture
	elif slot == 4:
		passive2.texture = texture
	elif slot == 5:
		passive3.texture = texture
