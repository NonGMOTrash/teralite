extends VBoxContainer

onready var item_name = $ItemName
onready var info = $ItemInfo
onready var bar_container = $HBoxContainer
onready var bar = $HBoxContainer/Bar
onready var timer = $Timer

func _ready():
	refs.item_info = weakref(self)
	global.connect("update_item_info", self, "update_item_info")
	visible = true

func update_item_info(current_item, extra_info, item_bar_max, item_bar_value, bar_timer_duration):
	if current_item != null:
		item_name.visible = true
		item_name.text = current_item
	else:
		item_name.visible = false

	if extra_info != null:
		info.visible = true
		info.text = extra_info
	else:
		info.visible = false

	if item_bar_max != null && item_bar_max > 0 && item_bar_value != null && item_bar_value > 0:
		bar_container.visible = true
		bar.max_value = item_bar_max
		bar.value = item_bar_value
		bar.step = item_bar_max / 100
	else:
		bar_container.visible = false

	if bar_timer_duration != null && bar_timer_duration > 0:
		timer.wait_time = bar_timer_duration
		timer.start()

func _process(_delta):
	if timer.time_left == 0: return
	bar.value = timer.time_left

