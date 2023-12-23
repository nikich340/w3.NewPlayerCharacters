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

cli_path = "D:/w3.modding/w3.projects/WolvenKit-7/WolvenKit.CLI/bin/Release/net481/WolvenKit.CLI.exe"


# get node by path
def new_guid() -> str:
    return str(uuid.uuid4())


def chunk_count() -> int:
    global data
    return len(data["_chunks"])


def REF(node: dict) -> str:
    return node["_vars"]["_reference"]["_value"]


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


# func to load data from cr2w
def load_cr2w(file_path, overwrite=False, remove_json=True):
    global cli_path
    export_json(file_path, overwrite)
    data = load_json(file_path + ".json")
    if remove_json:
        os.remove(file_path + ".json")
    return data


data = dict()
rep_data = {
    "dialogLine": dict(),
    "cutscene": dict(),
    "chunk": dict(),
    "guid": dict(),
    "elementId": dict(),
    "controlParts": set(),
    "sections": set(),
    "commonChunks": set()
}


def inc_sectionId_counter() -> int:
    global data
    main_vars = data["_chunks"]["CStoryScene #0"]["_vars"]
    new_id = main_vars["sectionIDCounter"]["_value"] + 1
    main_vars["sectionIDCounter"]["_value"] = new_id
    return new_id


def inc_elementId_counter() -> int:
    global data
    main_vars = data["_chunks"]["CStoryScene #0"]["_vars"]
    if "elementIDCounter" in main_vars:
        # main_vars["elementIDCounter"]["_value"] = 0
        new_id = main_vars["elementIDCounter"]["_value"] + 1
        main_vars["elementIDCounter"]["_value"] = new_id
        return new_id
    else:
        return -1


def is_section(type) -> bool:
    return type in {
        "CStorySceneSection",
        "CStorySceneCutsceneSection",
        "CStorySceneVideoSection",
        "CStorySceneScript",
        "CStorySceneFlowCondition",
        "CStorySceneFlowSwitch",
        "CStorySceneLinkHub",
        "CStorySceneRandomizer",
        "CStorySceneScript",
        "CStorySceneInput",
        "CStorySceneOutput",
        "CStorySceneControlPart"
    }


def requires_patching(type) -> bool:
    return type in {
        # sections
        "CStorySceneSection",
        "CStorySceneCutsceneSection",
        "CStorySceneVideoSection",
        "CStorySceneScript",
        "CStorySceneFlowCondition",
        "CStorySceneFlowSwitch",
        "CStorySceneLinkHub",
        "CStorySceneRandomizer",
        "CStorySceneScript",
        "CStorySceneControlPart",
        # elements
        "CStorySceneElement",
        "CStorySceneBlockingElement",
        "CStorySceneChoice",
        "CStorySceneComment",
        "CStorySceneCutscenePlayer",
        "CStorySceneLine",
        "CStoryScenePauseElement",
        "CStorySceneQuestChoiceLine",
        "CStorySceneScriptLine",
        "CStorySceneSectionVariantElementInfo",
        "CStorySceneVideoElement",
        "CStorySceneLinkElement",
        "CStorySceneChoiceLine",
        # specific
        "CStorySceneEventInfo",
        "CStorySceneSectionVariant",
        "CQuestFactsDBCondition"
        # "CStorySceneInput",
        # "CStorySceneOutput",
    }


def requires_patching2(type) -> bool:
    return type not in {
        # sections
        "CStoryScene",
        "CStorySceneInput",
        "CStorySceneOutput",
        "CStorySceneProp",
        "CStorySceneActor",
        "CStorySceneLight",
        "CStorySceneEffect",
        "CStorySceneGraph",

        "CStorySceneDialogsetInstance",
        "CStorySceneDialogsetSlot",
        "CStorySceneAction",
        "CStorySceneActionMoveTo",
        "CStorySceneActionRotateToPlayer",
        "CStorySceneActionSlide",
        "CStorySceneActionStartWork",
        "CStorySceneActionStopWork",
        "CStorySceneActionTeleport"
    }


