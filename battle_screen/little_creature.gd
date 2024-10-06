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

var jumped = false

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
	torque_gain_proportional *= (configuration.gravity_multiplier * configuration.weight_multiplier)


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

func _on_sprite_animation_looped() -> void:
	#if %Sprite.animation == "Jump":
		#%Sprite.play("default")
	pass
