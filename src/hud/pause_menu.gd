extends CanvasLayer

# Referencias a los nodos
@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var confirm_dialog = $ConfirmDialog

func _ready():
	# Hacemos que la pausa funcione INCLUSO si el juego está pausado (process_mode)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Conectar botones
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Conectar la señal 'confirmed' del diálogo
	confirm_dialog.confirmed.connect(_on_confirm_quit)

# Función para reanudar el juego
func _on_resume_pressed():
	# Le pedimos al SaveManager que reanude el juego
	SaveManager.unpause_game()

# Función para el botón "Salir al Menú"
func _on_quit_pressed():
	# En lugar de salir directamente, mostramos el pop-up de confirmación
	confirm_dialog.popup_centered()

# Esta función se llama SOLO si el jugador presiona "Aceptar" en el pop-up
func _on_confirm_quit():
	# Le pedimos al SaveManager que maneje la salida al menú
	SaveManager.quit_to_menu()
