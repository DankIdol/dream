extends RigidBody

signal explosion

const GRAVITY := -10
const DMG := 200

var exploded = false

func _ready():
	set_as_toplevel(true)
	$Timer.start()

func _process(delta):
	visible = true
	if !exploded:
		$OmniLight.light_energy += .1
	if $Particles.emitting == false && exploded:
		call_deferred("queue_free")

func _on_Timer_timeout():
	emit_signal("explosion")
	exploded = true
	mode = RigidBody.MODE_RIGID
	$MeshInstance.visible = false
	$Particles.emitting = true
	for e in $Area.get_overlapping_areas():
		if e.is_in_group("enemy") and ! e.is_in_group("non_targetable"):
			e.get_parent().damage(DMG)
