@tool
extends RigidBody2D
class_name BottleShard


@export_range(1, 15) var which := 1:
	set(value):
		which = value
		queue_redraw()


func _draw() -> void:
	for i in range(1, 16):
		var enabled := i == which
		get_node('%d' % [i]).visible = enabled
		get_node('CollisionPolygon2D%d' % [i]).disabled = not enabled


func _ready() -> void:
	if Engine.is_editor_hint(): return
	await get_tree().create_timer(5.0).timeout
	queue_free()
