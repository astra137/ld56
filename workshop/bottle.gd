extends RigidBody2D
class_name Bottle

const FURBLE = preload('res://battle_screen/little_creature.tscn')

@export var type := Furble.CreatureTypes.FIRE

var should_shatter := false
var _shattering := false
var _mouse_motion: InputEventMouseMotion = null
var _previous_position := global_position
var _previous_velocity := linear_velocity
var _is_dragging := false


func drain_mouse_motion() -> Vector2:
	var rel := _mouse_motion.relative
	_mouse_motion = null
	return rel


func shatter() -> void:
	if _shattering: return
	_shattering = true
	_shatter.call_deferred()


func _shatter() -> void:
	for body in get_furbles():
		body.reparent(get_tree().root)

	var cork_sprite := $Cork
	var cork: RigidBody2D = load('res://workshop/cork.tscn').instantiate()
	get_tree().root.add_child(cork)
	cork.global_position = cork_sprite.global_position
	cork.linear_velocity = Vector2.UP.rotated(randf_range(-PI/2., PI/2.)) * 480.0
	cork.angular_velocity = TAU

	for node in BottleShard.spawn_shards():
		get_tree().root.add_child(node)
		node.global_position = global_position
		node.linear_velocity = Vector2.UP.rotated(randf_range(-PI/2., PI/2.)) * 480.0
		node.angular_velocity = TAU

	queue_free()


func get_furbles() -> Array[Furble]:
	var list: Array[Furble] = []
	list.assign(%Creatures.get_children())
	return list


func has_furble(body: Furble) -> bool:
	if is_queued_for_deletion(): return false
	return %Creatures == body.get_parent()


func _ready() -> void:
	#body_entered.connect(_body_entered)
	for idx in 10:
		var body: Furble = FURBLE.instantiate()
		body.type = type
		body.state = Furble.MovementStates.BOTTLED
		%Creatures.add_child(body)


func _process(delta: float) -> void:
	if should_shatter:
		should_shatter = false
		shatter()
	if _is_dragging:
		global_position = get_global_mouse_position()
		linear_velocity = drain_mouse_motion() / delta if _mouse_motion else Vector2.ZERO
		sleeping = false


func _unhandled_input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseMotion:
			if not _mouse_motion:
				_mouse_motion = event
			else:
				_mouse_motion.accumulate(event)


func _input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseButton:
			_is_dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var delta_velocity := state.linear_velocity - _previous_velocity
	if delta_velocity.length() > 480.0:
		var valid_hits: Array[PhysicsBody2D] = []
		for idx in state.get_contact_count():
			var body = state.get_contact_collider_object(idx)
			if body is PhysicsBody2D:
				if body.collision_layer & collision_mask:
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
			_is_dragging = event.is_pressed()
			viewport.set_input_as_handled()


func _on_container_body_exited(body: Node2D) -> void:
	if body is Furble and has_furble(body):
		body.linear_velocity = Vector2.ZERO
		body.global_position = global_position
		#body.teleport(global_position - body.global_position)
