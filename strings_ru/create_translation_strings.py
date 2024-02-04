import json, os
from pathlib import Path

lang = "ru"
m_strings = dict()
m_strings_en = dict()

def load_strings(file: str, d : dict):
	loaded = 0
	print(f"[+] Loading: {file}")
	
	with open(file, mode="r", encoding="utf-8") as f_str:
		for line in f_str.readlines():
			if line.startswith(";"):
				continue
			# print(f"[+] Line: {line}")
			parts = line[:-1].split("|")
			if parts[0] in d and d[parts[0]][2] != parts[3]:
				print(f"[!] duplicate: {parts[0]} [{d[parts[0]][2]} -> {parts[3]}]")
			d[parts[0]] = [ parts[1], parts[2], parts[3] ]
			loaded += 1
	print(f"[+] Loaded {loaded} strings: {file}")
	

def save_strings(file: str, d : dict):
	global lang
	saved = 0
	# print(f"[+] Loading: {file}")
	
	with open(file, mode="w", encoding="utf-8") as f_str:
		f_str.write(f";meta[language={lang}]\n")
		f_str.write(f"; id      |key(hex)|key(str)| text\n")

		for id in d:
			f_str.write(f"{id}|{d[id][0]}|{d[id][1]}|{d[id][2]}\n")
			saved += 1
	print(f"[+] Saved {saved} strings: {file}")
	
def main():
	if os.path.exists(f"all.{lang}.strings.csv"):
		os.remove(f"all.{lang}.strings.csv")
        
	load_strings("../strings/all.en.strings.csv", m_strings_en)
	for f in Path(".").rglob("*.csv"):
		load_strings(str(f), m_strings)
	
	for id in list(m_strings_en.keys()):
		if id not in m_strings:
			print(f"[-] missed translation: {id} [{m_strings_en[id][2]}]")
			continue
		m_strings_en[id][2] = m_strings[id][2]
	
	save_strings(f"all.{lang}.strings.csv", m_strings_en)

main()
input("DONE!")