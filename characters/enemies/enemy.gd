extends CharacterBody3D

@export var speed = 3.0
@export var health: int = 100

@export var spearman: Spearman

@onready var health_bar = $Sprite3D/SubViewport/HealthBar3D

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	
	speed *= 50


func _physics_process(delta: float) -> void:
	var direction = (spearman.global_position - global_position).normalized()
	velocity = direction * speed * delta
	look_at(spearman.global_position)
	move_and_slide()


func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		queue_free()
	
	health_bar.value = health
