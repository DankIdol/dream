extends KinematicBody

enum State {IDLE, RUN, JUMP, FALL}

const JUMP_SPEED = 7
const JUMP_FRAMES = 1
const HOP_FRAMES = 3

export var mouse_y_sens = .1
export var mouse_x_sens = .1
export var move_speed = 10
export var sprint_speed = 50
export var acceleration = .5
export var gravity = -10
export var friction = 1.15
export var max_climb_angle = .6
export var angle_of_freedom = 80
export var boost_accumulation_speed = 1
export var max_boost_multiplier = 2

onready var camera = $UpperCollider/Camera
var score = 0
var can_sprint = true
var dims: Vector2
var tween = Tween.new()

var hand_sprite = 1
var hand_sprites = [
	preload("res://Assets/Hands/000.png"), # idle
	preload("res://Assets/Hands/001.png"), # cumgun
	preload("res://Assets/Hands/002.png"), # shotgun
	preload("res://Assets/Hands/003.png"), # bomb
	preload("res://Assets/Hands/004.png")  # time
]
var icons = [
	preload("res://Assets/Icons/000.png"), # cumgun
	preload("res://Assets/Icons/001.png"), # bomb
	preload("res://Assets/Icons/002.png"), # shotgun
	preload("res://Assets/Icons/003.png")  # time
]

var crosshairs = [
	preload("res://Assets/Crosshairs/crosshair_cum.png"),
	preload("res://Assets/Crosshairs/crosshair_bomb.png"),
	preload("res://Assets/Crosshairs/crosshair_shotgun.png"),
	preload("res://Assets/Crosshairs/crosshair_time.png")
]

var weapons
var window_scale: int
var active_weapon := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	weapons = $UpperCollider/Camera/Guns.get_children()
	for w in weapons: w.camera = camera
	weapons[3].visible = false
	weapons[active_weapon].visible = true
	
	dims = get_viewport().size
	var sc = dims / Vector2(1920, 1080)
	window_scale = 8 * ( (sc.x + sc.y) / 2 )
	$Crosshair.position = Vector2(dims.x / 2, dims.y / 2)
	$Hand.position.y = dims.y - ((64 * window_scale) / 2)
	$Hand.scale = Vector2(window_scale, window_scale)
	
	var hand_y = $Hand.position.y
	var hand_animation = Animation.new()
	var track_index = hand_animation.add_track(Animation.TYPE_VALUE)
	hand_animation.track_set_path(track_index, "Hand:position:y")
	hand_animation.track_insert_key(track_index, 0.0, hand_y)
	hand_animation.track_insert_key(track_index, 0.2, hand_y + 50)
	hand_animation.track_insert_key(track_index, 0.4, hand_y)
	hand_animation.length = 0.4
	hand_animation.loop = true
	$AnimationPlayer.add_animation("hand_bob", hand_animation)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Tween.connect("tween_all_completed", self, "_on_tween_all_completed")
	
	$AliveTimer.start()


func _physics_process(delta):
	#$Label.text = str(hand_sprite)
	_process_input(delta)
	_process_movement(delta)

func _process(delta):
	$ScoreLabel.text = str(score)

# Handles mouse movement
func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(event.relative.x * mouse_y_sens * -1))
		$UpperCollider/Camera.rotate_x(deg2rad(event.relative.y * mouse_x_sens * -1))
		
		var camera_rot = $UpperCollider/Camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, 90 + angle_of_freedom * -1, 90 + angle_of_freedom)
		$UpperCollider/Camera.rotation_degrees = camera_rot


var inbetween = false
func _on_tween_all_completed():
	inbetween = false
	crouch_floor = false


var state = State.FALL
var on_floor = false
var frames = 0
var crouching = false
var crouch_floor = false #true if started crouching on the floor
var input_dir = Vector3(0, 0, 0)
func _process_input(delta):
	# Toggle mouse capture
	if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Jump
