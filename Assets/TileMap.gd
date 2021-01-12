extends TileMap

const dim = Vector2(1024/16, 600/16)
var noise = OpenSimplexNoise.new()

func _ready():
	randomize()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 10.0
	noise.persistence = 0.2
	
	for x in dim.x:
		for y in dim.y:
			var value = noise.get_noise_2d(x, y)
			if value < 0.2:
				self.set_cell(x, y, 1)
	self.update_bitmask_region(Vector2(0, 0), dim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
