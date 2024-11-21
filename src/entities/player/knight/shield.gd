extends Area2D
class_name PlayerShield
@onready var fx_anim: AnimationPlayer = $"../FXAnim"
@onready var damage_spawn: Marker2D = %DamageSpawn
@onready var weapon_sfx: AudioStreamPlayer = $"../WeaponSFX"
@export var block_sfx: AudioStream

func notify_hit(amount: int, entity: CollisionObject2D) -> void:
	print("blocking")
	if fx_anim.is_playing() and fx_anim.current_animation == "parry_hold" and entity.has_method("notify_hit"):
		print("parrying")
		entity.notify_hit(amount, true)
		fx_anim.play("parry_attack")
	else:
		weapon_sfx.stream = block_sfx
		weapon_sfx.play()
		GameEnviroment.show_damage(damage_spawn.global_position, 0, false, true)
