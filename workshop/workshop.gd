extends Node2D


func spill() -> Array[Furble]:
	return await %Cauldron.spill()
