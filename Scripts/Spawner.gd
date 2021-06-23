extends Spatial

var monster_node

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
	

func spawn(monster):
	var m = monster.instance()
	m.global_transform.origin = self.global_transform.origin
	monster_node.add_child(m)

func _on_SpawnTimer_timeout():
	spawn(monsters[weighted_random[randi() % len(weighted_random)]].scene)
	