def is_element(type) -> bool:
    return type in {
        "CStorySceneElement",
        "CStorySceneBlockingElement",
        "CStorySceneChoice",
        "CStorySceneComment",
        "CStorySceneCutscenePlayer",
        "CStorySceneLine",
        "CStoryScenePauseElement",
        "CStorySceneQuestChoiceLine",
        "CStorySceneScriptLine",
        "CStorySceneSectionVariantElementInfo",
        "CStorySceneVideoElement",
        "CStorySceneLinkElement",
        "CStorySceneChoiceLine"
    }


def requires_elementID(type) -> bool:
    return type in {
        "CStorySceneBlockingElement",
        "CStorySceneChoice",
        "CStorySceneComment",
        "CStorySceneCutscenePlayer",
        "CStorySceneElement",
        "CStorySceneLine",
        "CStoryScenePauseElement",
        "CStorySceneQuestChoiceLine",
        "CStorySceneScriptLine",
        "CStorySceneSectionVariantElementInfo",
        "CStorySceneVideoElement"
    }


def requires_sectionID(type) -> bool:
    return type in {
        "CStorySceneSection",
        "CStorySceneCutsceneSection",
        "CStorySceneVideoSection"
    }


def clone_chunk(key: str) -> str:
    global data, rep_data
    chunk = data["_chunks"][key]
    type = chunk["_type"]
    copy_key = f"{type} #{chunk_count()}"
    data["_chunks"][copy_key] = deepcopy(data["_chunks"][key])
    data["_chunks"][copy_key]["_key"] = copy_key
    rep_data["chunk"][key] = copy_key

    # add to main chunk if needed
    if key in rep_data["controlParts"]:
        data["_chunks"]["CStoryScene #0"]["_vars"]["controlParts"]["_elements"].append({
            "_type": "ptr:CStorySceneControlPart",
            "_vars": {
                "_reference": {
                    "_type": "string",
                    "_value": copy_key
                }
            }
        })
    if key in rep_data["sections"]:
        data["_chunks"]["CStoryScene #0"]["_vars"]["sections"]["_elements"].append({
            "_type": "ptr:CStorySceneSection",
            "_vars": {
                "_reference": {
                    "_type": "string",
                    "_value": copy_key
                }
            }
        })

    # patch parent key
    parentKey = data["_chunks"][copy_key]["_parentKey"]
    if parentKey in rep_data["chunk"]:
        data["_chunks"][copy_key]["_parentKey"] = rep_data["chunk"][parentKey]
    elif parentKey and parentKey not in rep_data["commonChunks"]:
        error(f"clone chunk {key}: can't patch parentKey: {parentKey}")

    return copy_key


def patch_sectionId(oldValue: int):
    # inc_elementId_counter()
    return inc_sectionId_counter()


def patch_elementId(oldValue: str):
    global rep_data

    if oldValue not in rep_data["elementId"]:
        rep_data["elementId"][oldValue] = "nr_" + oldValue
        inc_elementId_counter()

    return rep_data["elementId"][oldValue]


def patch_sectionName(oldValue: str):
    return "nr_" + oldValue


def patch_cutscene(oldValue: str):
    global rep_data
    if oldValue in rep_data["cutscene"]:
        rep_data["patched_cs"] += 1
        return rep_data["cutscene"][oldValue]
    else:
        return oldValue


def patch_guid(oldValue: str):
    global rep_data
    if oldValue not in rep_data["guid"]:
        rep_data["guid"][oldValue] = new_guid()

    return rep_data["guid"][oldValue]


def patch_dialogLine(oldValue: int):
    global rep_data
    if oldValue in rep_data["dialogLine"]:
        rep_data["patched_dl"] += 1
        return rep_data["dialogLine"][oldValue]
    else:
        return oldValue


