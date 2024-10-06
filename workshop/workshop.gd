extends Node2D


const FURBLE = preload('res://battle_screen/little_creature.tscn')


func _on_cauldron_clicked(cursor: Vector2) -> void:
	printerr('_on_cauldron_clicked')


func spawn_furble(cursor: Vector2) -> void:
	var body: Furble = FURBLE.instantiate()
	add_child(body)
	body.type = randi_range(0, 7) as Furble.CreatureTypes
	body.global_position = cursor
