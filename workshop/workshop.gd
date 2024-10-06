extends Node2D


const FAUX_FURBLE = preload('res://workshop/faux_furble.tscn')

var count := 0


func _process(_delta: float) -> void:
	%FPS.text = '%s\n%s' % [Engine.get_frames_per_second(), count]


func _on_cauldron_clicked(cursor: Vector2) -> void:
	spawn_furble(cursor)


func spawn_furble(cursor: Vector2) -> void:
	var body: FauxFurble = FAUX_FURBLE.instantiate()
	add_child(body)
	body.type = randi_range(0, 8) as Furble.CreatureTypes
	body.global_position = cursor
	count += 1