def patch_reference(oldKey: str):
    global rep_data
    newKey = oldKey
    if oldKey in rep_data["chunk"]:
        newKey = rep_data["chunk"][oldKey]
    elif oldKey not in rep_data["commonChunks"]:
        newKey = clone_chunk(oldKey)

    return newKey


def patch_node_DFS(node):
    global data, rep_data

    # it's map
    if "_vars" in node:
        for var_name in node["_vars"]:
            # do stuff here depending on var names
            if var_name == "sectionId":
                node["_vars"]["sectionId"]["_value"] = patch_sectionId(node["_vars"]["sectionId"]["_value"])
            elif var_name == "elementId":
                node["_vars"]["elementId"]["_value"] = patch_elementId(node["_vars"]["elementId"]["_value"])
            elif var_name == "elementID":
                node["_vars"]["elementID"]["_value"] = patch_elementId(node["_vars"]["elementID"]["_value"])
            elif var_name == "sectionName":
                node["_vars"]["sectionName"]["_value"] = patch_sectionName(node["_vars"]["sectionName"]["_value"])
            elif var_name == "cutscene":
                node["_vars"]["cutscene"]["_vars"]["_depotPath"]["_value"] = patch_cutscene(
                    node["_vars"]["cutscene"]["_vars"]["_depotPath"]["_value"])
            elif var_name == "dialogLine":
                node["_vars"]["dialogLine"]["_value"] = patch_dialogLine(node["_vars"]["dialogLine"]["_value"])
            elif var_name == "_reference":
                node["_vars"]["_reference"]["_value"] = patch_reference(node["_vars"]["_reference"]["_value"])
            else:
                patch_node_DFS(node["_vars"][var_name])
    # it's array
    elif "_elements" in node:
        for i, element in enumerate(node["_elements"]):
            patch_node_DFS(element)
    # it's scalar
    else:
        # do stuff depending on type
        type = node["_type"]
        if type == "CGUID":
            node["_value"] = patch_guid(node["_value"])
        return

    return


def patch_chunk_input(inputKey):
    global data, rep_data

    inputChunk = data["_chunks"][inputKey]
    if "nextLinkElement" not in data["_chunks"][inputKey]["_vars"]:
        return

    oldNextKey = REF(inputChunk["_vars"]["nextLinkElement"])
    newNextKey = patch_reference(oldNextKey)

    flowSectionKey = f"CStorySceneFlowCondition #{chunk_count()}"
    data["_chunks"][flowSectionKey] = {
        "_type": "CStorySceneFlowCondition",
        "_key": flowSectionKey,
        "_parentKey": "CStoryScene #0",
        "_flags": 8192,
        "_vars": {
            "linkedElements": {
                "_type": "array:2,0,ptr:CStorySceneLinkElement",
                "_elements": [
                    {
                        "_type": "ptr:CStorySceneLinkElement",
                        "_vars": {
                            "_reference": {
                                "_type": "string",
                                "_value": inputKey
                            }
                        }
                    }
                ]
            },
            "comment": {
                "_type": "String",
                "_value": "[nr_speech_switch >= 1]"
            },
            "trueLink": {
                "_type": "ptr:CStorySceneLinkElement",
                "_vars": {
                    "_reference": {
                        "_type": "string",
                        "_value": newNextKey
                    }
                }
            },
            "falseLink": {
                "_type": "ptr:CStorySceneLinkElement",
                "_vars": {
                    "_reference": {
                        "_type": "string",
                        "_value": oldNextKey
                    }
                }
            },
            "questCondition": {
                "_type": "ptr:IQuestCondition",
                "_vars": {
                    "_reference": {
                        "_type": "string",
                        "_value": "LATER"
                    }
                }
            }
        }
    }

    inputChunk["_vars"]["nextLinkElement"]["_vars"]["_reference"]["_value"] = flowSectionKey
    data["_chunks"][oldNextKey]["_vars"]["linkedElements"]["_elements"][0]["_vars"]["_reference"][
        "_value"] = flowSectionKey
    data["_chunks"][newNextKey]["_vars"]["linkedElements"]["_elements"][0]["_vars"]["_reference"][
        "_value"] = flowSectionKey
    data["_chunks"]["CStoryScene #0"]["_vars"]["controlParts"]["_elements"].append({
        "_type": "ptr:CStorySceneControlPart",
        "_vars": {
            "_reference": {
                "_type": "string",
                "_value": flowSectionKey
            }
        }
    })

    factDbSectionKey = f"CQuestFactsDBCondition #{chunk_count()}"
    data["_chunks"][factDbSectionKey] = {
        "_type": "CQuestFactsDBCondition",
        "_key": factDbSectionKey,
        "_parentKey": flowSectionKey,
        "_flags": 8200,
        "_vars": {
            "factId": {
                "_type": "String",
                "_value": "nr_speech_switch"
            },
            "value": {
                "_type": "Int32",
                "_value": 1
            },
            "compareFunc": {
                "_type": "ECompareFunc",
                "_value": "CF_GreaterEqual"
            }
        }
    }
    data["_chunks"][flowSectionKey]["_vars"]["questCondition"]["_vars"]["_reference"]["_value"] = factDbSectionKey
    return


