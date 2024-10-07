extends CharacterBody2D


signal clicked()


@export var spill_target: Marker2D


var is_spilling := false
var furbles: Array[Furble] = []


func awaken_furbles(list: Array[Furble]) -> void:
	for body in list:
		body.reparent(get_tree().root)
		body.state = Furble.MovementStates.FALLING


func spill() -> void:
	is_spilling = true
	var original := global_position
	var list := furbles.duplicate()
	for body in list: body.reparent(self)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, ^'global_position', spill_target.global_position, 1.0)
	tween.tween_property(self, ^'rotation', PI*0.99, 1.0)
	tween.chain()
	tween.tween_callback(awaken_furbles.bind(list))
	tween.tween_interval(2.0)
	tween.chain()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, ^'global_position', original, 1.0)
	tween.tween_property(self, ^'rotation', 0, 1.0)
	await tween.finished
	for body in furbles: body.queue_free()
	is_spilling = false


func _on_clickable_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()


func _on_clickable_mouse_entered() -> void:
	print_verbose('_on_clickable_mouse_entered')


func _on_clickable_mouse_exited() -> void:
	print_verbose('_on_clickable_mouse_exited')



const SPEED = 600.0

var gravity: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity") \
	* ProjectSettings.get_setting("physics/2d/default_gravity_vector")


func _physics_process(delta):
	if is_spilling:
		#velocity = Vector2.ZERO
		#move_and_slide()
		return

	if not is_on_floor():
		velocity += gravity * delta
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func _on_container_body_entered(body: Node2D) -> void:
	furbles.push_back(body)


func _on_container_body_exited(body: Node2D) -> void:
	furbles.erase(body)
