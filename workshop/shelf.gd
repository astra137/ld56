extends StaticBody2D

const BOTTLE = preload('res://workshop/bottle.tscn')
const ROW1 = -132
const ROW2 = -44


var bottles: Array[RigidBody2D] = []


func idx_to_pos(idx: int) -> Vector2:
	match idx:
		0: return Vector2(-132, -132)
		1: return Vector2(-44, -132)
		2: return Vector2(44, -132)
		3: return Vector2(132, -132)
		4: return Vector2(-132, -44)
		5: return Vector2(-44, -44)
		6: return Vector2(44, -44)
		7: return Vector2(132, -44)
		_: return Vector2.ZERO


func spawn_bottle(idx: int) -> RigidBody2D:
	var bottle: RigidBody2D = BOTTLE.instantiate()
	bottle.tree_exiting.connect(handle_bottle_gone.bind(idx))
	bottle.type = idx as Furble.CreatureTypes
	bottle.position = idx_to_pos(idx)
	%Bottles.add_child.call_deferred(bottle)
	bottles[idx] = bottle
	return bottle


func handle_bottle_gone(idx: int) -> void:
	bottles[idx].queue_free()
	await get_tree().create_timer(1.0).timeout
	spawn_bottle(idx)


func _ready() -> void:
	bottles.resize(8)
	for idx in 8: spawn_bottle(idx)
