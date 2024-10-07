extends Node


const CENTER_LEFT := Vector2(1440, 810) * 0.5
const CENTER_RIGHT := CENTER_LEFT + Vector2(1440, 0)


var level_node: Node
var level_number := 1:
	set(value):
		level_number = clampi(value, 1, 5)

var camera_toggle := false
var camera_tween: Tween


func swap_level(node: Node) -> void:
	for n in %Level.get_children():
		%Level.remove_child(n)
		n.queue_free()
	%Level.add_child(node)
	level_node = node


func load_level(next_level := level_number) -> void:
	level_number = next_level
	match level_number:
		2: swap_level(load('res://battle_screen/levels/level_2.tscn').instantiate())
		3: swap_level(load('res://battle_screen/levels/level_4.tscn').instantiate())
		4: swap_level(load('res://battle_screen/levels/level_5.tscn').instantiate())
		5: swap_level(load('res://battle_screen/levels/level_6.tscn').instantiate())
		_: swap_level(load('res://battle_screen/levels/level_1.tscn').instantiate())


func pan_camera(rightside: bool) -> void:
	camera_toggle = rightside
	var pos := CENTER_RIGHT if camera_toggle else CENTER_LEFT
	if camera_tween: camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.tween_property(%Camera2D, ^'position', pos, 0.6)
	await camera_tween.finished


func _ready() -> void:
	load_level()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if event is InputEventKey and event.is_released():
		match event.keycode:
			KEY_F1: load_level(level_number - 1)
			KEY_F2: load_level(level_number + 1)


func _on_button_view_pressed() -> void:
	pan_camera(not camera_toggle)


func _on_button_reset_pressed() -> void:
	get_tree().call_group(&'bottles', &'shatter')
	get_tree().call_group(&'furble', &'queue_free')
	await pan_camera(false)
	load_level()


func _on_button_spill_pressed() -> void:
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonReset.disabled = true
	pan_camera(true)
	var list: Array[Furble] = await %Workshop.spill()
	%ButtonReset.disabled = false
	var victory: bool = await level_node.get_node('LevelBaseLayer').start_level(list)
	await %VictoryBanner.show_message('Victory!' if victory else 'Massive L!')
	if victory: level_number += 1
	await _on_button_reset_pressed()
	%ButtonView.disabled = false
	%ButtonSpill.disabled = false
