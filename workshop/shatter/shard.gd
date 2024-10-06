@tool
extends RigidBody2D
class_name BottleShard


const BOTTLE_SHARD = preload('res://workshop/shatter/shard.tscn')


@export_range(1, 15) var which := 1:
	set(value):
		which = value
		queue_redraw()


static func spawn_shards(count := 4) -> Array[BottleShard]:
	var list: Array[BottleShard] = []
	var indices := [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	indices.shuffle()
	for i in count:
		var node: BottleShard = BOTTLE_SHARD.instantiate()
		node.which = indices[i]
		list.push_back(node)
	return list


func _draw() -> void:
	for i in range(1, 16):
		var enabled := i == which
		get_node('%d' % [i]).visible = enabled
		get_node('CollisionPolygon2D%d' % [i]).disabled = not enabled


func _ready() -> void:
	if Engine.is_editor_hint(): return
	await get_tree().create_timer(5.0).timeout
	queue_free()
