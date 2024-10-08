extends Node

const FURBLE := preload("res://battle_screen/little_creature.tscn")

const CENTER_MENU := Vector2(1750, 405)
const CENTER_LEFT := Vector2(720, 405)
const CENTER_RIGHT := CENTER_LEFT + Vector2(1440, 0)


var sandbox := false
var level_node: Node
var level_number := 1:
	set(value):
		level_number = clampi(value, 1, 11)

var camera_toggle := false
var camera_tween: Tween

enum GameState {
	WORKSHOP,
	SPILLING,
	BATTLING,
	VICTORY,
	DEFEAT,
	RESETTING
}


var game_state := GameState.WORKSHOP


func swap_level(node: Node) -> void:
	for n in %Level.get_children():
		%Level.remove_child(n)
		n.queue_free()
	%Level.add_child(node)
	level_node = node


func load_level(next_level := level_number) -> void:
	level_number = next_level
	save_persistent_level()
	%LabelLevel.text = 'Level %s' % [level_number]
	match level_number:
		2: swap_level(load('res://battle_screen/levels/level_2.tscn').instantiate())
		3: swap_level(load('res://battle_screen/levels/level_4.tscn').instantiate())
		4: swap_level(load('res://battle_screen/levels/level_5.tscn').instantiate())
		5: swap_level(load('res://battle_screen/levels/level_6.tscn').instantiate())
		6: swap_level(load('res://battle_screen/levels/level_7.tscn').instantiate())
		7: swap_level(load('res://battle_screen/levels/level_8.tscn').instantiate())
		8: swap_level(load('res://battle_screen/levels/level_9.tscn').instantiate())
		9: swap_level(load('res://battle_screen/levels/level_10.tscn').instantiate())
		10: swap_level(load('res://battle_screen/levels/level_11.tscn').instantiate())
		11: swap_level(load('res://battle_screen/levels/level_12.tscn').instantiate())
		_: swap_level(load('res://battle_screen/levels/level_1.tscn').instantiate())


func pan_camera(rightside: bool) -> void:
	camera_toggle = rightside
	var pos := CENTER_RIGHT if camera_toggle else CENTER_LEFT
	if camera_tween: camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.tween_property(%Camera2D, ^'position', pos, 0.6)
	get_tree().call_group(&'bottles', &'screen_switch')
	await camera_tween.finished


func _ready() -> void:
	%GameMenu.hide()


# State transitions
func workshop():
	%ButtonView.disabled = false
	%ButtonSpill.disabled = false
	%ButtonReset.disabled = false
	load_level()
	game_state = GameState.WORKSHOP

func spilling():
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonReset.disabled = true
	game_state = GameState.SPILLING
	load_level()
	pan_camera(true)
	var level: LevelBaseLayer = level_node.get_node('LevelBaseLayer')
	await %Workshop.spill(level)
	battling(level)


func battling(level: LevelBaseLayer):
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonReset.disabled = false
	game_state = GameState.BATTLING
	var victory := await level.start_level()
	if game_state == GameState.BATTLING:
		if victory:
			victory()
		else:
			defeat()


func victory():
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonReset.disabled = true
	game_state = GameState.VICTORY
	await %VictoryBanner.show_message('Victory!')
	level_number += 1
	resetting()

func defeat():
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonReset.disabled = true
	game_state = GameState.DEFEAT
	await %VictoryBanner.show_message('Nice Try!')
	resetting()

func resetting():
	%ButtonView.disabled = true
	%ButtonSpill.disabled = true
	%ButtonReset.disabled = true
	get_tree().call_group(&'bottles', &'queue_free')
	get_tree().call_group(&'furble', &'queue_free')
	game_state = GameState.RESETTING
	await pan_camera(false)
	workshop()


func _unhandled_input(event: InputEvent) -> void:
	if not sandbox: return
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_F1: load_level(level_number - 1)
			KEY_F2: load_level(level_number + 1)
			KEY_1: spawn_furble(Furble.CreatureTypes.FIRE)
			KEY_2: spawn_furble(Furble.CreatureTypes.ICE)
			KEY_3: spawn_furble(Furble.CreatureTypes.EARTH)
			KEY_4: spawn_furble(Furble.CreatureTypes.ARCANE)
			KEY_5: spawn_furble(Furble.CreatureTypes.WATER)
			KEY_6: spawn_furble(Furble.CreatureTypes.ELECTRICITY)
			KEY_7: spawn_furble(Furble.CreatureTypes.WIND)
			KEY_8: spawn_furble(Furble.CreatureTypes.GRAVITY)


func spawn_furble(type: Furble.CreatureTypes):
	var node: Furble = FURBLE.instantiate()
	add_child(node)
	node.type = type
	if camera_toggle:
		node.level = level_node.get_node('LevelBaseLayer')
	else:
		node.update_lifetime()
	node.global_position = node.get_global_mouse_position()


func _on_button_view_pressed() -> void:
	pan_camera(not camera_toggle)


func _on_button_reset_pressed() -> void:
	if game_state == GameState.WORKSHOP or game_state == GameState.BATTLING:
		resetting()


func _on_button_spill_pressed() -> void:
	if game_state == GameState.WORKSHOP:
		spilling()


func load_persistent_level() -> void:
	var cfg := ConfigFile.new()
	cfg.load('user://save.cfg')
	level_number = cfg.get_value('', 'level', 1)


func save_persistent_level() -> void:
	if sandbox: return
	var cfg := ConfigFile.new()
	cfg.set_value('', 'level', level_number)
	cfg.save('user://save.cfg')


func _on_btn_play_pressed() -> void:
	load_persistent_level()
	resetting()
	%MainMenu.hide()
	%GameMenu.show()
	%LabelFPS.visible = sandbox
	%LabelFurbles.visible = sandbox


func _on_btn_sandbox_pressed() -> void:
	sandbox = true
	_on_btn_play_pressed()
