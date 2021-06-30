extends Spatial

const PELLET_COUNT := 10
const ACCURACY := .2

onready var aimcast = $RayCast

var pellet = preload("res://Scenes/Pellet.tscn")
var can_shoot := true
var camera: Camera

func _ready():
	randomize()

func swap():
	pass

func shoot(_type: String):
	if can_shoot:
		var random_vector = Vector3(1, 0, 0)
		random_vector.x *= rand_range(-ACCURACY, ACCURACY)
		var target = $target.global_transform.origin + random_vector
		
		for i in PELLET_COUNT:
			var b = pellet.instance()
			add_child(b)
			b.global_transform.origin += Vector3(1, 0, 0) * rand_range(-ACCURACY, ACCURACY)
			b.origin = global_transform.origin
			b.look_at(target, Vector3.UP)
			b.active = true
		
		camera.shake(.25, 40, .2)
		
		can_shoot = false
		$Timer.start()
		$AudioStreamPlayer3D.play()

func _on_Timer_timeout():
	can_shoot = true
