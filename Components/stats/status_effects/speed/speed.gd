extends Status_Effect

onready var top_speed_change = entity.TOP_SPEED * (level / 5.0)
onready var acceleration_change = entity.ACCELERATION * (level / 4.0)
onready var slowdown_change = entity.SLOWDOWN * (level / 15.0)

var original_slowdown: int
var dash_change: float
var original_dash: int

func _ready():
	if entity.truName == "player":
		dash_change = entity.dash_strength * (level / 6.5)
		original_dash = entity.dash_strength
	start()

# i have to have start() as a seperate function because slowness is inheireited from this and it needs
# to override the _ready logic, but can't because that's a virtual function
func start():
	original_slowdown = entity.SLOWDOWN
	
	entity.TOP_SPEED += top_speed_change
	entity.ACCELERATION += acceleration_change
	entity.SLOWDOWN = max(entity.SLOWDOWN - slowdown_change, 0)
	
	if entity.truName == "player":
		entity.dash_strength += dash_change

func depleted():
	entity.TOP_SPEED -= top_speed_change
	entity.ACCELERATION -= acceleration_change
	entity.SLOWDOWN = min(entity.SLOWDOWN + slowdown_change, original_slowdown)
	
	if entity.truName == "player":
		entity.dash_strength -= dash_change
