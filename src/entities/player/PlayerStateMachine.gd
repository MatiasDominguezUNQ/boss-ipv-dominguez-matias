## Esta State Machine en particular del player solo extiende la
## funcionalidad de la State Machine abstracta para ajustarse
## a las necesidades del personaje a usar. Para estructuras de juego
## más complejas, generalmente se abstraen estos métodos para crear
## un controller genérico que se pueda asignar a cualquier entidad.
extends AbstractStateMachine


## Esta función deriva el handleo de cada golpe que recibe
## el personaje al estado actual particular, en vez de vincular
## la señal de "hit" a los estados que lo usan, ya que sino se
## podría ejecutar código de estados inactivos.
func notify_hit(amount: int, isCrit) -> void:
	current_state.handle_event("hit", amount, isCrit)

## Esta función no se utiliza aun, ya que aun no contamos con
## una pool de HP variable.
func notify_healed(amount: int) -> void:
	current_state.handle_event("healed", amount)


func _on_body_animations_animation_finished(anim_name: StringName) -> void:
	current_state._on_animation_finished(anim_name)

func rope_cast_collided(collider):
	current_state._on_rope_cast_collided(collider)
