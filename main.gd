extends Node


const CENTER_LEFT := Vector2(1440, 810) * 0.5
const CENTER_RIGHT := CENTER_LEFT + Vector2(1440, 0)


var camera_tween: Tween


func tween_camera(final: Vector2) -> void:
	if camera_tween: camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.tween_property(%Camera2D, ^'position', final, 0.6)


func _ready() -> void:
	%Camera2D.position = CENTER_LEFT


func _on_button_left_pressed() -> void:
	tween_camera(CENTER_LEFT)


func _on_button_right_pressed() -> void:
	tween_camera(CENTER_RIGHT)


func _on_button_spill_pressed() -> void:
	pass # Replace with function body.