def main(mods: bool):
    global data, rep_data

    # temp test
    # rep_data["cutscene"]["animations\\cutscenes\\prologue\\q001_beginning\\cs001_griffin\\cs001_griffin.w2cutscene"] = "dlc\\dlcnewreplacers\\data\\cutscenes\\woman_retarget\\113.cs001_griffin.w2cutscene"
    # rep_data["dialogLine"][168702] = 2100005677

    with open("string_geralt_replacements.csv", encoding="utf-8", mode="r") as infile:
        for line in infile.readlines():
            line = line[:-1]
            if line.startswith(";"):
                continue
            parts = line.split("|")
            rep_data["dialogLine"][int(parts[0])] = int(parts[1])

    info(f"Loaded geralt lines: {len(rep_data['dialogLine'])}")

    with open("w2cutscene_replacements.csv", encoding="utf-8", mode="r") as infile:
        for line in infile.readlines():
            line = line[:-1]
            if line.startswith(";"):
                continue
            parts = line.split("|")
            rep_data["cutscene"][parts[0]] = parts[1]

    info(f"Loaded cutscenes: {len(rep_data['cutscene'])}")
    if mods:
        in_folder = "CookedFiles.Mods"  # input("Input folder (scenes): ")
        out_folder = "CookedScenes.Mods.Patched"  # input("Output folder (scenes): ")
    else:
        in_folder = "CCC" # "CookedScenes.Vanilla"  # input("Input folder (scenes): ")
        out_folder = "CCT" # "CookedScenes.Patched"  # input("Output folder (scenes): ")
    scene_files = list(str(x).replace("\\", "/") for x in Path(in_folder).rglob("*.w2scene") if x.is_file())
    print(f"Scene files: {len(scene_files)}")

    log_main = open(f"LogMain_{mods}.txt", mode="w", encoding="utf-8")
    for scene_file in tqdm(scene_files):
        try:
            export_json(scene_file)
            data = load_json(scene_file + ".json")
            vanilla_chunks = list(data['_chunks'])

            # preload some info
            rep_data["chunk"].clear()
            rep_data["guid"].clear()
            rep_data["controlParts"].clear()
            rep_data["sections"].clear()
            rep_data["commonChunks"].clear()
            rep_data["elementId"].clear()
            rep_data["patched_cs"] = 0
            rep_data["patched_dl"] = 0

            story_vars = data["_chunks"]["CStoryScene #0"]["_vars"]
            if "controlParts" in story_vars:
                for controlPart in story_vars["controlParts"]["_elements"]:
                    rep_data["controlParts"].add(REF(controlPart))

            if "sections" in story_vars:
                for section in data["_chunks"]["CStoryScene #0"]["_vars"]["sections"]["_elements"]:
                    rep_data["sections"].add(REF(section))
            for key in vanilla_chunks:
                if not requires_patching2(data["_chunks"][key]["_type"]):
                    info(f"Common chunk: {key}")
                    rep_data["commonChunks"].add(key)

            # create chunks
            for key in vanilla_chunks:
                chunk = data['_chunks'][key]
                type = chunk['_type']

                if requires_patching2(type):
                    # if already cloned
                    new_key = patch_reference(key)
                    info(f"Clone chunk: {key} -> {new_key}")

            # copy and patch chunks and their vars recursively
            for key in vanilla_chunks:
                chunk = data['_chunks'][key]
                type = chunk['_type']

                if requires_patching2(type):
                    # if already cloned
                    new_key = rep_data["chunk"][key]
                    info(f"Patch vars: {key} -> {new_key}")
                    patch_node_DFS(data["_chunks"][new_key])

            # patch input chunks
            for key in vanilla_chunks:
                chunk = data['_chunks'][key]
                type = chunk['_type']
                if type == "CStorySceneInput" and "nextLinkElement" in chunk["_vars"]:
                    info(f"Patch input: {key}")
                    patch_chunk_input(key)

            if rep_data['patched_cs'] > 0 or rep_data['patched_dl'] > 0:
                edited_path = out_folder + "/" + str(Path(scene_file).relative_to(in_folder))
                os.makedirs(os.path.dirname(edited_path), exist_ok=True)
                save_json(data, edited_path + ".json")
                import_json(edited_path + ".json")
                os.remove(edited_path + ".json")
                log_main.write(f"Scene patched: {scene_file} ({rep_data['patched_cs']} cs, {rep_data['patched_dl']} lines)\n")
            else:
                info(f"Scene not require patching: {scene_file}")
                log_main.write(f"Scene not require patching: {scene_file}\n")

        except Exception as e:
            error(f"Exception {e} for scene: {scene_file}")
            log_main.write(f"Exception {e}, for scene: {scene_file}\n")
        log_main.flush()

    log_main.close()


