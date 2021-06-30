extends Spatial

var monster_node
var mesh_material

var monsters = [
	{
		"scene": preload("res://Scenes/Monsters/Spearleg.tscn"),
		"weight": 5
	},
	{
		"scene": preload("res://Scenes/Monsters/Ghostcloud.tscn"),
		"weight": 1
	},
	{
		"scene": preload("res://Scenes/Monsters/Blob.tscn"),
		"weight": 2
	}
]

var weighted_random = []

func _ready():
	randomize()
	for i in len(monsters):
		for j in monsters[i].weight:
			weighted_random.append(i)
	mesh_material = $MeshInstance.get_active_material(0)

func spawn(monster):
	if randi() % 10 < Globals.current_difficulty and Globals.current_fps >= 50:
		var m = monster.instance()
		monster_node.add_child(m)
		m.global_transform.origin = self.global_transform.origin
		$OmniLight.visible = true
		$MeshInstance.set_surface_material(0, mesh_material)
	else:
		$OmniLight.visible = false
		$MeshInstance.set_surface_material(0, null)

func _on_SpawnTimer_timeout():
	spawn(monsters[weighted_random[randi() % len(weighted_random)]].scene)
	
