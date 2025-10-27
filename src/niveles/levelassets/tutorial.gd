# Tutorial_Trigger.gd

extends Area2D

# -----------------
# 1. PROPIEDADES EXPORTADAS (Editable en el Inspector)
# -----------------

# La ruta al Label que es hijo directo de este Area2D. 
# Asegúrate que 'Label' sea el nombre correcto de tu nodo de texto hijo.
@onready var label_instruccion: Label = $Label 

# Permite definir el mensaje único para cada trigger en el editor.
@export var mensaje_tutorial: String = "Instrucción de Tutorial (¡Cambia este texto!)." 

# Duración en segundos que el mensaje estará visible.
@export var duracion_mensaje: float = 4.0

# -----------------
# 2. LÓGICA DE ACTIVACIÓN
# -----------------

# Bandera para asegurar que el mensaje solo se active una vez por trigger.
var activado_una_vez: bool = false


func _ready():
	# Aseguramos que el Label esté oculto al iniciar.
	label_instruccion.hide()


# ¡IMPORTANTE!: Esta función debe estar conectada a la señal 'body_entered' del Area2D.
func _on_body_entered(body: Node2D): 
	
	# 1. Si ya se activó, salimos inmediatamente.
	if activado_una_vez:
		return

	# 2. Verificación del Jugador (Asegúrate que tu jugador esté en el grupo "player").
	if body.is_in_group("player"):
		activar_instruccion()


# -----------------
# 3. LÓGICA DE VISUALIZACIÓN
# -----------------

func activar_instruccion():
	# 1. Marcar como activado.
	activado_una_vez = true
	
	# 2. Actualizar el texto y mostrar el Label en el nivel.
	label_instruccion.text = mensaje_tutorial
	label_instruccion.show()
	
	# 3. Esperar la duración especificada.
	# El 'await' detiene la función aquí hasta que el temporizador finalice.
	await get_tree().create_timer(duracion_mensaje).timeout
	
	# 4. Ocultar la instrucción.
	label_instruccion.hide()
	
	# 5. Desactivar el Area2D para prevenir detecciones futuras.
	monitoring = false
