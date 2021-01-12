extends KinematicBody

export var gravity = Vector3.DOWN * 10
export var speed = 4
export var target: Vector3
var velocity := Vector3.ZERO
var health := 100

func _ready():
	randomize()
	$AnimationPlayer.play("ArmatureAction")

func _physics_process(delta):
	var vision_point = target
	vision_point.y = 0
	look_at(target, Vector3.UP)
	
	velocity += gravity * delta
	get_input(delta)
	velocity = move_and_slide(velocity, Vector3.UP)

func get_input(delta):
	var vy = velocity.y
	velocity = (target - self.global_transform.origin).normalized() * speed
	velocity.y = vy

func damage(dmg: int):
	health -= dmg
	if health <= 0:
		$HitArea/CollisionShape.disabled = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Die")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Die":
		queue_free()



