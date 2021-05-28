extends Spatial

export var player: PackedScene
var monsters = [
	preload("res://Scenes/Monsters/Spearleg.tscn"),
	preload("res://Scenes/Monsters/Ghostcloud.tscn"),
	preload("res://Scenes/Monsters/Blob.tscn"),
]

func spawn(ID):
	var m = monsters[ID].instance()
	m.set_as_toplevel(true)
	m.target = player
	add_child(m)

func _on_SpawnTimer_timeout():
	pass
	
