extends Node

const DBG = true

const PASSWORD = "9938168C44797E256687EAF632ED3939D15A2C6C8BFCE46E8EC94120713B2170"
const SAVEFILE = "user://nightmare_save"
const URL = "http://localhost:9001"
onready var AUDIO = get_node("/root/AudioPlayer")

var current_fps = 0
var enemies_spawned = 0
var current_difficulty = 5
var music_style = ""

func reset():
	current_fps = 0
	enemies_spawned = 0
	current_difficulty = 0
