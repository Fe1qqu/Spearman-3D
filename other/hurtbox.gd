class_name HurtBox
extends Area3D

@export var damage_interval: float = 1.0
@export var invulnerability_time: float = 0.5

var hitbox_in_area: HitBox = null
var damage_timer: Timer = Timer.new()
var invulnerability_timer: Timer = Timer.new()
var is_invulnerable: bool = false

func _ready() -> void:
	# Setting up a timer for the damage interval
	damage_timer.wait_time = damage_interval
	damage_timer.one_shot = false
	damage_timer.autostart = false
	add_child(damage_timer)
	damage_timer.connect("timeout", self._deal_damage)
	
	# Setting a timer for invulnerability
	invulnerability_timer.wait_time = invulnerability_time
	invulnerability_timer.one_shot = true
	invulnerability_timer.autostart = false
	add_child(invulnerability_timer)
	invulnerability_timer.connect("timeout", self._end_invulnerability)
	
	connect("area_entered", self._on_area_entered)
	connect("area_exited", self._on_area_exited)

func _on_area_entered(hitbox: HitBox) -> void:
	if (hitbox.is_in_group("hitboxes") and not (owner.is_in_group("enemies") 
		and hitbox.owner.is_in_group("enemies")) and owner.has_method("take_damage")):
		hitbox_in_area = hitbox
		_try_deal_damage()
		if damage_timer.is_stopped():
			damage_timer.start()

func _on_area_exited(hitbox: HitBox) -> void:
	if hitbox == hitbox_in_area:
		hitbox_in_area = null
		damage_timer.stop()

func _deal_damage() -> void:
	_try_deal_damage()

func _try_deal_damage() -> void:
	if not is_invulnerable and hitbox_in_area:
		owner.take_damage(hitbox_in_area.damage)
		hitbox_in_area.emit_signal("hit_target", owner)
		is_invulnerable = true
		invulnerability_timer.start()

func _end_invulnerability() -> void:
	is_invulnerable = false
