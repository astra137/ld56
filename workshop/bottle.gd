extends RigidBody2D

@export var type := Furble.CreatureTypes.FIRE

var should_shatter := false
var _shattering := false
var _mouse_motion: InputEventMouseMotion = null
var _tracking: Array[Furble] = []
var _previous_velocity := linear_velocity
var _is_dragging := false:
	set(value):
		_is_dragging = value
		#custom_integrator = value


func shatter() -> void:
	if _shattering: return
	_shattering = true
	_shatter.call_deferred()


func _shatter() -> void:
	var cork_sprite := $Cork
	var cork: RigidBody2D = load('res://workshop/cork.tscn').instantiate()
	get_tree().root.add_child(cork)
	cork.global_position = cork_sprite.global_position
	cork.linear_velocity = Vector2.UP.rotated(randf_range(-PI/2., PI/2.)) * 480.0
	cork.angular_velocity = TAU

	for body in _tracking:
		body.reparent(get_tree().root)
		body.freeze = false
	_tracking.clear()

	for node in BottleShard.spawn_shards():
		get_tree().root.add_child(node)
		node.global_position = global_position
		node.linear_velocity = Vector2.UP.rotated(randf_range(-PI/2., PI/2.)) * 480.0
		node.angular_velocity = TAU

	queue_free()


func _ready() -> void:
	#body_entered.connect(_body_entered)
	for body: Furble in %Creatures.get_children():
		body.type = type
		body.freeze = true
		_tracking.push_back(body)


func _process(delta: float) -> void:
	if should_shatter:
		should_shatter = false
		shatter()
	if _mouse_motion:
		var rel := _mouse_motion.relative
		_mouse_motion = null
		position += rel
		linear_velocity = rel / delta
	elif _is_dragging:
		linear_velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if _is_dragging:
		var fix := get_viewport().get_mouse_position() - global_position
		apply_central_force(fix * 500.0)


func _unhandled_input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseMotion:
			sleeping = false
			if not _mouse_motion:
				_mouse_motion = event
			else:
				_mouse_motion.accumulate(event)


func _input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseButton:
			_is_dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _is_dragging:
		state.apply_central_force(-state.total_gravity)

	#for idx in state.get_contact_count():
		#var impulse := state.get_contact_impulse(idx)
		#if not impulse.is_zero_approx():
			#if impulse.length() > 128.0:
				#var other = state.get_contact_collider_object(idx)
				#if other is Furble: continue
				#print('%s _integrate_forces %s %s' % [self, impulse.length(), other])
				#should_shatter = true
				#break

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
	if body is Furble and _tracking.has(body):
		body.linear_velocity = Vector2.ZERO
		body.global_position = global_position
		#body.teleport(global_position - body.global_position)
