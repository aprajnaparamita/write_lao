from TTS.utils.synthesizer import Synthesizer

   model_path = "path/to/checkpoint_100000.pth"
   config_path = "path/to/config.json"
   speakers_file_path = "path/to/speakers.pth"

   synthesizer = Synthesizer(model_path, config_path, speakers_file_path, None, None, None)

   # Generate audio
   text = "ເຮົາ"  # Example Lao text
   outputs = synthesizer.tts(text, speaker_idx="Nick", language_name="lo-la")

   # Save to file
   synthesizer.save_wav(outputs, "output.wav")

