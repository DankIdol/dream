extends KinematicBody

export var gravity = Vector3.ZERO
export var speed = .5
export var target: Vector3
var velocity := Vector3.ZERO
var health := 1000

func _ready():
	$AnimationPlayer.play("ArmatureAction")

func _physics_process(delta):
	var vision_point = target
	vision_point.y = 0
	look_at(target, Vector3.UP)
	self.rotation_degrees.x = 0
	
	velocity += gravity * delta
	get_input(delta)
	velocity.y = 0
	velocity = move_and_slide(velocity, Vector3.UP)

func get_input(delta):
	var vy = velocity.y
	velocity = (target - self.global_transform.origin).normalized() * speed
	velocity.y = vy

func damage(dmg: int):
	health -= dmg
	print(health)
	if health <= 0:
		$HitArea/CollisionShape.disabled = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Die")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Die":
		queue_free()



