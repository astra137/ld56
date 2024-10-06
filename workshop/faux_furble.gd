@tool
extends RigidBody2D


@export var type := Furble.CreatureTypes.FIRE:
	set(value):
		type = value
		modulate = CreatureConfiguration.type_configuration[type].color


#func _draw() -> void:
	#modulate = CreatureConfiguration.type_configuration[type].color


func _on_body_entered(body: Node) -> void:
	if body is Furble:
		pass
		#print_verbose('%s touched %s' % [self.type, body.type])
		#angular_velocity = 10.0 * TAU


var _teleport_pending := false
var _teleport_vector := Vector2.ZERO


func teleport(delta: Vector2) -> void:
	_teleport_pending = true
	_teleport_vector += delta


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _teleport_pending:
		state.transform.origin += _teleport_vector
		_teleport_pending = false
		_teleport_vector = Vector2.ZERO
