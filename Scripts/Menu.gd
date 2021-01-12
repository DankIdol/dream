extends Node2D

var icons = {
	"play": preload("res://Assets/UI_Icons/play_icon.png"),
	"leaderboard": preload("res://Assets/UI_Icons/leaderboard_icon.png"),
	"credits": preload("res://Assets/UI_Icons/about_icon.png"),
	"exit": preload("res://Assets/UI_Icons/exit_icon.png")
}
var loader
var dims: Vector2

func _ready():
	dims = get_viewport().size
	$TextureRect.margin_right = dims.x
	$TextureRect.margin_bottom = dims.y
	
	$ProgressBar.margin_left = (dims.x / 2) - 50
	$ProgressBar.margin_right += (dims.x / 2) - 50
	$ProgressBar.margin_top = (dims.y / 2) - 10
	$ProgressBar.margin_bottom += (dims.y / 2) - 10
	
	$ScoreBoard.position.x = dims.x - 500 - 20
	$ScoreBoard.position.y = dims.y - 500 - 20

func _process(delta):
	if loader != null:
		var err = loader.poll()
		if err == OK:
			$ProgressBar.value += 1
		elif err == ERR_FILE_EOF:
			var root = get_node("/root")
			var level = root.get_node("Menu")
			var scene = loader.get_resource()
			get_node("/root").add_child(scene.instance())
			root.remove_child(level)
			level.call_deferred("free")

func _on_Play_mouse_entered():
	$VBoxContainer/Play.icon = icons["play"]
func _on_Play_mouse_exited():
	$VBoxContainer/Play.icon = null
func _on_Play_pressed():
	$ScoreBoard.visible = false
	$VBoxContainer.visible = false
	$ProgressBar.visible = true
	loader = ResourceLoader.load_interactive("res://Scenes/Game.tscn")

func _on_Leaderboard_mouse_entered():
	$VBoxContainer/Leaderboard.icon = icons["leaderboard"]
func _on_Leaderboard_mouse_exited():
	$VBoxContainer/Leaderboard.icon = null
func _on_Leaderboard_pressed():
	$ScoreBoard.visible = ! $ScoreBoard.visible

func _on_Credits_mouse_entered():
	$VBoxContainer/Credits.icon = icons["credits"]
func _on_Credits_mouse_exited():
	$VBoxContainer/Credits.icon = null
func _on_Credits_pressed():
	pass

func _on_Exit_mouse_entered():
	$VBoxContainer/Exit.icon = icons["exit"]
func _on_Exit_mouse_exited():
	$VBoxContainer/Exit.icon = null
func _on_Exit_pressed():
	get_tree().quit()
