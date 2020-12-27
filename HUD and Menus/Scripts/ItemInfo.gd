extends VBoxContainer

onready var iName = $ItemName
onready var iInfo = $ItemInfo
onready var iBar = $Bar
onready var timer = $Timer

func _ready():
	global.connect("update_item_info", self, "update_item_info")
	visible = true

func update_item_info(current_item, extra_info, item_bar_max, item_bar_value, bar_timer_duration):
	if current_item != null:
		iName.visible = true
		iName.text = current_item
	else:
		iName.visible = false
		
	if extra_info != null:
		iInfo.visible = true
		iInfo.text = extra_info
	else:
		iInfo.visible = false
	
	if item_bar_max != null && item_bar_max > 0 && item_bar_value != null && item_bar_value > 0:
		iBar.visible = true
		iBar.max_value = item_bar_max
		iBar.value = item_bar_value
	else:
		iBar.visible = false
	
	if bar_timer_duration != null && bar_timer_duration > 0:
		timer.wait_time = bar_timer_duration
		timer.start()

func _process(_delta):
	if timer.time_left == 0: return
	iBar.value = timer.time_left

