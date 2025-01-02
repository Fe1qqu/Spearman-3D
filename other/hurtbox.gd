class_name HurtBox
extends Area3D

@export var damage_interval: float = 1.0
var hitbox_in_area: HitBox = null

var damage_timer: Timer = Timer.new()

func _ready() -> void:
	damage_timer.wait_time = damage_interval
	damage_timer.one_shot = false
	damage_timer.autostart = false
	add_child(damage_timer)
	damage_timer.connect("timeout", self._deal_damage)
	connect("area_entered", self._on_area_entered)
	connect("area_exited", self._on_area_exited)


func _on_area_entered(hitbox: HitBox) -> void:
	if (hitbox.is_in_group("hitboxes") and not (owner.is_in_group("enemies") and hitbox.owner.is_in_group("enemies")) 
		and owner.has_method("take_damage")):
		hitbox_in_area = hitbox
		_deal_damage()
		if damage_timer.is_stopped():
			damage_timer.start()


func _on_area_exited(hitbox: HitBox) -> void:
	if hitbox == hitbox_in_area:
		hitbox_in_area = null
		damage_timer.stop()


func _deal_damage() -> void:
	owner.take_damage(hitbox_in_area.damage)
