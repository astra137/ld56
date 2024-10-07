extends Obstacle


func freeze():
	can_wash_away = true
	can_stick = true
	super.freeze()

func default():
	can_wash_away = false
	can_stick = false
	super.default()
