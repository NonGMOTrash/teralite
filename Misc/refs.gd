extends Node

var level: Navigation2D
var player: Entity
var canvas_layer: CanvasLayer
var health_ui: Control
var item_bar: Control
var item_info: VBoxContainer
var stopwatch: Label
var pause_menu: ColorRect
var camera: Camera2D
var ysort: YSort
var world_tiles: TileMap
var navigation: TileMap
var low_walls: TileMap
var background_tiles: TileMap
var background: Sprite
var level_completion: ColorRect
var ambiance: Global_Sound
var ambient_lighting: CanvasModulate
var transition: TextureRect
var vignette: CanvasLayer
var fps: Label

class safe:
	var level := weakref(Object())
	var player := weakref(Object())
	var canvas_layer := weakref(Object())
	var health_ui := weakref(Object())
	var item_bar := weakref(Object())
	var item_info := weakref(Object())
	var stopwatch := weakref(Object())
	var pause_menu := weakref(Object())
	var camera := weakref(Object())
	var ysort := weakref(Object())
	var world_tiles := weakref(Object())
	var background_tiles := weakref(Object())
	var background := weakref(Object())
	var navigation := weakref(Object())
	var level_completion := weakref(Object())
	var ambiance := weakref(Object())
	var ambient_lighting := weakref(Object())
	var transition := weakref(Object())
	var vignette := weakref(Object())

signal recieved_ref(ref)

func update_ref(ref: String, node: Node):
	if not ref in self:
		push_error("can't update nonexistant ref '%s'" % ref)
		return
	
	set(ref, node)
	safe.set(ref, weakref(node))
	emit_signal("recieved_ref", ref)
