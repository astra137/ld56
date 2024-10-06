extends Label


func _ready() -> void:
	var timer := Timer.new()
	timer.timeout.connect(queue_redraw)
	timer.autostart = true
	timer.wait_time = 0.2
	add_child(timer)


func _draw() -> void:
	text = '%s furbles' % [get_tree().get_node_count_in_group(&'furble')]
