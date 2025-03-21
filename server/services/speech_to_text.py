import speech_recognition as sr
from pydub import AudioSegment

class SpeechToText:
    def __init__(self):
        self.recognizer = sr.Recognizer()
    
    def convert_audio_to_text(self, audio_file):
        """
        Converts speech from an audio file to text.
        :param audio_file: Path to the audio file (.wav or .mp3)
        :return: Transcribed text or error message
        """
        try:
            # Convert MP3 to WAV if needed
            if audio_file.endswith(".mp3"):
                sound = AudioSegment.from_mp3(audio_file)
                audio_file = audio_file.replace(".mp3", ".wav")
                sound.export(audio_file, format="wav")
            
            # Load the audio file
            with sr.AudioFile(audio_file) as source:
                audio_data = self.recognizer.record(source)
                
            # Convert speech to text
            text = self.recognizer.recognize_google(audio_data)
            return text
        
        except sr.UnknownValueError:
            return "Speech Recognition could not understand the audio."
        except sr.RequestError as e:
            return f"Could not request results from Google Speech Recognition service; {e}"
        except Exception as e:
            return f"Error processing audio: {e}"
