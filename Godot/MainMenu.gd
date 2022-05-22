extends Control

onready var newGameButton = $VBoxContainer/NewGameButton
onready var howToPlayButton = $VBoxContainer/HowToPlayButton
onready var howToPlayCloseButton = $"../HowToPlayPanel/VBoxContainer/CloseButton"
onready var creditsButton = $VBoxContainer/CreditsButton
onready var creditsCloseButton = $"../CreditsPanel/VBoxContainer/CloseButton"

onready var howToPlayPanel = $"../HowToPlayPanel"
onready var creditsPanel = $"../CreditsPanel"

signal new_game

func _ready():
	newGameButton.connect("pressed", self, "_new_game")
	howToPlayButton.connect("pressed", self, "_show_how_to_play", [true])
	creditsButton.connect("pressed", self, "_show_credits", [true])

	howToPlayCloseButton.connect("pressed", self, "_show_how_to_play", [false])
	creditsCloseButton.connect("pressed", self, "_show_credits", [false])

	# ensure extra menus are hidden
	howToPlayPanel.hide()
	creditsPanel.hide()

func _new_game():
	emit_signal("new_game")

func _show_how_to_play(shouldShow):
	howToPlayPanel.visible = shouldShow

func _show_credits(shouldShow):
	creditsPanel.visible = shouldShow
