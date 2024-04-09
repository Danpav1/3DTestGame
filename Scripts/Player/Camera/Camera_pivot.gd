extends Node3D

@export var player: CharacterBody3D

# Offsets
var position_offset: Vector3 = Vector3(0, 1, 0)  # The camera is 1 unit above the player
var follow_speed: float = 5.0

func _ready() -> void:
	if not player:
		print("Player node not set or found. Please assign the Player node to the camera rig script.")
		set_physics_process(false)  # Disable _process until the player is set to avoid errors

func _process(delta: float) -> void:
	# Follow the player with an offset
	if player:
		# Calculate the camera global position based on the player's position and the offsets
		var rotated_offset: Vector3 = player.global_transform.basis * position_offset
		var target_position: Vector3 = player.global_transform.origin + rotated_offset

		# Lerp the camera's position for smooth following
		global_transform.origin = global_transform.origin.lerp(target_position, follow_speed * delta)
