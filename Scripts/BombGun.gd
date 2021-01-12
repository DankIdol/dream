extends Spatial

var can_shoot := true
var bomb = preload("res://Scenes/Bomb.tscn")
var camera: Camera

func swap():
	$BombIndicator.visible = false

func shoot(type: String):
	if can_shoot && type == "release":
		$Cooldown.start()
		can_shoot = false
		$BombIndicator.visible = false
		var b = bomb.instance()
		b.connect("explosion", self, "_on_Bomb_explosion")
		add_child(b)
	if can_shoot && type == "hold":
		$BombIndicator.visible = true

func _on_Bomb_explosion():
	camera.shake(.5, 100, .5)

func _on_Cooldown_timeout():
	can_shoot = true
