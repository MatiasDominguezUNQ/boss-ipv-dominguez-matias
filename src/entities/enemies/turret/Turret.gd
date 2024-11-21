extends CharacterBody2D
class_name EnemyTurret

signal hit(amount)

@onready var fire_position: Node2D = $FirePosition
@onready var raycast: RayCast2D = $RayCast2D
@onready var damage_spawn: Marker2D = %DamageSpawn

@onready var body_anim: AnimatedSprite2D = $Body
@export var projectile_scene: PackedScene
@export var wander_radius: Vector2 = Vector2(10.0, 10.0)
@export var pathfinding_path: NodePath
@export var speed: float = 10.0
@export var max_speed: float = 100.0
@export var attack_sfx: AudioStream
@export var die_sfx: AudioStream
@export var experience_reward: int = 1
@onready var pathfinding: PathfindAstar = get_node_or_null(pathfinding_path)
@onready var body_sfx: AudioStreamPlayer2D = $BodySFX

var target: Node2D
var projectile_container: Node
## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false
var spike_walk_skill = false

func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container

func _fire() -> void:
	if target != null:
		var proj_instance: Node = projectile_scene.instantiate()
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(
			projectile_container,
			fire_position.global_position,
			fire_position.global_position.direction_to(Vector2(target.global_position.x,target.global_position.y-10)),
			self
		)

func _physics_process(delta: float) -> void:
	## Damos vuelta el cuerpo para que mire al objetivo en el eje x
	## y usamos la dirección a la que se casteó el raycast
	## Otra manera sería hacer (target.global_position - global_position).x < 0
	body_anim.flip_h = raycast.target_position.x < 0

func _set_velocity(next_point):
	velocity = (velocity + global_position.direction_to(next_point) * speed).limit_length(max_speed)
	body_anim.flip_h = velocity.x < 0

func _can_see_target():
	if target == null:
		return false
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	return raycast.is_colliding() && raycast.get_collider() == target

func _apply_movement():
	set_velocity(velocity)
	move_and_slide()

func notify_hit(amount = 1) -> void:
	emit_signal("hit", amount)

func _remove() -> void:
	GameState.give_experience.emit(experience_reward)
	get_parent().remove_child(self)
	queue_free()

## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_anim.sprite_frames.has_animation(animation):
		body_anim.play(animation)

func get_current_animation():
	return body_anim.animation
