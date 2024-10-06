extends RigidBody2D

class_name Furble

@export var torque_gain_proportional := 6000.0
@export var torque_gain_derivative := 900.0
@export var max_speed := 20.0
@export var force_magnitude := 10000.0
@export var jump_impulse := Vector2(300.0, -600.0)
@export var jump_probability := 0.001

@export var type := CreatureTypes.FIRE:
	set(value):
		type = value
		if is_node_ready():
			update_type()


var state := MovementStates.BOTTLED

enum MovementStates {
	BOTTLED,
	FALLING,
	WALK,
	PREPARING_JUMP,
	JUMPING,
	PILED
}

enum CreatureTypes {
	FIRE,
	ICE,
	EARTH,
	ARCANE,
	WATER,
	ELECTRICITY,
	WIND,
	GRAVITY
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_type()
	%Sprite.play("default")


func update_type() -> void:
	var configuration: CreatureTypeAttribute = CreatureConfiguration.type_configuration[type]
	%Sprite.modulate = configuration.color
	mass *= configuration.weight_multiplier
	max_speed *= configuration.speed_multiplier
	gravity_scale *= configuration.gravity_multiplier
	torque_gain_proportional *= ((configuration.gravity_multiplier ** 2) * (configuration.weight_multiplier ** 2))
	torque_gain_derivative*= ((configuration.gravity_multiplier ** 2) * (configuration.weight_multiplier ** 2))
	force_magnitude *= ((configuration.gravity_multiplier ** 2) * (configuration.weight_multiplier ** 2))
	jump_impulse *= ((configuration.gravity_multiplier ** 2) * (configuration.weight_multiplier ** 2))

	match type:
		CreatureTypes.WATER:
			set_collision_mask_value(5, false)
			set_collision_layer_value(3, false)
			set_collision_layer_value(6, true)

func awaken_furble() -> void:
	state = MovementStates.FALLING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta):
	var bodies = get_colliding_bodies()
	var is_grounded = false

	for body in bodies:
		if body.is_in_group("ground"):
			is_grounded = true

	var should_jump := randf() <= jump_probability

	# State transitions
	match state:
		MovementStates.FALLING:
			if is_grounded:
				walk()
			elif !bodies.is_empty() and linear_velocity.length() <= 100.0:
				piled()
		MovementStates.WALK:
			if bodies.is_empty():
				falling()
			elif should_jump:
				preparing_jump()
			elif !is_grounded and !bodies.is_empty():
				piled()
		MovementStates.PREPARING_JUMP:
			if %Sprite.frame == 5:
				jump()
		MovementStates.JUMPING:
			if linear_velocity.y <= 0.0:
				falling()
		MovementStates.PILED:
			if bodies.is_empty():
				falling()
			elif should_jump:
				preparing_jump()
			elif is_grounded:
				walk()

	if state != MovementStates.BOTTLED:
		rotate_upright()

	match state:
		MovementStates.FALLING:
			falling_tick()
		MovementStates.WALK:
			walk_tick()
		MovementStates.PREPARING_JUMP:
			preparing_jump_tick()
		MovementStates.JUMPING:
			jump_tick()
		MovementStates.PILED:
			piled_tick()


# State transition functions
func piled():
	%Sprite.play("default")
	state = MovementStates.PILED

func falling():
	%Sprite.play("falling")
	state = MovementStates.FALLING

func walk():
	%Sprite.play("walk")
	state = MovementStates.WALK

func preparing_jump():
	%Sprite.play("jump")
	state = MovementStates.PREPARING_JUMP

func jump():
	state = MovementStates.JUMPING
	apply_central_impulse(jump_impulse)


# State tick functions
func piled_tick():
	pass

func walk_tick():
	if linear_velocity.x < max_speed:
		# Create a force vector pointing to the right
		var force = Vector2(1, 0) * force_magnitude
		# Apply the force to the center of mass
		apply_central_force(force)

func falling_tick():
	pass

func preparing_jump_tick():
	pass

func jump_tick():
	pass

func rotate_upright():
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



#region Teleport

var _teleport_pending := false
var _teleport_vector := Vector2.ZERO

func teleport(delta: Vector2) -> void:
	_teleport_pending = true
	_teleport_vector += delta

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _teleport_pending:
		state.transform.origin += _teleport_vector
		_teleport_pending = false
		_teleport_vector = Vector2.ZERO

#endregion


func _on_area_obstacle_entered(body: Node2D) -> void:
	if body is Obstacle:
		match type:
			CreatureTypes.FIRE:
				(body as Obstacle).try_burn()


func _on_area_obstacle_exited(body: Node2D) -> void:
	if body is Obstacle:
		match type:
			CreatureTypes.FIRE:
				(body as Obstacle).try_stop_burn()
