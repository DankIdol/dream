extends Node2D

const menu_music = preload("res://Assets/Music/Assassin.mp3")

const loops = {
	"Combat": [
		preload("res://Assets/Music/Loops/Combat/1.mp3"),
		preload("res://Assets/Music/Loops/Combat/2.mp3"),
		preload("res://Assets/Music/Loops/Combat/3.mp3")
	],
	"Dramatic": [
		preload("res://Assets/Music/Loops/Dramatic/1.mp3"),
		preload("res://Assets/Music/Loops/Dramatic/2.mp3"),
		preload("res://Assets/Music/Loops/Dramatic/3.mp3"),
	],
	"Driving": [
		preload("res://Assets/Music/Loops/Driving/1.mp3"),
		preload("res://Assets/Music/Loops/Driving/2.mp3"),
	],
	"Metal": [
		preload("res://Assets/Music/Loops/Metal/1.mp3"),
		preload("res://Assets/Music/Loops/Metal/2.mp3")
	],
	"Orchestral": [
		preload("res://Assets/Music/Loops/Orchestral/1.mp3"),
		preload("res://Assets/Music/Loops/Orchestral/2.mp3")
	],
	"Powerful": [
		preload("res://Assets/Music/Loops/Powerful/1.mp3"),
		preload("res://Assets/Music/Loops/Powerful/2.mp3")
	],
	"Rock": [
		preload("res://Assets/Music/Loops/Rock/1.mp3"),
		preload("res://Assets/Music/Loops/Rock/2.mp3")
	],
	"Triumphant": [
		preload("res://Assets/Music/Loops/Triumphant/1.mp3"),
		preload("res://Assets/Music/Loops/Triumphant/2.mp3"),
		preload("res://Assets/Music/Loops/Triumphant/3.mp3")
	]
}

func set_volume(volume):
	$AudioStreamPlayer.volume_db = volume

func play_menu():
	$AudioStreamPlayer.stream = menu_music
	$AudioStreamPlayer.play()

func play_style(style) -> String:
	randomize()
	if ! style in loops.keys():
		style = loops.keys()[randi() % len(loops)]
	
	var track = loops[style][randi() % len(loops[style])]
	$AudioStreamPlayer.stream = track
	$AudioStreamPlayer.play()
	
	return style
	