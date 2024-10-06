extends Node2D


signal clicked(cursor: Vector2)


func _on_clickable_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(event.global_position)


func _on_clickable_mouse_entered() -> void:
	print_verbose('_on_clickable_mouse_entered')


func _on_clickable_mouse_exited() -> void:
	print_verbose('_on_clickable_mouse_exited')
