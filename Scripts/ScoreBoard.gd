extends Node2D

const URL = "https://nightmare-score-server.herokuapp.com"
const ALL = "/all"
const globals = preload("res://Scripts/Globals.gd")
const data = {
	"name": "not_loaded"
}

func _ready():
	var save = File.new()
	save.open_encrypted_with_pass(globals.SAVEFILE, File.READ, globals.PASSWORD)
	data["name"] = save.get_as_text().strip_edges().strip_escapes()
	save.close()
	_make_post_request(URL + ALL, data, false)

func _make_post_request(url, data_to_send, use_ssl):
	var query = JSON.print(data_to_send)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result

	$Background/LoadingContainer.visible = false
	$Background/RecordsContainer.visible = true
	
	var index = 0
	var container = $Background/RecordsContainer/VBoxContainer
	for r in container.get_children():
		if "Record" in r.name && index + 1 < len(json["top"]):
			r.get_child(0).text =\
				str(index + 1) + ". " + json["top"][index]["name"] + " - "
			r.get_child(1).text = str(json["top"][index]["score"])
			index += 1

	$Background/RecordsContainer/VBoxContainer/You/Name.text = \
		json["you"]["row_number"] + ". " + json["you"]["name"] + " - "
	$Background/RecordsContainer/VBoxContainer/You/Score.text = \
		str(json["you"]["score"])
		
