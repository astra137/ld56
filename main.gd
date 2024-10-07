extends Node


const CENTER_LEFT := Vector2(1440, 810) * 0.5
const CENTER_RIGHT := CENTER_LEFT + Vector2(1440, 0)


var camera_toggle: bool = false
var camera_tween: Tween


func pan_camera(rightside: bool) -> void:
	camera_toggle = rightside
	var pos := CENTER_RIGHT if camera_toggle else CENTER_LEFT
	if camera_tween: camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.tween_property(%Camera2D, ^'position', pos, 0.6)


func _on_button_view_pressed() -> void:
	pan_camera(not camera_toggle)


func _on_button_clean_pressed() -> void:
	pan_camera(false)
	get_tree().call_group(&'bottles', &'shatter')
	get_tree().call_group(&'furble', &'queue_free')


func _on_button_spill_pressed() -> void:
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonClean.disabled = true
	pan_camera(true)
	var list: Array[Furble] = await %Workshop.spill()
	var victory: bool = await $BattleScreen/LevelBaseLayer.start_level(list)
	%ButtonView.disabled = false
	%ButtonSpill.disabled = false
	%ButtonClean.disabled = false
	_on_button_clean_pressed()
	%VictoryBanner.show_message('Victory!' if victory else 'Massive L!')
