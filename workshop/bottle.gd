extends CharacterBody2D


var is_dragging := false


func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion:
		position += event.relative


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_area_2d_mouse_entered() -> void:
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
