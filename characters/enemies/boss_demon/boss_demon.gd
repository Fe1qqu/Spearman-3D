extends Enemy

@export var fireball_scene: PackedScene = preload("res://projectiles/fireball.tscn")
@export var fireball_delay: float = 5.0

func _ready() -> void:
	super._ready()
	shoot_fireball()
	_schedule_next_attack()

func _schedule_next_attack() -> void:
	await get_tree().create_timer(fireball_delay).timeout
	if not is_inside_tree():
		return
	shoot_fireball()
	_schedule_next_attack()

func shoot_fireball() -> void:
	if not spearman or not is_inside_tree():
		return

	var fireball: Fireball = fireball_scene.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position + Vector3(0, 1.5, 0)
	fireball.set_direction((spearman.global_position - global_position).normalized())
