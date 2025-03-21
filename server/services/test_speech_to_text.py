from speech_to_text import SpeechToText  # Import the class
import os
import warnings  
warnings.simplefilter("ignore", RuntimeWarning)




# Initialize the SpeechToText instance
stt = SpeechToText()

# Provide the path to your test audio file
audio_path = "test.wav"  # Replace with your actual file

# Check if file exists
if not os.path.exists(audio_path):
    print(f"Error: File '{audio_path}' not found.")
else:
    # Convert speech to text
    text = stt.convert_audio_to_text(audio_path)
    print("Transcribed Text:", text)
