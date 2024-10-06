extends Obstacle

@export var wind_furble_impulse := Vector2(2000, -20000)

var knocking_over_entities := 0

func try_knock_over() -> void:
	knocking_over_entities += 1

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if knocking_over_entities > 0:
		apply_central_force(wind_furble_impulse * knocking_over_entities)
