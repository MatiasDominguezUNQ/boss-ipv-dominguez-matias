extends Node2D

@onready var weapon_tip: Node2D = $WeaponTip
@onready var fx_anim: AnimationPlayer = $FXAnim
@onready var bow_crit: AudioStreamPlayer = $BowCrit
@onready var weapon_sfx: AudioStreamPlayer = $WeaponSFX
@onready var charge_effect: Node2D = $ChargeEffect
@onready var charged_particles: GPUParticles2D = $ChargedParticles
@onready var special_sfx: AudioStreamPlayer = $SpecialSFX

@export var prepare_fire_sfx: AudioStream
@export var fire_sfx: AudioStream
@export var crit_sfx: AudioStream
@export var special_attack_sfx: AudioStream
@export var projectile_scene: PackedScene
@onready var ranger: Player = $"../.."

var projectile_container: Node
var fire_tween: Tween
var fire_position


func cancel_attack():
	fx_anim.play("fire_release", -1, ranger.attack_speed)
	weapon_sfx.stop()

func process_input() -> void:
	if fx_anim.is_playing() && fx_anim.current_animation == "fire_start" && !Input.is_action_pressed("primary_attack"):
		fx_anim.play("fire_release", -1, ranger.attack_speed)
		weapon_sfx.stop()
	if fx_anim.is_playing() && fx_anim.current_animation == "fire_start_special" && !Input.is_action_pressed("secondary_attack"):
		fx_anim.play("fire_release", -1, ranger.attack_speed)
		weapon_sfx.stop()
	if fx_anim.is_playing() && fx_anim.current_animation == "fire_hold" && !Input.is_action_pressed("primary_attack"):
		fx_anim.play("fire_release", -1, ranger.attack_speed)
		_fire()
	if fx_anim.is_playing() && fx_anim.current_animation == "fire_crit" && !Input.is_action_pressed("primary_attack"):
		fx_anim.play("fire_release", -1, ranger.attack_speed)
		_fire_crit()
	if fx_anim.is_playing() && fx_anim.current_animation == "fire_hold_special" && !Input.is_action_pressed("secondary_attack"):
		fx_anim.play("fire_release_special")
		_fire_special()
	if fx_anim.is_playing():
		rotation = (get_global_mouse_position() - global_position).angle()


func fire() -> void:
	weapon_sfx.stream = prepare_fire_sfx
	fx_anim.play("fire_start", -1, ranger.attack_speed)
	weapon_sfx.play()

func fire_special():
	fx_anim.play("fire_start_special")

## La animación de disparo llama a esta función que va a ser la que instancie
## el proyectil
func _fire() -> void:
	weapon_sfx.stream = fire_sfx
	weapon_sfx.play()
	projectile_scene.instantiate().initialize(projectile_container, weapon_tip.global_position, global_position.direction_to(weapon_tip.global_position), self.get_parent().get_parent(), ranger.damage)

func _fire_crit() -> void:
	weapon_sfx.stream = fire_sfx
	weapon_sfx.play()
	var damage = ranger.damage + ranger.critical_damage
	projectile_scene.instantiate().initialize(projectile_container, weapon_tip.global_position, global_position.direction_to(weapon_tip.global_position), self.get_parent().get_parent(), damage, true)

func _fire_special() -> void:
	var damage = ranger.damage + ranger.critical_damage
	projectile_scene.instantiate().initialize(projectile_container, weapon_tip.global_position, global_position.direction_to(weapon_tip.global_position), self.get_parent().get_parent(), damage, true, true)
	ranger.can_special_attack = false
	ranger.stamina_bar.start_timer()
	
func _on_fx_anim_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fire_start":
			if ranger.crit_skill:
				bow_crit.stream = crit_sfx
				bow_crit.play()
				fx_anim.play("fire_crit")
			else:
				fx_anim.play("fire_hold")
		"fire_crit":
			fx_anim.play("fire_hold")
		"fire_start_special":
			fx_anim.play("fire_hold_special")
		"fire_release_special":
			special_sfx.stream = special_attack_sfx
			special_sfx.play()
