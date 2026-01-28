class_name LevelConfig
extends Resource

@export var floors: Array[FloorConfig] = []


func get_floor_count() -> int:
	if floors.is_empty():
		push_error("[LevelConfig] floors array is empty.")
		return 0
	
	return floors.size()
