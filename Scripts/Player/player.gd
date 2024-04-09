extends CharacterBody3D

const WALK_SPEED = 3.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5

var gravity = 9.8
var current_direction = Vector3.ZERO  # Initial direction is zero


@onready var animation_player = $Visuals/player/AnimationPlayer
@onready var visuals = $Visuals
@onready var camera = $SubViewportContainer/SubViewport/Camera_rig

var walking = false
var running = false

func _ready():
	pass

func _physics_process(delta):
	# Gravity application
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0  # Reset Y velocity when on the floor

	# Jump handling
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("Jump")

	# Determine the input direction based on camera orientation and player input
	var forward = camera.global_transform.basis.z.normalized()
	var right = camera.global_transform.basis.x.normalized()
	var input_vec = Vector3.ZERO
	input_vec -= forward if Input.is_action_pressed("w") else Vector3.ZERO  # Forward
	input_vec += forward if Input.is_action_pressed("s") else Vector3.ZERO  # Backward
	input_vec -= right if Input.is_action_pressed("a") else Vector3.ZERO  # Left
	input_vec += right if Input.is_action_pressed("d") else Vector3.ZERO  # Right
	var direction = input_vec.normalized()

	# Smoothly interpolate current_direction towards the new input direction
	current_direction = current_direction.lerp(direction, delta * 10)  # Adjust the factor to control smoothness

	# Movement speed determination
	var current_speed = RUN_SPEED if Input.is_action_pressed("shift") else WALK_SPEED

	# Movement and animation
	if current_direction.length() > 0.01:
		velocity.x = current_direction.x * current_speed
		velocity.z = current_direction.z * current_speed

		# Update walking/running status and animations
		if not running and current_speed == RUN_SPEED:
			running = true
			walking = false
			animation_player.play("Run")
		elif not walking and current_speed == WALK_SPEED:
			walking = true
			running = false
			animation_player.play("Walk")
	else:
		velocity.x = 0
		velocity.z = 0
		if walking or running:
			walking = false
			running = false
			animation_player.play("Idle")

	# Rotation towards movement direction
	if current_direction.length() > 0.01:
		var target_rotation = atan2(-current_direction.x, -current_direction.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_rotation, 0.1)  # Adjust the factor for desired rotation smoothness

	# Apply movement with move_and_slide
	move_and_slide()
