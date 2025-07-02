extends Node

@onready var press_button_audio: AudioStreamPlayer = $PressButtonAudio
@onready var put_crown_audio: AudioStreamPlayer = $PutCrownAudio
@onready var quit_crown_audio: AudioStreamPlayer = $QuitCrownAudio


func play_button_sound():
	press_button_audio.stop()
	press_button_audio.play()

func play_put_crown_sound():
	put_crown_audio.stop()
	put_crown_audio.play()
	
func play_quit_crown_sound():
	quit_crown_audio.stop()
	quit_crown_audio.play()
