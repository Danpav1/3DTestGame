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
<<<<<<< HEAD
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta	

	# Use the camera's global transform to determine the forward and right vectors.
	var forward = -camera.global_transform.basis.z.normalized()
	var right = camera.global_transform.basis.x.normalized()
	
	# Get the input vector based on camera orientation.
	var input_vec = Vector3.ZERO
	input_vec += forward if Input.is_action_pressed("s") else Vector3.ZERO
	input_vec -= forward if Input.is_action_pressed("w") else Vector3.ZERO
	input_vec -= right if Input.is_action_pressed("d") else Vector3.ZERO
	input_vec += right if Input.is_action_pressed("a") else Vector3.ZERO
	var direction = input_vec.normalized()

	# Determine current speed based on whether the player is walking or running.
	var current_speed = WALK_SPEED if !Input.is_action_pressed("shift") else RUN_SPEED

	# Update animation and walking/running flags.
	if direction != Vector3.ZERO:
		if !running and current_speed == RUN_SPEED:
			running = true
			walking = false
			animation_player.play("Run")
		elif !walking and current_speed == WALK_SPEED:
			walking = true
			running = false
			animation_player.play("Walk")
	else:
		if walking or running:
			walking = false
			running = false
			animation_player.play("Idle")

	# Apply movement
	if direction != Vector3.ZERO:
		# Convert the global direction to the character's local space using direct multiplication
		var local_direction = global_transform.basis.inverse() * direction
		velocity.x = local_direction.x * current_speed
		velocity.z = local_direction.z * current_speed

		# Calculate the new forward direction for $Visuals, ignoring the vertical component
		var new_forward = Vector3(local_direction.x, 0, local_direction.z).normalized()
		
		# Only update the visuals' rotation if there is significant horizontal movement
		if new_forward.length() > 0.01:
			# Adjust the angle calculation by adding 180 degrees to flip the direction
			visuals.rotation_degrees.y = rad_to_deg(atan2(-new_forward.x, -new_forward.z))

	else:
		# Decelerate to a stop if no input is provided.
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Perform the movement.
=======
	handle_gravity(delta)
	handle_jump()
	handle_input(delta)
	update_movement(delta)
	update_rotation(delta)
>>>>>>> 2652451f6071b4515e0d156ce1b377cb6389a981
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
