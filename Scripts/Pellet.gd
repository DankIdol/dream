extends RigidBody

const DMG := 5
const SPEED := 20
const RANGE := 50

var origin: Vector3
var active := false

func _ready():
	set_as_toplevel(true)

func _process(delta):
	if origin.distance_to(global_transform.origin) > RANGE:
		active = false
		call_deferred("queue_free")
	
	if active:
		apply_impulse(transform.basis.z, -transform.basis.z * SPEED)

func _on_Area_area_entered(area):
	if area.is_in_group("enemy") and ! area.is_in_group("non_targetable"):
		area.get_parent().damage(DMG)
		call_deferred("queue_free")
