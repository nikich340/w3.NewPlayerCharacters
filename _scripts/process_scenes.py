import pathlib
import uuid
from pathlib import Path
from pprint import pprint
from tqdm import tqdm
import os
import json
import subprocess
from queue import Queue
from copy import deepcopy
from shutil import copy2

cli_path = "C:/w3.modding/GIT_FUZZO_WolvenKit-7_NGE/WolvenKit.CLI/bin/Release/net481/WolvenKit.CLI.exe"


# get node by path
def get_node(node: dict, path: list):
    if not path:
        return node

    v = path[0]
    if "_chunks" in node:
        if v in node["_chunks"]:
            return get_node(node["_chunks"][v], path[1:])
        else:
            print(f"[get_node] ERROR: no chunk {v} found (path = {path})")
            return None
    elif "_elements" in node:
        if isinstance(v, str):
            for element in node["_elements"]:
                if "_vars" in element and "_variant" in element["_vars"] and element["_vars"]["_name"]["_value"] == v:
                    return get_node(element["_vars"]["_variant"], path[1:])
            print(f"[get_node] ERROR: no array var {v} found (path = {path})")
            return None
        else:
            if len(node["_elements"]) > v:
                return get_node(node["_elements"][v], path[1:])
            else:
                print(f"[get_node] ERROR: no array element #{v} found (path = {path})")
                return None
    elif "_vars" in node:
        if v in node["_vars"]:
            return get_node(node["_vars"][v], path[1:])
        else:
            print(f"[get_node] ERROR: no var {v} found (path = {path})")
            return None
    else:
        print(f"[get_node] ERROR: UNKNOWN NODE TYPE: no var {v} found (path = {path}, node = {node})")
        return None


def info(msg: str):
    print(f"[+] {msg}")


def warning(msg: str):
    print(f"[*] {msg}")


def error(msg: str):
    print(f"[!] ERROR: {msg}")


# func to export json from cr2w
def export_json(file_path, overwrite=False):
    global cli_path
    if not overwrite and os.path.exists(file_path + ".json"):
        # info(f"Skip exporting json: {file_path}")
        return

    # info(f"Exporting json: {file_path}")
    args = [cli_path, "--cr2w2json", "--guids_as_strings", f"--input={file_path}"]
    p = subprocess.Popen(args, stdout=subprocess.DEVNULL)
    p.wait()


# func to load json file
def load_json(file_path) -> dict:
    info(f"Loading json: {file_path}")
    with open(file_path, "r", encoding='utf-8') as infile:
        data = json.load(infile)
    return data


# func to save json
def save_json(data, file_path):
    # info(f"Save json: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, ensure_ascii=False, indent=4)


# func to import json to cr2w
def import_json(file_path):
    global cli_path
    info(f"Importing json to cr2w: {file_path}")
    args = [cli_path, "--json2cr2w", "--guids_as_strings", f"--input={file_path}"]
    p = subprocess.Popen(args, stdout=subprocess.DEVNULL)
    p.wait()


# shared vars
visited_keys = set()
chunk_count = 0
changes_required = False
cs_to_cs_copy = dict()
loc_geralt_lines = dict()
data = dict()


def dfs_patch(parent_key, key):
    global data, chunk_count, changes_required, loc_geralt_lines, cs_to_cs_copy, visited_keys
    if key in visited_keys:
        return

    visited_keys.add(key)
    chunk_data = data["_chunks"][key]
    chunk_type = chunk_data["_type"]
    if chunk_type in {"CStorySceneInput", "CStorySceneOutput"}:
        # info(f"DFS: reached INPUT/OUTPUT, returning")
        return

    q = Queue(maxsize=0)
    for var_name in chunk_data["_vars"]:
        q.put([var_name, chunk_data["_vars"][var_name]])

    while not q.empty():
        node_name, node = q.get()
        if node is None:
            continue
        node_type = node['_type'] if '_type' in node else ''
        # info(f"DFS: chunk = {key}, type = {node_type}")
        if "_elements" in node:
            for i, a in enumerate(node["_elements"]):
                q.put([f"{node_name}/{i}", a])
        elif "_vars" in node:
            for v in node["_vars"]:
                q.put([v, node["_vars"][v]])
        elif "_value" in node:
            node_value = node['_value']

            if node_name == "_depotPath" and node_value.endswith(".w2cutscene"):
                if node_value in cs_to_cs_copy:
                    info(f"Cutscene patched: {node_value} -> {cs_to_cs_copy[node_value]}")
                    node['_value'] = cs_to_cs_copy[node_value]
                    changes_required = True
            elif node_type == "LocalizedString":
                if node_value in loc_geralt_lines:
                    changes_required = True
                    info(f"LocalizedString patched: {node_value} -> {loc_geralt_lines[node_value]}")
                    node['_value'] = loc_geralt_lines[node_value]
            elif node_type == "string":
                if node_value in data["_chunks"] and node_value != parent_key:
                    dfs_patch(key, node_value)
        else:
            print(f"Queue: UNKNOWN NODE TYPE: {node_type}, node = {node}")

    return


