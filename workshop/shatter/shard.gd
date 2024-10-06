@tool
extends RigidBody2D


@export_range(1, 15) var which := 1:
	set(value):
		which = value
		queue_redraw()


func randomize_shard() -> void:
	which = randi_range(1, 15)


func _draw() -> void:
	for i in range(1, 16):
		var enabled := i == which
		get_node('%d' % [i]).visible = enabled
		get_node('CollisionPolygon2D%d' % [i]).disabled = not enabled
