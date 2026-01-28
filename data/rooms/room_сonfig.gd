class_name RoomConfig
extends Resource

@export var enemy_types: Array[EnemyType.Enemy]
@export var enemy_positions: Array[Vector3]


func get_enemies_count() -> int:
	if enemy_types == null or enemy_positions == null:
		push_error("[RoomConfig] enemy_types or enemy_positions is not set.")
		return 0
	
	if enemy_types.size() != enemy_positions.size():
		push_error("[RoomConfig] enemy_types.size() != enemy_positions.size()!")
		return 0
	
	return enemy_types.size()
