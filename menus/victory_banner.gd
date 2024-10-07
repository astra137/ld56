extends CenterContainer


@export var template := '[font size=72][wave amp=72.0 freq=5.0 connected=1]{text}[/wave][/font]':
	set(value):
		template = value
		queue_redraw()


@export var text := '':
	set(value):
		text = value
		queue_redraw()


func _draw() -> void:
	%RichTextLabel.text = template.format({ 'text': text })


func show_message(msg: String) -> void:
	text = msg
	await get_tree().create_timer(3.0).timeout
	text = ''
