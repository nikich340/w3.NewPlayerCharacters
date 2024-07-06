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
VARS = "_vars"
ELEMENTS = "_elements"
REFERENCE = "_reference"
TYPE = "_type"
VALUE = "_value"


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


def get_node_str(node: dict, path: str):
    return get_node(node, path.split("/"))


def info(msg: str):
    print(f"[+] {msg}")


def warning(msg: str):
    print(f"[*] {msg}")


def error(msg: str):
    print(f"[!] ERROR: {msg}")
    exit(0)


# func to export json from cr2w
def export_json(file_path, overwrite=False):
    global cli_path
    if not overwrite and os.path.exists(file_path + ".json"):
        # info(f"Skip exporting json: {file_path}")
        return

    # info(f"Exporting json: {file_path}")
    args = [cli_path, "--cr2w2json", "--guids_as_strings", "--bytes_as_list", f"--input={file_path}"]
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
        json.dump(data, outfile, ensure_ascii=False, indent=2)


# func to import json to cr2w
def import_json(file_path):
    global cli_path
    info(f"Importing json to cr2w: {file_path}")
    args = [cli_path, "--json2cr2w", "--guids_as_strings", "--bytes_as_list", f"--input={file_path}"]
    p = subprocess.Popen(args, stdout=subprocess.DEVNULL)
    p.wait()


# get node by path
def get_node(node: dict, path: list):
    # print(f"get_node: {node['_type']}, path: {path}")
    if not path:
        return node

    v = path[0]
    if node["_type"] == "CR2W":
        return get_node(node["_chunks"][v], path[1:])
    elif "_elements" in node:
        if isinstance(v, str):
            for element in node["_elements"]:
                if "_vars" in element and "_variant" in element["_vars"] and element["_vars"]["_name"]["_value"] == v:
                    return get_node(element["_vars"]["_variant"], path[1:])
        else:
            return get_node(node["_elements"][v], path[1:])
    else:
        return get_node(node["_vars"][v], path[1:])


def CF_nice(CF_str) -> str:
    if CF_str == "CF_Equal":
        return "=="
    elif CF_str == "CF_NotEqual":
        return "!="
    elif CF_str == "CF_Less":
        return "<"
    elif CF_str == "CF_LessEqual":
        return "<="
    elif CF_str == "CF_Greater":
        return ">"
    elif CF_str == "CF_GreaterEqual":
        return ">="
    else:
        return CF_str


def main():
    file = "D:\\w3.modding\\w3.projects\\w3.NEW_REPLACERS\\additional.mod.post-cook\\quests\\part_1\\q304_dandelion.w2phase"  # input("Quest file path: ")
    export_json(file)
    data = load_json(file + ".json")
    keys = list(data["_chunks"])
    for key in keys:
        print(key)
        chunk = data["_chunks"][key]
        if not chunk[TYPE].endswith("Block"):
            continue

        if not "cachedConnections" in chunk[VARS]:
            chunk[VARS]["cachedConnections"] = {
                "_type": "array:2,0,SCachedConnections",
                "_elements": [
                    {
                        "_type": "SCachedConnections",
                        "_vars": {
                            "socketId": {
                                "_type": "CName",
                                "_value": "Out"
                            },
                            "blocks": {
                                "_type": "array:2,0,SBlockDesc",
                                "_elements": []
                            }
                        }
                    }
                ]
            }
        for conn in chunk[VARS]["cachedConnections"][ELEMENTS]:
            if not "socketId" in conn[VARS] or conn[VARS]["socketId"][VALUE] == "Out":
                if "blocks" not in conn[VARS]:
                    conn[VARS]["blocks"] = {
                        "_type": "array:2,0,SBlockDesc",
                        "_elements": []
                    }
                script_key = f"CQuestScriptBlock #{len(data['_chunks'])}"
                info = f"DONE: {key}"
                if "caption" in chunk[VARS]:
                    info += ", " + chunk[VARS]["caption"][VALUE]
                if "name" in chunk[VARS]:
                    info += ", " + chunk[VARS]["name"][VALUE]
                if "comment" in chunk[VARS]:
                    info += ", " + chunk[VARS]["comment"][VALUE]

                conn[VARS]["blocks"][ELEMENTS].append(
                    {
                        "_type": "SBlockDesc",
                        "_vars": {
                            "ock": {
                                "_type": "ptr:CQuestGraphBlock",
                                "_vars": {
                                    "_reference": {
                                        "_type": "string",
                                        "_value": script_key
                                    }
                                }
                            },
                            "putName": {
                                "_type": "CName",
                                "_value": "In"
                            }
                        }
                    }
                )
                parent_key = chunk["_parentKey"]
                data["_chunks"][script_key] = {
                    "_type": "CQuestScriptBlock",
                    "_key": script_key,
                    "_parentKey": parent_key,
                    "_flags": 8192,
                    "_vars": {
                        "comment": {
                            "_type": "String",
                            "_value": info
                        },
                        "guid": {
                            "_type": "CGUID",
                            "_value": str(uuid.uuid4())
                        },
                        "functionName": {
                            "_type": "CName",
                            "_value": "NR_DebugQuestBlock"
                        },
                        "parameters": {
                            "_type": "array:2,0,QuestScriptParam",
                            "_elements": [
                                {
                                    "_type": "QuestScriptParam",
                                    "_vars": {
                                        "name": {
                                            "_type": "CName",
                                            "_value": "info"
                                        },
                                        "value": {
                                            "_type": "CVariant",
                                            "_vars": {
                                                "_variant": {
                                                    "_type": "CName",
                                                    "_value": info
                                                },
                                                "_name": {
                                                    "_type": "string",
                                                    "_value": "value"
                                                }
                                            }
                                        }
                                    }
                                }
                            ]
                        },
                        "BufferParameters": {
                            "_type": "CCompressedBuffer:CVariant",
                            "_elements": [
                                {
                                    "_type": "CVariant",
                                    "_vars": {
                                        "_variant": {
                                            "_type": "CName",
                                            "_value": f"{key} done"
                                        },
                                        "_name": {
                                            "_type": "string",
                                            "_value": "info"
                                        }
                                    }
                                }
                            ]
                        }
                    }
                }
                data["_chunks"][parent_key][VARS]["graphBlocks"][ELEMENTS].append(
                    {
                        "_type": "ptr:CGraphBlock",
                        "_vars": {
                            "_reference": {
                                "_type": "string",
                                "_value": script_key
                            }
                        }
                    }
                )
                break

    save_json(data, file + "_debug.w2phase.json")
    import_json(file + "_debug.w2phase.json")

main()
input("DONE!")
