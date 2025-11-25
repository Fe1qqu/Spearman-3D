extends Node3D
class_name Fireball

const EXPLOSION_SCENE: PackedScene = preload("res://vfx/Explosion/explosion.tscn")

@export var speed: float = 30.0
@export var lifetime: float = 5.0
@export var direction: Vector3 = Vector3.ZERO

@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	audio_stream_player.playing = true
	
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()
	look_at(global_position + direction)

# Called when fireball HitBox hits a target via HurtBox
func _on_hit_target(_target: Node) -> void:
	pass
	#queue_free()

# Called when fireball hits a wall / environment
func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is StaticBody3D or body.is_in_group("environment"):
		_spawn_explosion()
		queue_free()

func _spawn_explosion() -> void:
	if EXPLOSION_SCENE == null:
		return
	
	var explosion: Node3D = EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion)
	
	explosion.global_position = global_position
	
	var animation_player: AnimationPlayer = explosion.get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("explode")
		animation_player.connect("animation_finished", func(_a): explosion.queue_free())
