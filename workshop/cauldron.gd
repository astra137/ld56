extends CharacterBody2D
class_name Cauldron


@export var spill_target: Marker2D

@onready var original_position := global_position

var tween: Tween
var furbles: Array[Furble] = []


func spill(level: LevelBaseLayer) -> void:
	assert(not tween)
	var root := get_tree().root
	var list := furbles.duplicate()
	for body in list:
		body.reparent(self)
		level.track_furble(body)
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, ^'global_position', spill_target.global_position, 1.0)
	tween.tween_property(self, ^'rotation', PI*0.99, 1.0)
	tween.chain()
	tween.tween_callback(func(): for body in list: body.reparent(root))
	tween.tween_interval(2.0)
	tween.chain()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, ^'global_position', original_position, 1.0)
	tween.tween_property(self, ^'rotation', 0, 1.0)
	await tween.finished
	tween = null


func _on_container_body_entered(body: Furble) -> void:
	furbles.push_back(body)
	body.cauldron = self


func _on_container_body_exited(body: Furble) -> void:
	furbles.erase(body)
	body.cauldron = null


func _on_bottle_entered(body: Bottle) -> void:
	body.shatter()
