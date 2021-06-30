extends Spatial

onready var aimcast = $RayCast
var bullet = preload("res://Scenes/Bullet.tscn")
var can_shoot := true
var camera: Camera

func _ready():
	pass # Replace with function body.

func swap():
	pass

func shoot(type: String):
	if can_shoot && type == "hold":
		var b = bullet.instance()
		add_child(b)
		b.origin = global_transform.origin
		b.look_at($target.global_transform.origin, Vector3.UP)
		b.active = true
		can_shoot = false
		$Timer.start()
		$AudioStreamPlayer3D.play()

func _on_Timer_timeout():
	can_shoot = true
