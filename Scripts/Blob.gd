extends KinematicBody

export var gravity = Vector3.DOWN * 10
export var speed = 20
export var target: Vector3
var rush_target: Vector3
var velocity := Vector3.ZERO
var health := 100
var rushing := false

func _ready():
	$ActiveTimer.start()
	randomize()

func _physics_process(delta):
	if rushing:
		var vision_point = rush_target
		vision_point.y = 0
		look_at(target, Vector3.UP)
		
		velocity += gravity * delta
		get_input(delta)
		velocity = move_and_slide(velocity, Vector3.UP)
	else:
		# fall to ground if not rushing
		velocity += gravity * delta
		velocity = move_and_slide(velocity, Vector3.UP)

func get_input(delta):
	var vy = velocity.y
	velocity = (rush_target - self.global_transform.origin).normalized() * speed
	velocity.y = vy

func damage(dmg: int):
	health -= dmg
	if health <= 0:
		queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Die":
		queue_free()

func _on_ActiveTimer_timeout():
	rush_target = target
	rushing = true
	$RushTimer.start()

func _on_RushTimer_timeout():
	rushing = false
	$ActiveTimer.start()


