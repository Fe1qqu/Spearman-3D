extends CharacterBody3D
class_name Enemy

@export var speed = 30.0
@export var health: int = 100

@export var spearman: Spearman

func _ready() -> void:
	$Sprite3D/SubViewport/HeathBar3D.max_value = health
	$Sprite3D/SubViewport/HeathBar3D.value = health

func _physics_process(delta: float) -> void:
	var direction = (spearman.global_position - global_position).normalized()
	velocity = direction * speed * delta
	look_at(spearman.global_position)
	move_and_slide()

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		queue_free()
	
	$Sprite3D/SubViewport/HeathBar3D.value = health
