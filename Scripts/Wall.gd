tool
extends Node2D

export var width: int

func _process(delta):
	$Sprite.rotation = rand_range(0, 180)