def main():
    global cli_path, data, chunk_count, changes_required, loc_geralt_lines, cs_to_cs_copy, visited_keys
    if not os.path.exists(cli_path):
        cli_path = input("CLI path: ")

    with open("string_en_geralt.csv", encoding="utf-8", mode="r") as infile:
        for line in infile.readlines():
            if line.startswith(";"):
                continue
            line = line[:-1]
            id = int(line[:10])
            new_id = 2100000000 + len(loc_geralt_lines) + 1
            loc_geralt_lines[id] = new_id

    with open("string_geralt_replacements.csv", encoding="utf-8", mode="w") as outfile:
        for id in loc_geralt_lines:
            str_id = str(id)
            while len(str_id) < 10:
                str_id = "0" + str_id
            str_id2 = str(loc_geralt_lines[id])
            while len(str_id2) < 10:
                str_id2 = "0" + str_id2
            outfile.write(f"{str_id}|{str_id2}\n")

    info(f"Loaded geralt lines: {len(loc_geralt_lines)}")

    with open("w2cutscene_replacements.csv", encoding="utf-8", mode="r") as infile:
        for line in infile.readlines():
            line = line[:-1]
            if line.startswith(";"):
                continue
            parts = line.split("|")
            cs_to_cs_copy[parts[0]] = parts[1]

    info(f"Loaded cutscenes: {len(cs_to_cs_copy)}")

    dir = input("Input dir (Cooked): ")
    edited_dir = input("Output dir (Cooked.Final): ")
    w2scene_paths = list(x for x in Path(dir).rglob("*.w2scene") if x.is_file())
    w2scene_edited_paths = list()

    # input_names = dict()
    for w2scene_path in tqdm(w2scene_paths):
        data.clear()
        visited_keys.clear()
        chunk_count = 0
        changes_required = False
        inputs = dict()
        scene_name = str(w2scene_path).split("\\")[-1]

        vanilla_path = str(w2scene_path.relative_to(dir)).replace("\\", "/")
        # input_names[vanilla_path] = []

        export_json(str(w2scene_path))
        data = load_json(str(w2scene_path) + ".json")

        for key in data["_chunks"]:
            chunk_count += 1
            chunk_type = data["_chunks"][key]["_type"]
            # chunks[key] = data["_chunks"][key]
            if chunk_type == "CStorySceneInput":
                inputs[key] = data["_chunks"][key]
                # if "inputName" in data["_chunks"][key]["_vars"]:
                #    input_names[vanilla_path].append(data["_chunks"][key]["_vars"]["inputName"]["_value"])
                # else:
                #    input_names[vanilla_path].append("Input")

        info(f"Scene {scene_name}, {len(data['_chunks'])} chunks, {len(inputs)} inputs")

        copied_chunks = dict()
        # inject flow condition and start dfs copying chunks until Output met
        for inputSectionKey in inputs:
            if "nextLinkElement" not in inputs[inputSectionKey]["_vars"]:
                continue

            nextLinkKey = inputs[inputSectionKey]["_vars"]["nextLinkElement"]["_vars"]["_reference"]["_value"]
            dfs_patch(inputSectionKey, nextLinkKey)

        edited_path = edited_dir + "/" + str(w2scene_path.relative_to(dir))
        if changes_required:
            os.makedirs(os.path.dirname(edited_path), exist_ok=True)
            info(f"Changes required: {edited_path}")
            save_json(data, edited_path + ".json")
            import_json(edited_path + ".json")
            os.remove(edited_path + ".json")
            # w2scene_edited_paths.append(str(w2scene_path.relative_to(dir)))
        else:
            info(f"Changes not required: {edited_path}")

    # save_json(input_names, "w2scene_inputs.json")

    # info(f"Edited w2scenes: {len(w2scene_edited_paths)}")
    # with open("edited_w2scene.csv", encoding="utf-8", mode="w") as outfile:
    #    for path in w2scene_edited_paths:
    #        outfile.write(path + "\n")

def copy_to_dlc():
    dir = input("Input dir (CookedScenes.Output): ")
    edited_dir = input("Output dir (CookedScenes.Final): ")
    w2scene_paths = list(x for x in Path(dir).rglob("*.w2scene") if x.is_file())
    w2scene_num = 0

    with open("w2scene_replacements.csv", encoding="utf-8", mode="w") as outfile:
        for path in tqdm(w2scene_paths):
            w2scene_num += 1
            vanilla_path = str(path.relative_to(dir))
            scene_name = vanilla_path.split("\\")[-1]
            dlc_path = f"dlc\\dlcnewreplacers\\data\\scenes\\female_patched\\{w2scene_num}.{scene_name}"
            os.makedirs(os.path.dirname(edited_dir + "\\" + dlc_path), exist_ok=True)
            copy2(dir + "\\" + vanilla_path, edited_dir + "\\" + dlc_path)
            outfile.write(f"{vanilla_path}|{dlc_path}\n")

    info(f"Copied scenes: {w2scene_num}")

#main()
copy_to_dlc()