#	if Input.is_action_pressed("jump") && on_floor && state != State.FALL && (frames == 0 || frames > JUMP_FRAMES + 1):
#		frames = 0
#		state = State.JUMP
	if Input.is_action_pressed("jump"):
		global_transform.origin += Vector3(0, 1, 0)
	
	if Input.is_action_just_pressed("shift") and can_sprint:
		tween.interpolate_property($UpperCollider/Camera, "fov", 70, 90, .5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
		$UpperCollider/Camera.fov = 90
		move_speed = sprint_speed
		can_sprint = false
		$SprintTimer.start()
		
	if Input.is_action_pressed("left_click"):
		$Hand.position.x = dims.x / 2
		$UpperCollider/Camera/Guns.translation.x = 1.5
		weapons[active_weapon].shoot("hold")
		$Hand.texture = hand_sprites[hand_sprite]
		$Hand/Icon.visible = false
		
		if active_weapon == 3: # time
			move_speed = 20
		
	if Input.is_action_just_released("left_click"):
		$Hand.position.x = 250
		$UpperCollider/Camera/Guns.translation.x = 0
		weapons[active_weapon].shoot("release")
		$Hand.texture = hand_sprites[0]
		$Hand/Icon.visible = true
		
		move_speed = 10
	
	if Input.is_action_just_released("scroll_up"):
		if hand_sprite < len(hand_sprites) - 1:
			hand_sprite += 1
		else:
			hand_sprite = 1
		$Hand/Icon.texture = icons[hand_sprite - 1]
		weapons[active_weapon].swap()
		active_weapon = hand_sprite - 1
		
		weapons[3].visible = false
		weapons[active_weapon].visible = true
		swap_crosshair(crosshairs[active_weapon])
			
	if Input.is_action_just_released("scroll_down"):
		if hand_sprite > 1:
			hand_sprite -= 1
		else:
			hand_sprite = len(hand_sprites) - 1
			
		$Hand/Icon.texture = icons[hand_sprite - 1]
		weapons[active_weapon].swap()
		active_weapon = hand_sprite - 1
		
		weapons[3].visible = false
		weapons[active_weapon].visible = true
		swap_crosshair(crosshairs[active_weapon])
	
	# WASD
	input_dir = Vector3(Input.get_action_strength("d") - Input.get_action_strength("a"), 
			0,
			Input.get_action_strength("s") - Input.get_action_strength("w")).normalized()


var collision : KinematicCollision  # Stores the collision from move_and_collide
var velocity := Vector3(0, 0, 0)
var rotation_buf = rotation  # used to calculate rotation delta for air strafing
var turn_boost = 1
func _process_movement(delta):
	# state management
	if !collision:
		on_floor = false
		if state != State.JUMP:
			state = State.FALL
	else:
		if state == State.JUMP:
			pass
		elif Vector3.UP.dot(collision.normal) < max_climb_angle:
			state = State.FALL
		else:
			on_floor = true
			if input_dir.length() > .1 && (frames > JUMP_FRAMES+HOP_FRAMES || frames == 0):
				state = State.RUN
				turn_boost = 1
			else:
				state = State.IDLE
	
	#jump state
	if state == State.JUMP && frames < JUMP_FRAMES:
		velocity.y = JUMP_SPEED
		frames += 1 * delta * 60
	elif state == State.JUMP:
		state = State.FALL

	#fall state
	if state == State.FALL:
		if inbetween && crouching && crouch_floor:
			velocity.y = gravity;
		if velocity.y > gravity:
			velocity.y += gravity * delta * 4
	
	#run state
	if state == State.RUN:
		velocity += input_dir.rotated(Vector3(0, 1, 0), rotation.y) * acceleration
		if Vector2(velocity.x, velocity.z).length() > (move_speed/2 if crouching else move_speed):
			velocity = velocity.normalized() * (move_speed/2 if crouching else move_speed)
		velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1)
		velocity.y -= 1 + (1+int(velocity.y < 0) * .3)
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("hand_bob")

	#idle state
	if state == State.IDLE && frames < HOP_FRAMES + JUMP_FRAMES:
		frames += 1 * delta * 60
	elif state == State.IDLE:
		turn_boost = 1
		if velocity.length() > .5:
			velocity /= friction
			velocity.y = ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * -1) - .0001
		$AnimationPlayer.stop(true)

	#air strafe
	if state > 2:
		#x axis movement
		var rotation_d = rotation - rotation_buf
		if input_dir.x > .1 && rotation_d.y < 0:
			velocity = velocity.rotated(Vector3.UP, rotation_d.y )
			turn_boost += boost_accumulation_speed * delta 
		elif input_dir.x < -.1 && rotation_d.y > 0:
			velocity = velocity.rotated(Vector3.UP, rotation_d.y ) 
			turn_boost += boost_accumulation_speed * delta 
		
		if abs(input_dir.x) < .1 && on_floor:
			#z axis movement
			var movement_vector = Vector3(0,0,input_dir.z).rotated(Vector3(0, 1, 0), rotation.y) * move_speed /2
			if movement_vector.length() < .1:
				velocity = velocity
			elif Vector2(velocity.x, velocity.z).length() < move_speed:
				var xy = Vector2(movement_vector.x , movement_vector.z).normalized()
				velocity += Vector3(xy.x, 0, xy.y) * acceleration
				
		turn_boost = clamp(turn_boost, 1, max_boost_multiplier)
		rotation_buf = rotation

	#apply
	if velocity.length() >= .5 || inbetween:
		collision = move_and_collide(velocity * Vector3(turn_boost, 1, turn_boost) * delta)
	else:
		velocity = Vector3(0, velocity.y, 0)
	if collision:
		if Vector3.UP.dot(collision.normal) < .5:
			velocity.y += delta * gravity
			clamp(velocity.y, gravity, 9999)
			velocity = velocity.slide(collision.normal).normalized() * velocity.length()
		elif turn_boost > 1.01:
			velocity = Vector3(velocity.x, velocity.y + ((Vector3(velocity.x, 0, velocity.z).dot(collision.normal)) * - 2) , velocity.z)
		else:
			velocity = velocity

func swap_crosshair(crosshair):
	$Crosshair.texture = crosshair

func _on_HitArea_area_entered(area):
	if area.is_in_group("death"):
		print("death")

func _on_HitArea_body_entered(body):
	if body.is_in_group("death"):
		print("death")

func _on_AliveTimer_timeout():
	score += .1

func _on_SprintTimer_timeout():
	move_speed = 10
	$SprintCooldownTimer.start()
	tween.interpolate_property($UpperCollider/Camera, "fov", 90, 70, .5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)

func _on_SprintCooldownTimer_timeout():
	can_sprint = true
