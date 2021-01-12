extends Spatial

var camera: Camera

func swap():
	Engine.time_scale = 1

func shoot(type: String):
	if type == "hold":
		Engine.time_scale = 0.1
		$Particles.process_material.gravity.y = 10
		
	if type == "release":
		Engine.time_scale = 1
		$Particles.process_material.gravity.y = -10
