extends Node2D


const FURBLE = preload('res://battle_screen/little_creature.tscn')

var count := 0


func _process(_delta: float) -> void:
	%FPS.text = '%s\n%s' % [Engine.get_frames_per_second(), count]


func _on_cauldron_clicked(cursor: Vector2) -> void:
	spawn_furble(cursor)


func spawn_furble(cursor: Vector2) -> void:
	var body: Furble = FURBLE.instantiate()
	add_child(body)
	body.type = randi_range(0, 7) as Furble.CreatureTypes
	body.global_position = cursor
	count += 1
