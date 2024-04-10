extends CharacterBody3D

const WALK_SPEED = 3.0
const RUN_SPEED = 5.0
const ACCEL = 5.0
const ROTATE_SPEED = 5.0  # Determines how quickly the character rotates

@onready var visuals = $Visuals
@onready var animation_player = $Visuals/player/AnimationPlayer

var input: Vector2
var direction: Vector3
var walking = false
var running = false

func get_input() -> Vector2:
	input = Vector2.ZERO
	input.x = Input.get_action_strength("a") - Input.get_action_strength("d")
	input.y = Input.get_action_strength("w") - Input.get_action_strength("s")
	return input.normalized()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	var player_input = get_input()

	if player_input.length() > 0:
		var current_speed = WALK_SPEED if !Input.is_action_pressed("shift") else RUN_SPEED

		# Convert 2D input into a 3D vector for movement
		var direction = Vector3(player_input.x, 0, player_input.y) * current_speed
		velocity.x = lerp(velocity.x, direction.x, ACCEL * delta)
		velocity.z = lerp(velocity.z, direction.z, ACCEL * delta)

		# Update animation and walking/running flags based on the movement.
		if current_speed == RUN_SPEED and !running:
			running = true
			walking = false
			animation_player.play("Run")
		elif current_speed == WALK_SPEED and !walking:
			walking = true
			running = false
			animation_player.play("Walk")

		# Rotate the character to face the moving direction
		visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(-direction.x, -direction.z), delta * ROTATE_SPEED)
	else:
		# If no input is provided, reduce the character's horizontal velocity to stop sliding.
		velocity.x = lerp(velocity.x, 0.0, ACCEL * delta)
		velocity.z = lerp(velocity.z, 0.0, ACCEL * delta)

		# Play the "Idle" animation if the character was previously moving.
		if walking or running:
			walking = false
			running = false
			animation_player.play("Idle")

	# Move the character
	move_and_slide()
