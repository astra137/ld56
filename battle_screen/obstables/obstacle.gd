extends RigidBody2D
class_name Obstacle

@export var type := ObstacleTypes.WOOD
@export var burn_health := 50.0
@export var can_stick := false
@export var wind_furble_impulse := Vector2(2000, -20000)

var fire_sound_counter := 0.0

const disappearing_smoke = preload("res://battle_screen/obstables/effects/disappearing_smoke.tscn")

var burning_entities := 0

var state := ObstacleStates.DEFAULT

enum ObstacleStates {
	DEFAULT,
	BURNING,
	BURNT,
	CRACKED,
	BARRIER
}

enum ObstacleTypes {
	WOOD,
	STONE,
	ARCANE
}

func try_burn():
	if type == ObstacleTypes.WOOD:
		burning_entities += 1

		match state:
			ObstacleStates.DEFAULT:
				burning()

func burning():
	%FireParticles.emitting = true
	%AshParticles.emitting = true
	state = ObstacleStates.BURNING

func burnt():
	%FireParticles.emitting = false
	%AshParticles.emitting = false

	var instance = disappearing_smoke.instantiate()
	get_tree().get_root().add_child(instance)
	instance.global_position = global_position
	instance.emitting = true

	state = ObstacleStates.BURNT
	queue_free()

func default():
	if !is_queued_for_deletion():
		%FireParticles.emitting = false
		%AshParticles.emitting = false
		state = ObstacleStates.DEFAULT

func try_stop_burn():
	burning_entities -= 1

	if burning_entities <= 0:
		default()

func try_crack():
	pass

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	match state:
		ObstacleStates.BURNING:
			if burn_health <= 0.0:
				burnt()

	match state:
		ObstacleStates.BURNING:
			if burn_health >= 0.0:
				burning_tick(delta)


func burning_tick(delta: float):
	burn_health -= delta * burning_entities

	fire_sound_counter += delta
	if (1.0 / %BurningSound.max_polyphony) < fire_sound_counter:
		fire_sound_counter = 0.0
		%BurningSound.play()

	%MainSprite.modulate = Color.RED.lerp(Color.WHITE, clamp((burn_health / 50.0), 0.0, 1.0))