def dump_inputs_test(mods):
    if mods:
        vanilla_folder = "CookedFiles.Mods"  # input("Input folder (scenes): ")
        in_folder = "CookedScenes.Mods.Patched"  # input("Output folder (scenes): ")
    else:
        vanilla_folder = "CookedScenes.Vanilla"  # input("Input folder (scenes): ")
        in_folder = "CookedScenes.Patched"  # input("Output folder (scenes): ")

    scene_files = list(str(x.relative_to(in_folder)).replace("\\", "/") for x in Path(in_folder).rglob("*.w2scene") if x.is_file())
    print(f"Scene files: {len(scene_files)}")

    log_dump = open(f"DumpInputs_{mods}.csv", mode="w", encoding="utf-8")
    log_dump.write(f"scene_path;has_cutscene;input_1|input_2|...|input_N\n")

    num = 0
    inputs = set()

    for scene_path in tqdm(scene_files):
        inputs.clear()
        data = load_json(f"{vanilla_folder}/{scene_path}.json")
        has_cs = False
        for key in data["_chunks"]:
            chunk = data["_chunks"][key]
            chunk_vars = data["_chunks"][key]["_vars"]
            if chunk["_type"] == "CStorySceneInput" and "nextLinkElement" in chunk_vars:
                inputs.add(chunk_vars["inputName"]["_value"] if "inputName" in chunk_vars else "Input")
            elif chunk["_type"] == "CStorySceneCutsceneSection":
                has_cs = True

        log_dump.write(f"{scene_path};{1 if has_cs else 0};")
        log_dump.write("|".join(inputs))
        log_dump.write(f"\n")
        log_dump.flush()
        num += 1

main(mods=False)
# dump_inputs_test(mods=True)
