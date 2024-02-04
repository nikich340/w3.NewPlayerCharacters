import os

os.system("color")
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def main():
    path = input("File path (empty to use all.en.strings.csv): ")
    if not path:
        path = "all.en.strings.csv"
    if not os.path.exists(path):
        print(f"{bcolors.FAIL}ERROR: file not found: {path}{bcolors.ENDC}")
        return

    prefix = input("ID-prefix (211XXXX): ")
    if not prefix:
        prefix = 2115940
    else:
        prefix = int(prefix)
    
    with open(path, mode="r", encoding="utf-8") as f:
        lines = f.readlines()
        used = set()
        for i, line in enumerate(lines):
            if line.startswith(";"):
                continue
            try:
                id = int(line[:10])
            except ValueError:
                print(f"{bcolors.FAIL}ERROR: not numeric id [{line[:10]}] in line #{i} ({line[:-1]}){bcolors.ENDC}")
                continue
            
            if id in used:
                print(f"{bcolors.FAIL}WARNING: duplicated id [{id}] in line #{i} ({line[:-1]}){bcolors.ENDC}")
            used.add(id)
        
        start_id = prefix * 1000
        end_id = prefix * 1000 + 999
        dec = 0
        
        for id in range(start_id, end_id + 1):
            if dec > 9:
                print("", end="\n")
                dec = 0
            
            if id in used:
                print(f"{bcolors.FAIL}{id}{bcolors.ENDC}", end=" ")
            else:
                print(f"{bcolors.OKGREEN}{id}{bcolors.ENDC}", end=" ")
            dec += 1
        print("", end="\n")

main()
input("DONE!")