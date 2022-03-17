import os
from multiprocessing import Pool
from pydub import AudioSegment
from tqdm import tqdm

def worker(filename):
  audio = AudioSegment.from_wav(filename)
  audio_len = len(audio)
  if audio_len < 1000.0:
    extra_silence = AudioSegment.silent(duration=1000.0 - audio_len)
    audio = audio + extra_silence
  new_filename = f"{filename[:-4]}[{(len(audio)/1000.0):.3f}].wav"
  audio.export(new_filename, format = "wav", parameters=["-y", "-vn", "-ac", "1", "-ar", "44100", "-acodec", "pcm_s16le"])
  os.remove(filename)

if __name__ == '__main__':
  converted_count = 0
  convertlist = []
  for filename in os.listdir(os.getcwd() + "/speech.en.wav/"):
    if filename.endswith(".wav"):
      convertlist.append(filename)
      converted_count += 1
  
  with Pool(processes=min(converted_count, os.cpu_count())) as p:
    list(tqdm(p.imap_unordered(worker, convertlist), total=converted_count))
    