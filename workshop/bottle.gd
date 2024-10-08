extends RigidBody2D
class_name Bottle

const FURBLE = preload('res://battle_screen/little_creature.tscn')
const BOTTLE_SHATTER = preload('res://workshop/shatter/bottle_shatter.tscn')


@export var type := Furble.CreatureTypes.FIRE

enum BottleStates {
	RESTING,
	DRAGGING,
	FALLING,
	SHATTERING
}

var state := BottleStates.RESTING

var should_shatter := false
var _mouse_motion: InputEventMouseMotion = null
var _previous_position := global_position
var _previous_velocity := linear_velocity

# reset bottles
var initial_position := Vector2.ZERO
const resting_movement_limit := 30.0


func drain_mouse_motion() -> Vector2:
	var rel := _mouse_motion.relative
	_mouse_motion = null
	return rel


func get_furbles() -> Array[Furble]:
	var list: Array[Furble] = []
	list.assign(%Creatures.get_children())
	return list


func has_furble(body: Furble) -> bool:
	return %Creatures == body.get_parent()


func _ready() -> void:
	#body_entered.connect(_body_entered)
	add_collision_exception_with($Inside)
	for idx in 10:
		var body: Furble = FURBLE.instantiate()
		body.type = type
		body.bottle = self
		%Creatures.add_child(body)
		add_collision_exception_with(body)
	initial_position = global_position


func _process(delta: float) -> void:
	# state transitions
	match state:
		BottleStates.DRAGGING:
			if should_shatter:
				shatter()

	# tick state functions
	match state:
		BottleStates.DRAGGING:
			dragging_tick(delta)
		BottleStates.RESTING:
			resting_tick()


# State transition functions
func shatter() -> void:
	state = BottleStates.SHATTERING
	_shatter.call_deferred()


func _shatter() -> void:
	for body in get_furbles():
		body.bottle = null
		body.reparent(get_tree().root)
	var node: Node2D = BOTTLE_SHATTER.instantiate()
	get_tree().root.add_child(node)
	node.global_position = global_position
	queue_free()


func falling() -> void:
	state = BottleStates.FALLING

func dragging() -> void:
	%PickupSound.play()
	state = BottleStates.DRAGGING

func screen_switch() -> void:
	if state == BottleStates.DRAGGING:
		shatter()

# tick events
func dragging_tick(delta: float) -> void:
	global_position = get_global_mouse_position()
	linear_velocity = drain_mouse_motion() / delta if _mouse_motion else Vector2.ZERO
	sleeping = false

func resting_tick() -> void:
	if global_position.distance_to(initial_position) >= resting_movement_limit:
		shatter()

func _unhandled_input(event: InputEvent) -> void:
	if state == BottleStates.DRAGGING:
		if event is InputEventMouseMotion:
			if not _mouse_motion:
				_mouse_motion = event
			else:
				_mouse_motion.accumulate(event)


func _input(event: InputEvent) -> void:
	if state == BottleStates.DRAGGING:
		if event is InputEventMouseButton:
			if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				falling()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var delta_velocity := state.linear_velocity - _previous_velocity
	if delta_velocity.length() > 480.0:
		var valid_hits: Array[PhysicsBody2D] = []
		for idx in state.get_contact_count():
			var body = state.get_contact_collider_object(idx)
			if body is PhysicsBody2D:
				if body.collision_layer & collision_mask:
					# exclude bottles or shelf
					if !body.get_collision_layer_value(2) and !body.get_collision_layer_value(7):
						valid_hits.push_back(body)
		if not valid_hits.is_empty():
			shatter()
			for body in valid_hits:
				if body.has_method('shatter'):
					body.shatter()
	_previous_velocity = state.linear_velocity


func _on_clickable_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			match state:
				BottleStates.FALLING:
					if event.is_pressed():
						dragging()
						viewport.set_input_as_handled()
				BottleStates.RESTING:
					if event.is_pressed():
						dragging()
						viewport.set_input_as_handled()
				BottleStates.DRAGGING:
					if !event.is_pressed():
						falling()
						viewport.set_input_as_handled()


func _on_container_body_exited(body: Node2D) -> void:
	if body is Furble and not is_queued_for_deletion() and has_furble(body):
		body.linear_velocity = Vector2.ZERO
		body.global_position = global_position
