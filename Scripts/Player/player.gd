extends CharacterBody3D

const WALK_SPEED = 3.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8
const DIRECTION_LERP_FACTOR = 15.0  # Adjust the factor to control smoothness
const ROTATION_LERP_FACTOR = 0.1  # Adjust the factor for desired rotation smoothness

var current_direction = Vector3.ZERO

@onready var animation_player = $Visuals/player/AnimationPlayer
@onready var visuals = $Visuals
@onready var camera = $SubViewportContainer/SubViewport/Camera_rig

var current_state = "idle"

func _ready():
	pass

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump()
	handle_input(delta)
	update_movement(delta)
	update_rotation(delta)
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0

func handle_jump():
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		set_animation("Jump")

func handle_input(delta):
	var forward = camera.global_transform.basis.z.normalized()
	var right = camera.global_transform.basis.x.normalized()
	var input_vec = Vector3.ZERO
	input_vec -= forward if Input.is_action_pressed("w") else Vector3.ZERO
	input_vec += forward if Input.is_action_pressed("s") else Vector3.ZERO
	input_vec -= right if Input.is_action_pressed("a") else Vector3.ZERO
	input_vec += right if Input.is_action_pressed("d") else Vector3.ZERO
	var direction = input_vec.normalized()
	current_direction = current_direction.lerp(direction, delta * DIRECTION_LERP_FACTOR)

func update_movement(delta):
	var current_speed = RUN_SPEED if Input.is_action_pressed("shift") else WALK_SPEED
	if current_direction.length() > 0.01:
		velocity.x = current_direction.x * current_speed
		velocity.z = current_direction.z * current_speed
		set_animation("Run" if current_speed == RUN_SPEED else "Walk")
	else:
		velocity.x = 0
		velocity.z = 0
		set_animation("Idle")

func update_rotation(delta):
	if current_direction.length() > 0.01:
		var target_rotation = atan2(-current_direction.x, -current_direction.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_rotation, ROTATION_LERP_FACTOR)

func set_animation(name):
	if current_state != name:
		current_state = name
		animation_player.play(name)
