extends Node3D

var mouse_sensitivity: float = 0.065  # Sensitivity of the mouse movement
var is_rotating: bool = false  # Flag to track if currently rotating
var snap_target_angle: float = 0.0  # Target angle for snapping
var snap_speed: float = 5.0  # Speed of snapping rotation

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_rotating:
		# Update rotation based on mouse movement
		rotation_degrees.y += event.relative.x * mouse_sensitivity
		# Update snap target angle to current angle to avoid snapping while rotating
		snap_target_angle = rotation_degrees.y

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_rotating = true  # Start rotating
			else:
				is_rotating = false  # Stop rotating
				# Set snap target to the nearest 45 degree increment
				snap_target_angle = round(rotation_degrees.y / 45.0) * 45.0

func _process(delta: float) -> void:
	if not is_rotating:
		# Smoothly interpolate towards the snap target angle when not rotating
		rotation_degrees.y = lerp_angle(deg_to_rad(rotation_degrees.y), deg_to_rad(snap_target_angle), snap_speed * delta)
		rotation_degrees.y = rad_to_deg(rotation_degrees.y)
