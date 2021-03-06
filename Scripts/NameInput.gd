extends Node2D

const EXISTS = "/name"

var save_file
var cross_icon = preload("res://Assets/UI_Icons/bad_input_icon.png")
var arrow_icon = preload("res://Assets/UI_Icons/arrow_icon.png")
var data = {
	"name": ""
}

func _ready():
	save_file = File.new()
	if save_file.file_exists(Globals.SAVEFILE):
		get_tree().change_scene("res://Scenes/Menu.tscn")

func _make_post_request(url, data_to_send, use_ssl):
	var query = JSON.print(data_to_send)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result

	if json["exists"]:
		$ColorRect/HBoxContainer/Button.icon = cross_icon
	else:
		$ColorRect/HBoxContainer/Button.icon = arrow_icon
		save_file.open_encrypted_with_pass(Globals.SAVEFILE, File.WRITE, Globals.PASSWORD)
		save_file.store_line(data["name"])
		save_file.close()
		get_tree().change_scene("res://Scenes/Menu.tscn")

func _on_LineEdit_text_changed(new_text):
	data["name"] = new_text

func _on_Button_pressed():
	if data["name"] != "":
		_make_post_request(Globals.URL + EXISTS, data, false)

