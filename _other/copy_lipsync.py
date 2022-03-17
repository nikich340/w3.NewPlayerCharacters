import os
from pathlib import Path
from shutil import copy2

lipsync_dir = "D:/_w3.tools/_voicelines/EN.lipsync"
wem_list = list(Path("speech.en.wem").rglob("*.wem"))

for wem_path in wem_list:
    id = wem_path.name[:10]
    #while id[0] == "0" and not os.path.exists(f"{lipsync_dir}/{id}.cr2w"):
    #    id = id[1:]

    if os.path.exists(f"{lipsync_dir}/{id}.cr2w"):
        copy2(f"{lipsync_dir}/{id}.cr2w", f"speech.en.wem/{id}.lipsyncanim.cr2w")
    else:
        print(f"Warning! Lipsync not found for id: {id}")

smth = input("\nDONE!")