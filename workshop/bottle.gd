extends StaticBody2D


const SHARD = preload('res://workshop/shatter/shard.tscn')


@export var type := Furble.CreatureTypes.FIRE

var _is_dragging := false
var _mouse_motion: InputEventMouseMotion = null
var _tracking: Array[Furble] = []


func shatter() -> void:
	var cork := $Cork
	cork.reparent(get_tree().root)
	cork.freeze = false
	cork.apply_central_impulse(Vector2.UP * 1.0)
	for body in _tracking:
		body.reparent(get_tree().root)
	_tracking.clear()
	for i in 4:
		var node: RigidBody2D = SHARD.instantiate()
		node.randomize_shard()
		get_tree().root.add_child(node)
		node.global_position = global_position
		node.linear_velocity = 2.0 * Vector2.RIGHT.rotated(randf() * TAU)
	queue_free()


func _ready() -> void:
	for body: Furble in %Creatures.get_children():
		body.type = type
		_tracking.push_back(body)


func _input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseMotion:
			if not _mouse_motion:
				_mouse_motion = event
			else:
				_mouse_motion.accumulate(event)
		elif event is InputEventMouseButton:
			_is_dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _process(delta: float) -> void:
	if _mouse_motion:
		var rel := _mouse_motion.relative
		_mouse_motion = null
		position += rel
		#for body in _tracking: body.teleport(rel)
		constant_linear_velocity = rel / delta
	else:
		constant_linear_velocity = Vector2.ZERO


func _on_clickable_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.is_pressed()
			viewport.set_input_as_handled()


func _on_container_body_exited(body: Node2D) -> void:
	if body is Furble and _tracking.has(body):
		body.linear_velocity = Vector2.ZERO
		#body.global_position = global_position
		body.teleport(global_position - body.global_position)


func _on_shatter_trigger_body_entered(body: Node2D) -> void:
	printerr('_on_shatter_trigger_body_entered ', body)
	shatter.call_deferred()
