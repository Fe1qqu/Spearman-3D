class_name SceneDatabase
extends Resource

@export var enemies: Dictionary[EnemyType.Enemy, PackedScene]
@export var bosses: Dictionary[EnemyType.Boss, PackedScene]
@export var items: Dictionary[ItemType.Item, PackedScene]

func get_enemy(enemy_type: EnemyType.Enemy) -> PackedScene:
	if not enemies.has(enemy_type):
		push_error("[SceneDatabase] Enemy scene not found: %s" % enemy_type)
		return null
	
	return enemies[enemy_type]

func get_boss(boss_type: EnemyType.Boss) -> PackedScene:
	if not bosses.has(boss_type):
		push_error("[SceneDatabase] Boss scene not found: %s" % boss_type)
		return null
	
	return bosses[boss_type]

func get_item(item_type: ItemType.Item) -> PackedScene:
	if not items.has(item_type):
		push_error("[SceneDatabase] Item scene not found: %s" % item_type)
		return null
	
	return items[item_type]
