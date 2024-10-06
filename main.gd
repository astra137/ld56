extends Node


const CENTER_LEFT := Vector2(1440, 810) * 0.5
const CENTER_RIGHT := CENTER_LEFT + Vector2(1440, 0)


var camera_right := false
var camera_tween: Tween


func toggle_camera() -> void:
	camera_right = not camera_right
	var pos := CENTER_RIGHT if camera_right else CENTER_LEFT
	if camera_tween: camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.tween_property(%Camera2D, ^'position', pos, 0.6)


func _on_button_view_pressed() -> void:
	toggle_camera()


func _on_button_spill_pressed() -> void:
	pass # Replace with function body.


func _on_button_clean_pressed() -> void:
	get_tree().call_group(&'bottles', &'shatter')
	get_tree().call_group(&'furble', &'queue_free')
