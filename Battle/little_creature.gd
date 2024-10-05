extends RigidBody2D

@export var torque_gain_proportional = 10000.0
@export var torque_gain_derivative = 100.0
@export var max_speed = 20.0
@export var force_magnitude = 7000.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta):
	var is_grounded = false
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("ground"):
			# The contact normal is pointing upwards (assuming y-down coordinate system)
			is_grounded = true
			break

	if is_grounded:
		if linear_velocity.x < max_speed:
			# Create a force vector pointing to the right
			var force = Vector2(1, 0) * force_magnitude
			# Apply the force to the center of mass
			#add_constant_central_force(force)
			apply_central_force(force)
	else:
		pass
		
	 #Get global up rotation
	var current_rotation = global_rotation
	var angle_difference = normalize_angle((2*PI) - global_rotation)
	
	# Calculate the angular velocity difference (aiming for zero angular velocity)
	var angular_velocity_difference = -angular_velocity
	
	# Calculate the torque to apply
	var torque = (angle_difference * torque_gain_proportional) + (angular_velocity_difference * torque_gain_derivative)
	#print(torque)
	
	# Apply the torque
	apply_torque(torque)
		
func normalize_angle(angle):
	return fmod(angle + PI, 2 * PI) - PI
