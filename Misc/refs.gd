extends Node

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

signal got_player
