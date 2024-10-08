extends Label


func _ready() -> void:
	var timer := Timer.new()
	timer.timeout.connect(queue_redraw)
	timer.autostart = true
	timer.wait_time = 0.05
	add_child(timer)


func _draw() -> void:
	var base_layer = get_tree().get_first_node_in_group("level_base_layer") as LevelBaseLayer
	text = '%s left' % maxi(base_layer.victory_points - base_layer.current_points, 0)
