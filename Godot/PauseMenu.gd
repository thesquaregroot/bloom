extends Panel

onready var resumeButton = $VBoxContainer/ResumeButton
onready var howToPlayButton = $VBoxContainer/HowToPlayButton
onready var quitButton = $VBoxContainer/QuitButton

onready var mainMenu = $"../MainMenu"

signal quit_game

func _ready():
	resumeButton.connect("pressed", self, "resume")
	howToPlayButton.connect("pressed", mainMenu, "_show_how_to_play", [true])
	quitButton.connect("pressed", self, "_quit")

func resume():
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	show()

func _quit():
	get_tree().paused = false
	hide()
	emit_signal("quit_game")
