extends Label


func _process(_delta: float) -> void:
	text = '%s fps' % [Engine.get_frames_per_second()]
