extends Spatial

# https://coolors.co/071013-a71d31-477998-f7ff58-f6c0d0

const color = Color(167/255.0, 29/255.0, 49/255.0)
const dim = Vector2(100, 51)
const height_level = 3

var DBG = false

var mesh = preload("res://Scenes/Mesh.tscn")

var tmpMesh = Mesh.new()
var vertices = PoolVector3Array()
var UVs = PoolVector2Array()
var mat = SpatialMaterial.new()
var normals = PoolVector3Array()
var height_data = {}
var noise = OpenSimplexNoise.new()
var noise_data = []


func _ready():
	var style = Globals.AUDIO.play_style("")
	$MusicInfoLabel.text = "now playing:\n" + str(style)
	
	var file = File.new()
	file.open("res://settings.json", File.READ)
	var settings = file.get_as_text()
	if not settings == "":
		settings = JSON.parse(settings).result
		DBG = settings["debug"]
	file.close()
	
	$AnimationPlayer.play("fade_in")
	
	# center the player
	$"3dCC".global_transform.origin = Vector3(dim.x / 2, 3, -dim.y / 2)
	
	ProjectSettings.set_setting("display/window/vsync/use_vsync", true)
	
	randomize()
	noise.seed = 1337
	noise.octaves = 4
	noise.period = 10.0
	noise.persistence = 0.2
	
	# generate the entire map in advance
#	noise_data.resize(dim.x * dim.y)
#	for x in dim.x:
#		for y in dim.y:
#			noise_data[(x * 10) + y] = noise.get_noise_2d(x, y)
	
	generate_map(0, 0)

#	var f = File.new()
#	f.open("res://verts.txt", File.WRITE)
#	f.store_string(str(normals))
#	print(len(normals))
#	generate_walls()
	
func _physics_process(delta):
	var player_pos = $"3dCC".global_transform.origin
	for e in $Enemies.get_children():
		if not DBG:
			e.target = player_pos
		
	if player_pos.y < -3:
		get_tree().quit()
		
	$Label.text = str(Engine.get_frames_per_second()) + " FPS\n"
	$Label.text += str(player_pos) + "\n"

func death():
	$AnimationPlayer.play_backwards("fade_in")




# ------------------------------------------------------------------
	
func generate_map(_x, _y):
	for x in dim.x:
		for y in dim.y:
			var value = noise.get_noise_2d(x + _x, y + _y)
#			var value = noise_data[(x * 10) + y]
			height_data[Vector2(x, y)] = value * height_level

	for x in dim.x - 1:
		for y in dim.y - 1:
			createQuad(x, y)

	mat.albedo_color = color

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)

	for v in vertices.size():
		st.add_color(Color(1, 0, 0))
		st.add_uv(UVs[v])
		st.add_normal(normals[v])
		st.add_vertex(vertices[v])

	st.commit(tmpMesh)
	
	var shape = ConcavePolygonShape.new()
	shape.set_faces(tmpMesh.get_faces())
	
	var mesh_instance = mesh.instance()
	mesh_instance.mesh = tmpMesh
	mesh_instance.get_collider().shape = shape
	
	mesh_instance.global_transform.origin = Vector3(_x, 0, _y)
	
	add_child(mesh_instance)
	

func createQuad(x,y):
	var vert1 # vertex positions (Vector2)
	var vert2
	var vert3
	
	var side1 # sides of each triangle (Vector3)
	var side2
	
	var normal # normal for each triangle (Vector3)
	
	# triangle 1
	vert1 = Vector3(x,height_data[Vector2(x,y)],-y)
	vert2 = Vector3(x,height_data[Vector2(x,y+1)],-y-1)
	vert3 = Vector3(x+1,height_data[Vector2(x+1,y+1)],-y-1)
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	
	UVs.push_back(Vector2(vert1.x/10, -vert1.z/10))
	UVs.push_back(Vector2(vert2.x/10, -vert2.z/10))
	UVs.push_back(Vector2(vert3.x/10, -vert3.z/10))
	
	side1 = vert2-vert1
	side2 = vert2-vert3
	normal = side1.cross(side2)
	
	for i in range(0,3):
		normals.push_back(normal)
	
	# triangle 2
	vert1 = Vector3(x,height_data[Vector2(x,y)],-y)
	vert2 = Vector3(x+1,height_data[Vector2(x+1,y+1)],-y-1)
	vert3 = Vector3(x+1,height_data[Vector2(x+1,y)],-y)
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	
	UVs.push_back(Vector2(vert1.x/10, -vert1.z/10))
	UVs.push_back(Vector2(vert2.x/10, -vert2.z/10))
	UVs.push_back(Vector2(vert3.x/10, -vert3.z/10))
	
	side1 = vert2-vert1
	side2 = vert2-vert3
	normal = side1.cross(side2)
	
	for i in range(0, 3):
		normals.push_back(normal)

func _on_MusicInfoTimer_timeout():
	$MusicInfoLabel.visible = false
