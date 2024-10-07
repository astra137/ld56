extends RigidBody2D

class_name Furble

@export var torque_gain_proportional := 6000.0
@export var torque_gain_derivative := 900.0
@export var max_speed := 20.0
@export var force_magnitude := 10000.0
@export var jump_impulse := Vector2(300.0, -600.0)
@export var jump_probability := 0.001
@export var chirp_probability := 0.005
@export var lifetime_min := 50.0
@export var lifetime_max := 70.0

@export var type := CreatureTypes.FIRE:
	set(value):
		type = value
		if is_node_ready():
			update_type()


var state := MovementStates.FALLING

# Death variables
var current_lifetime := 0.0
const death_particles := preload("res://battle_screen/little_creature/death_smoke.tscn")

# Object sticking variables
var stuck_object: Obstacle
const stuck_force := 100.0
const unstuck_breaking_speed := -250.0
const stuck_max_time := 5.0
var stuck_current_time := 0.0

# Knock down variables
var knock_down_target: Obstacle
const knock_down_force := 800.0
const knock_down_max_time := 5.0
var knock_down_current_time := 0.0

# Crack variables
var crack_target: Obstacle
const knock_back_impulse := Vector2(-2000.0, -2000.0)
const knockback_time := 0.5
var knockback_current_time := 0.0

enum MovementStates {
	BOTTLED,
	FALLING,
	WALK,
	PREPARING_JUMP,
	JUMPING,
	PILED,
	STUCK,
	KNOCK_DOWN,
	CRACK,
	CRACK_JUMP,
	DEATH
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
	current_lifetime = randf_range(lifetime_min, lifetime_max)
	%Sprite.play("default")


func update_type() -> void:
	var configuration: CreatureTypeAttribute = CreatureConfiguration.type_configuration[type]
	%Sprite.modulate = configuration.color
	mass *= configuration.weight_multiplier
	max_speed *= configuration.speed_multiplier
	gravity_scale *= configuration.gravity_multiplier
	torque_gain_proportional *= ((configuration.gravity_multiplier) * (configuration.weight_multiplier))
	torque_gain_derivative*= ((configuration.gravity_multiplier) * (configuration.weight_multiplier))
	force_magnitude *= ((configuration.gravity_multiplier) * (configuration.weight_multiplier)) * configuration.speed_multiplier
	jump_impulse *= ((configuration.gravity_multiplier) * (configuration.weight_multiplier))

	match type:
		CreatureTypes.WATER:
			set_collision_mask_value(5, false)
			set_collision_layer_value(3, false)
			set_collision_layer_value(6, true)


func _physics_process(delta):
	var bodies = get_colliding_bodies()
	var is_grounded = false

	for body in bodies:
		if body.is_in_group("ground"):
			is_grounded = true

	var should_jump := randf() <= jump_probability

	if current_lifetime <= 0.0 and state != MovementStates.DEATH:
		death()

	# State transitions
	match state:
		MovementStates.FALLING:
			if is_grounded:
				%LandingSounds.play()
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
		MovementStates.CRACK:
			if %Sprite.frame == 5:
				crack_jump()
		MovementStates.CRACK_JUMP:
			if knockback_current_time <= 0:
				if is_instance_valid(crack_target):
					crack_target.try_crack()
				apply_central_impulse(knock_back_impulse)
				falling()
		MovementStates.PILED:
			if bodies.is_empty():
				falling()
			elif should_jump:
				preparing_jump()
			elif is_grounded:
				walk()
		MovementStates.STUCK:
			if stuck_object == null:
				falling()
			elif stuck_object.linear_velocity.y <= unstuck_breaking_speed or stuck_current_time >= stuck_max_time:
				stuck_object = null
				falling()


	if state != MovementStates.BOTTLED:
		rotate_upright()

		current_lifetime -= delta

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
		MovementStates.STUCK:
			stuck_tick(delta)
		MovementStates.KNOCK_DOWN:
			knock_down_tick()
		MovementStates.CRACK_JUMP:
			crack_jump_tick(delta)


# State transition functions
func piled():
	%Sprite.play("default")
	state = MovementStates.PILED

func falling():
	%Sprite.play("falling")
	state = MovementStates.FALLING

func walk():
	chirp()
	%Sprite.play("walk")
	state = MovementStates.WALK

func preparing_jump():
	%Sprite.play("jump")
	state = MovementStates.PREPARING_JUMP

func jump():
	apply_central_impulse(jump_impulse)
	%JumpSounds.play()

	state = MovementStates.JUMPING

func crack_jump():
	knockback_current_time = knockback_time
	apply_central_impulse(jump_impulse)
	%JumpSounds.play()

	state = MovementStates.CRACK_JUMP

func stuck(body: Obstacle):
	stuck_current_time = 0.0
	stuck_object = body
	state = MovementStates.STUCK

func knock_down(object: Obstacle):
	knock_down_target = object
	state = MovementStates.KNOCK_DOWN

func crack(object: Obstacle):
	crack_target = object
	%Sprite.play("jump")
	state = MovementStates.CRACK

func death():
	%Sprite.play("death")
	state = MovementStates.DEATH
	await %Sprite.animation_looped
	%Sprite.play("squish")
	await get_tree().create_timer(1.0).timeout

	var instance = death_particles.instantiate()
	get_tree().get_root().add_child(instance)
	instance.global_position = global_position
	instance.emitting = true

	%DeathSound.play()
	await %DeathSound.finished

	queue_free()

# State tick functions
func piled_tick():
	chirp()
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

func stuck_tick(delta: float):
	chirp()
	apply_central_force(global_position.direction_to(stuck_object.global_position) * stuck_force)
	stuck_object.apply_central_force(stuck_object.wind_furble_impulse)
	stuck_current_time += delta

func knock_down_tick():
	chirp()
	knock_down_target.apply_force(Vector2.RIGHT * -knock_down_force, global_position)
	walk_tick()

func crack_jump_tick(delta: float):
	knockback_current_time -= delta

func chirp():
	if randf() <= chirp_probability:
		%ChirpSounds.play()

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
			CreatureTypes.WIND:
				if state != MovementStates.STUCK:
					if (body as Obstacle).can_stick:
						stuck(body as Obstacle)
			CreatureTypes.WATER:
				if (body as Obstacle).can_wash_away:
					knock_down(body as Obstacle)
			CreatureTypes.EARTH:
				if (body as Obstacle).can_crack:
					if state != MovementStates.CRACK and state != MovementStates.CRACK_JUMP:
						crack(body as Obstacle)



func _on_area_obstacle_exited(body: Node2D) -> void:
	if !is_queued_for_deletion():
		if body is Obstacle:
			match type:
				CreatureTypes.FIRE:
					(body as Obstacle).try_stop_burn()
				CreatureTypes.WATER:
					if state == MovementStates.KNOCK_DOWN:
						falling()
