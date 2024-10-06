extends RigidBody2D
class_name FauxFurble


@export var type := Furble.CreatureTypes.FIRE


func _on_body_entered(body: Node) -> void:
	if body is FauxFurble:
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
