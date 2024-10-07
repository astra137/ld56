@tool
extends TextureButton


@export var text := 'Btn':
	set(value):
		text = value
		queue_redraw()


func _draw() -> void:
	$Label.text = text
