extends Node3D

@export var player: CharacterBody3D

# Offsets
var position_offset: Vector3 = Vector3(0, 1, 0)  # The camera is 1 unit above the player

var mouse_sensitivity: float = 0.5
var is_rotating: bool = false
var snap_target_angle: float = 180.0  # Initialize to the desired starting angle
var snap_speed: float = 5.0
var follow_speed: float = 5.0
var rotation_threshold: float = 1.0  # Threshold to prevent minor rotations

func _ready() -> void:
	if not player:
		print("Player node not set or found. Please assign the Player node to the camera rig script.")
		set_physics_process(false)  # Disable _process until the player is set to avoid errors
	else:
		# Ensure the player faces the correct direction at start
		player.rotation_degrees.y = snap_target_angle

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_rotating:
		# Update rotation based on mouse movement
		player.rotation_degrees.y += event.relative.x * mouse_sensitivity
		# Update snap target angle to current angle to avoid snapping while rotating
		snap_target_angle = player.rotation_degrees.y

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_rotating = true  # Start rotating
			else:
				is_rotating = false  # Stop rotating
				# Set snap target to the nearest 45 degree increment
				snap_target_angle = round(player.rotation_degrees.y / 45.0) * 45.0

func _process(delta: float) -> void:
	if not is_rotating and player:
		var angle_difference = abs(player.rotation_degrees.y - snap_target_angle)
		if angle_difference > rotation_threshold:
			# Smoothly interpolate towards the snap target angle when not rotating
			player.rotation_degrees.y = lerp_angle(deg_to_rad(player.rotation_degrees.y), deg_to_rad(snap_target_angle), snap_speed * delta)
			player.rotation_degrees.y = rad_to_deg(player.rotation_degrees.y)
		
	# Follow the player with an offset
	if player:
		# Calculate the camera global position based on the player's position and the offsets
		var rotated_offset: Vector3 = player.global_transform.basis * position_offset
		var target_position: Vector3 = player.global_transform.origin + rotated_offset

		# Lerp the camera's position for smooth following
		global_transform.origin = global_transform.origin.lerp(target_position, follow_speed * delta)
