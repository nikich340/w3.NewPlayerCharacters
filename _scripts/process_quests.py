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


# shared vars
scene_to_scene_copy = dict()
line_to_line_copy = dict()
data = dict()
graph_data = dict()
mod_key_by_key = dict()
# [key][in/out] = [SBlockDesc vars1 ref, SBlockDesc vars2 ref]
# {"in": list(), "thunder": list()}
graph_visited = set()


def new_guid() -> str:
    return str(uuid.uuid4())


def chunk_count() -> int:
    global data
    return len(data["_chunks"])


def chunk_id(chunk_key) -> int:
    return int(chunk_key.split("#")[-1])


def patch_scene_path(path: str) -> str:
    global scene_to_scene_copy
    path = path.replace("/", "\\")
    if path in scene_to_scene_copy:
        return scene_to_scene_copy[path]
    else:
        return path


def requires_patching(key: str) -> bool:
    global data, scene_to_scene_copy
    if key not in data["_chunks"]:
        return False
    chunk = data["_chunks"][key]
    if chunk["_type"] not in {"CQuestContextDialogBlock", "CQuestSceneBlock", "CQuestInteractionDialogBlock"}:
        return False
    if "scene" in chunk["_vars"]:
        path = chunk["_vars"]["scene"]["_vars"]["_depotPath"]["_value"].replace("/", "\\")
        if path in scene_to_scene_copy:
            return True
    if "targetScene" in chunk["_vars"]:
        path = chunk["_vars"]["targetScene"]["_vars"]["_depotPath"]["_value"].replace("/", "\\")
        if path in scene_to_scene_copy:
            return True

    return False


def Create_SetSceneBlockActive(vanilla_func_key, scene_mod_key, graph_key, graph_path, active) -> dict:
    return {
        "_type": "CQuestScriptBlock",
        "_key": vanilla_func_key,
        "_parentKey": graph_key,
        "_flags": 8192,
        "_vars": {
            "guid": {
                "_type": "CGUID",
                "_value": new_guid()
            },
            "cachedConnections": {
                "_type": "array:2,0,SCachedConnections",
                "_elements": [
                    {
                        "_type": "SCachedConnections",
                        "_vars": {
                            "socketId": {
                                "_type": "CName",
                                "_value": "Out"
                            },
                        }
                    }
                ]
            },
            "functionName": {
                "_type": "CName",
                "_value": "NR_SetSceneBlockActive_Q"
            },
            "parameters": {
                "_type": "array:2,0,QuestScriptParam",
                "_elements": [
                    {
                        "_type": "QuestScriptParam",
                        "_vars": {
                            "name": {
                                "_type": "CName",
                                "_value": "questPath"  # a
                            },
                            "value": {
                                "_type": "CVariant",
                                "_vars": {
                                    "_variant": {
                                        "_type": "CName",  # b
                                        "_value": graph_path  # c
                                    },
                                    "_name": {
                                        "_type": "string",
                                        "_value": "value"
                                    }
                                }
                            }
                        }
                    },
                    {
                        "_type": "QuestScriptParam",
                        "_vars": {
                            "name": {
                                "_type": "CName",
                                "_value": "sceneBlockId"  # a
                            },
                            "value": {
                                "_type": "CVariant",
                                "_vars": {
                                    "_variant": {
                                        "_type": "Int32",  # b
                                        "_value": chunk_id(scene_mod_key)  # c
                                    },
                                    "_name": {
                                        "_type": "string",
                                        "_value": "value"
                                    }
                                }
                            }
                        }
                    },
                    {
                        "_type": "QuestScriptParam",
                        "_vars": {
                            "name": {
                                "_type": "CName",
                                "_value": "active"  # a
                            },
                            "value": {
                                "_type": "CVariant",
                                "_vars": {
                                    "_variant": {
                                        "_type": "Bool",  # b
                                        "_value": active  # c
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
            "caption": {
                "_type": "String",
                "_value": "Script [NR_SetSceneBlockActive_Q]"
            },
            "BufferParameters": {
                "_type": "CCompressedBuffer:CVariant",
                "_elements": [
                    {
                        "_type": "CVariant",
                        "_vars": {
                            "_variant": {
                                "_type": "CName",
                                "_value": graph_path
                            },
                            "_name": {
                                "_type": "string",
                                "_value": "questPath"
                            }
                        }
                    },
                    {
                        "_type": "CVariant",
                        "_vars": {
                            "_variant": {
                                "_type": "Int32",
                                "_value": chunk_id(scene_mod_key)
                            },
                            "_name": {
                                "_type": "string",
                                "_value": "sceneBlockId"
                            }
                        }
                    },
                    {
                        "_type": "CVariant",
                        "_vars": {
                            "_variant": {
                                "_type": "Bool",
                                "_value": active
                            },
                            "_name": {
                                "_type": "string",
                                "_value": "active"
                            }
                        }
                    }
                ]
            }
        }
    }


def Create_IsSceneBlockActive(func_key, scene_mod_key, on_false_CutControl_key, on_true_CutControl_key, graph_key, graph_path) -> dict:
    return {
        "_type": "CQuestScriptBlock",
        "_key": func_key,
        "_parentKey": graph_key,
        "_flags": 8192,
        "_vars": {
            "guid": {
                "_type": "CGUID",
                "_value": new_guid()
            },
            "cachedConnections": {
                "_type": "array:2,0,SCachedConnections",
                "_elements": [
                    {
                        "_type": "SCachedConnections",
                        "_vars": {
                            "socketId": {
                                "_type": "CName",
                                "_value": "False"
                            },
                            "blocks": {
                                "_type": "array:2,0,SBlockDesc",
                                "_elements": [
                                    {
                                        "_type": "SBlockDesc",
                                        "_vars": {
                                            "ock": {
                                                "_type": "ptr:CQuestGraphBlock",
                                                "_vars": {
                                                    "_reference": {
                                                        "_type": "string",
                                                        "_value": on_false_CutControl_key
                                                    }
                                                }
                                            },
                                            "putName": {
                                                "_type": "CName",
                                                "_value": "In"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    },
                    {
                        "_type": "SCachedConnections",
                        "_vars": {
                            "socketId": {
                                "_type": "CName",
                                "_value": "True"
                            },
                            "blocks": {
                                "_type": "array:2,0,SBlockDesc",
                                "_elements": [
                                    {
                                        "_type": "SBlockDesc",
                                        "_vars": {
                                            "ock": {
                                                "_type": "ptr:CQuestGraphBlock",
                                                "_vars": {
                                                    "_reference": {
                                                        "_type": "string",
                                                        "_value": on_true_CutControl_key
                                                    }
                                                }
                                            },
                                            "putName": {
                                                "_type": "CName",
                                                "_value": "In"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    }
                ]
            },
            "functionName": {
                "_type": "CName",
                "_value": "NR_IsSceneBlockActive_Q"
            },
            "parameters": {
                "_type": "array:2,0,QuestScriptParam",
                "_elements": [
                    {
                        "_type": "QuestScriptParam",
                        "_vars": {
                            "name": {
                                "_type": "CName",
                                "_value": "questPath"  # a
                            },
                            "value": {
                                "_type": "CVariant",
                                "_vars": {
                                    "_variant": {
                                        "_type": "CName",  # b
                                        "_value": graph_path  # c
                                    },
                                    "_name": {
                                        "_type": "string",
                                        "_value": "value"
                                    }
                                }
                            }
                        }
                    },
                    {
                        "_type": "QuestScriptParam",
                        "_vars": {
                            "name": {
                                "_type": "CName",
                                "_value": "sceneBlockId"  # a
                            },
                            "value": {
                                "_type": "CVariant",
                                "_vars": {
                                    "_variant": {
                                        "_type": "Int32",  # b
                                        "_value": chunk_id(scene_mod_key)  # c
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
            "choiceOutput": {
                "_type": "Bool",
                "_value": True
            },
            "caption": {
                "_type": "String",
                "_value": "Script [NR_IsSceneBlockActive_Q]"
            },
            "BufferParameters": {
                "_type": "CCompressedBuffer:CVariant",
                "_elements": [
                    {
                        "_type": "CVariant",
                        "_vars": {
                            "_variant": {
                                "_type": "CName",
                                "_value": graph_path
                            },
                            "_name": {
                                "_type": "string",
                                "_value": "questPath"
                            }
                        }
                    },
                    {
                        "_type": "CVariant",
                        "_vars": {
                            "_variant": {
                                "_type": "Int32",
                                "_value": chunk_id(scene_mod_key)
                            },
                            "_name": {
                                "_type": "string",
                                "_value": "sceneBlockId"
                            }
                        }
                    }
                ]
            }
        }
    }


def Create_ConditionBlock(cond_key, graph_key, putName, scene_vanilla_key, scene_mod_key, script_vanilla_key, script_mod_key) -> dict:
    return {
        "_type": "CQuestConditionBlock",
        "_key": cond_key,
        "_parentKey": graph_key,
        "_flags": 8192,
        "_vars": {
            "name": {
                "_type": "String",
                "_value": "nr_speech_switch >= 1"
            },
            "guid": {
                "_type": "CGUID",
                "_value": new_guid()
            },
            "cachedConnections": {
                "_type": "array:2,0,SCachedConnections",
                "_elements": [
                    {
                        "_type": "SCachedConnections",
                        "_vars": {
                            "socketId": {
                                "_type": "CName",
                                "_value": "True"
                            },
                            "blocks": {
                                "_type": "array:2,0,SBlockDesc",
                                "_elements": [
                                    {
                                        "_type": "SBlockDesc",
                                        "_vars": {
                                            "ock": {
                                                "_type": "ptr:CQuestGraphBlock",
                                                "_vars": {
                                                    "_reference": {
                                                        "_type": "string",
                                                        "_value": scene_mod_key
                                                    }
                                                }
                                            },
                                            "putName": {
                                                "_type": "CName",
                                                "_value": putName
                                            }
                                        }
                                    },
                                    {
                                        "_type": "SBlockDesc",
                                        "_vars": {
                                            "ock": {
                                                "_type": "ptr:CQuestGraphBlock",
                                                "_vars": {
                                                    "_reference": {
                                                        "_type": "string",
                                                        "_value": script_mod_key
                                                    }
                                                }
                                            },
                                            "putName": {
                                                "_type": "CName",
                                                "_value": "In"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    },
                    {
                        "_type": "SCachedConnections",
                        "_vars": {
                            "socketId": {
                                "_type": "CName",
                                "_value": "False"
                            },
                            "blocks": {
                                "_type": "array:2,0,SBlockDesc",
                                "_elements": [
                                    {
                                        "_type": "SBlockDesc",
                                        "_vars": {
                                            "ock": {
                                                "_type": "ptr:CQuestGraphBlock",
                                                "_vars": {
                                                    "_reference": {
                                                        "_type": "string",
                                                        "_value": scene_vanilla_key
                                                    }
                                                }
                                            },
                                            "putName": {
                                                "_type": "CName",
                                                "_value": putName
                                            }
                                        }
                                    },
                                    {
                                        "_type": "SBlockDesc",
                                        "_vars": {
                                            "ock": {
                                                "_type": "ptr:CQuestGraphBlock",
                                                "_vars": {
                                                    "_reference": {
                                                        "_type": "string",
                                                        "_value": script_vanilla_key
                                                    }
                                                }
                                            },
                                            "putName": {
                                                "_type": "CName",
                                                "_value": "In"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    }
                ]
            },
            "questCondition": {
                "_type": "ptr:IQuestCondition",
                "_vars": {
                    "_reference": {
                        "_type": "string",
                        "_value": str()
                    }
                }
            }
        }
    }


def Create_GraphDataIn(key, putName) -> dict:
    return {
        "ock": {
            "_type": "ptr:CQuestGraphBlock",
            "_vars": {
                "_reference": {
                    "_type": "string",
                    "_value": key
                }
            }
        },
        "putName": {
            "_type": "CName",
            "_value": putName
        }
    }


def Add_GraphBlock(block_key, graph_key):
    global data
    data["_chunks"][graph_key]["_vars"]["graphBlocks"]["_elements"].append(
        {
            "_type": "ptr:CGraphBlock",
            "_vars": {
                "_reference": {
                    "_type": "string",
                    "_value": block_key
                }
            }
        }
    )


def build_quest_graph(block_key: str):
    global data, graph_data, graph_visited
    if block_key in graph_visited:
        return
    graph_visited.add(block_key)
    block_type = data["_chunks"][block_key]["_type"]
    block_vars = data["_chunks"][block_key]["_vars"]
    if "cachedConnections" not in block_vars:
        return
    for out_ref in block_vars["cachedConnections"]["_elements"]:
        if "blocks" not in out_ref["_vars"]:
            continue
        socketId = out_ref["_vars"]["socketId"]["_value"] if "socketId" in out_ref["_vars"] else ""
        # if block_type == "CQuestCutControlBlock" and socketId == "Thunder":
        #    info(f"CUT CONTROL Thunder: {block_key}!")

        for out_block_ref in out_ref["_vars"]["blocks"]["_elements"]:
            if "ock" not in out_block_ref["_vars"]:
                continue
            out_block_key = out_block_ref["_vars"]["ock"]["_vars"]["_reference"]["_value"]
            if out_block_key not in data["_chunks"]:
                error(f"Invalid out key: {out_block_key}")
                continue
            out_block_type = data["_chunks"][out_block_key]["_type"]
            if block_type == "CQuestCutControlBlock" and socketId == "Thunder":
                graph_data[out_block_key]["thunder"].append(
                    {
                        "key": block_key,
                        # "elements": out_ref["_vars"]["blocks"]["_elements"],
                        # "block": out_block_ref
                    }
                )
            else:
                graph_data[out_block_key]["in"].append(out_block_ref["_vars"])


def handle_scene_chunk(scene_key, graph_key, quest_path):
    global data, graph_data, graph_visited, mod_key_by_key
    cond_key_by_inputName = dict()
    scene_type = data["_chunks"][scene_key]["_type"]

    # Copy scene block
    scene_copy_key = f"{scene_type} #{chunk_count()}"
    info(f"Patch chunk {scene_key} -> {scene_copy_key}")
    data["_chunks"][scene_copy_key] = deepcopy(data["_chunks"][scene_key])
    data["_chunks"][scene_copy_key]["_vars"]["guid"]["_value"] = new_guid()
    Add_GraphBlock(scene_copy_key, graph_key)
    graph_data[scene_copy_key] = {"in": list(), "thunder": list()}
    graph_visited.add(scene_copy_key)
    mod_key_by_key[scene_key] = scene_copy_key

    # Patch scene paths in mod scene block
    scene_copy_vars = data["_chunks"][scene_copy_key]["_vars"]
    if "scene" in scene_copy_vars:
        scene_copy_vars["scene"]["_vars"]["_depotPath"]["_value"] = patch_scene_path(
            scene_copy_vars["scene"]["_vars"]["_depotPath"]["_value"])
    if "targetScene" in scene_copy_vars:
        scene_copy_vars["targetScene"]["_vars"]["_depotPath"]["_value"] = patch_scene_path(
            scene_copy_vars["targetScene"]["_vars"]["_depotPath"]["_value"])

    # Add script blocks to mark active scene (vanilla or modded)
    vanilla_func_key = f"CQuestScriptBlock #{chunk_count()}"
    data["_chunks"][vanilla_func_key] = Create_SetSceneBlockActive(vanilla_func_key, scene_copy_key, graph_key, quest_path, False)
    graph_data[vanilla_func_key] = {"in": list(), "thunder": list()}
    graph_visited.add(vanilla_func_key)
    Add_GraphBlock(vanilla_func_key, graph_key)

    mod_func_key = f"CQuestScriptBlock #{chunk_count()}"
    data["_chunks"][mod_func_key] = Create_SetSceneBlockActive(mod_func_key, scene_copy_key, graph_key, quest_path, True)
    graph_data[mod_func_key] = {"in": list(), "thunder": list()}
    graph_visited.add(mod_func_key)
    Add_GraphBlock(mod_func_key, graph_key)

    # 3. setup condition + factdb chunk for every unic inputName and connect inputs to it
    # + add to graphBlocks + change graph
    updated_scene_ins = list()
    for in_ref in graph_data[scene_key]["in"]:
        putName = in_ref["putName"]["_value"]
        if putName not in cond_key_by_inputName:
            cond_key = f"CQuestConditionBlock #{chunk_count()}"
            data["_chunks"][cond_key] = Create_ConditionBlock(cond_key, graph_key, putName, scene_key, scene_copy_key,
                                                              vanilla_func_key, mod_func_key)
            Add_GraphBlock(cond_key, graph_key)

            factdb_key = f"CQuestFactsDBCondition #{chunk_count()}"
            data["_chunks"][factdb_key] = {
                "_type": "CQuestFactsDBCondition",
                "_key": factdb_key,
                "_parentKey": cond_key,
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
            data["_chunks"][cond_key]["_vars"]["questCondition"]["_vars"]["_reference"]["_value"] = factdb_key
            graph_data[cond_key] = {"in": list(), "thunder": list()}
            graph_visited.add(cond_key)
            cond_key_by_inputName[putName] = cond_key

        cond_key = cond_key_by_inputName[putName]
        in_ref["ock"]["_vars"]["_reference"]["_value"] = cond_key
        in_ref["putName"]["_value"] = "In"
        graph_data[cond_key]["in"].append(in_ref)
        graph_data[scene_copy_key]["in"].append(Create_GraphDataIn(scene_copy_key, putName))
        updated_scene_ins.append(Create_GraphDataIn(scene_key, putName))
    graph_data[scene_key]["in"] = updated_scene_ins

    # 4. Copy CutControl, patch copied to kill patched scene, reconnect inputs to ScriptBlock
    for thunder in graph_data[scene_key]["thunder"]:
        if thunder["key"] not in mod_key_by_key:
            # Add CutControl copy
            thunder_mod_key = f"CQuestCutControlBlock #{chunk_count()}"
            mod_key_by_key[thunder["key"]] = thunder_mod_key
            data["_chunks"][thunder_mod_key] = deepcopy(data["_chunks"][thunder["key"]])
            data["_chunks"][thunder_mod_key]["_vars"]["guid"]["_value"] = new_guid()
            graph_data[thunder_mod_key] = {"in": list(), "thunder": list()}
            graph_visited.add(thunder_mod_key)
            Add_GraphBlock(thunder_mod_key, graph_key)

            # Add Script checking block
            script_check_key = f"CQuestScriptBlock #{chunk_count()}"
            data["_chunks"][script_check_key] = Create_IsSceneBlockActive(script_check_key, scene_copy_key, thunder["key"], thunder_mod_key, graph_key, quest_path)
            graph_data[script_check_key] = {"in": list(), "thunder": list()}
            graph_visited.add(script_check_key)
            Add_GraphBlock(script_check_key, graph_key)

            # Reconnect blocks: vanilla thunder -> script check
            for thunder_in in graph_data[thunder["key"]]["in"]:
                thunder_in["ock"]["_vars"]["_reference"]["_value"] = script_check_key

            # Update graph data for vanilla and mod thunder
            graph_data[thunder["key"]]["in"] = [Create_GraphDataIn(script_check_key, "In")]
            graph_data[thunder_mod_key]["in"] = [Create_GraphDataIn(script_check_key, "In")]

        # Reconnect block in mod Thunder: scene -> mod scene
        thunder_mod_key = mod_key_by_key[thunder["key"]]
        for socket in data["_chunks"][thunder_mod_key]["_vars"]["cachedConnections"]["_elements"]:
            if "socketId" in socket["_vars"] and "blocks" in socket["_vars"] and socket["_vars"]["socketId"]["_value"] == "Thunder":
                for block in socket["_vars"]["blocks"]["_elements"]:
                    output_block_key = block["_vars"]["ock"]["_vars"]["_reference"]["_value"]
                    if output_block_key != scene_key:
                        continue
                    block["_vars"]["ock"]["_vars"]["_reference"]["_value"] = scene_copy_key
                    info(f"Patching Thunder output: {thunder_mod_key}.")
                    break



# context dumping info
dfs_data = dict()
dfs_visited = set()
graph_info_file = open("CQuestContextDialogBlock_info.txt", encoding="utf-8", mode="w")


def print_graph_to(vanilla_path, key, scene, targetScene):
    global data, graph_info_file, dfs_visited
    parent_key = data["_chunks"][key]["_parentKey"]
    if not parent_key:
        warning(f"No parent key: {key}")
        return

    parent_data = dict()
    children_data = dict()
    block_extras = dict()
    dfs_visited.clear()
    for block_ref in data["_chunks"][parent_key]["_vars"]["graphBlocks"]["_elements"]:
        ref_key = block_ref["_vars"]["_reference"]["_value"]
        if ref_key in data["_chunks"]:
            chunk_type = data["_chunks"][ref_key]["_type"]
            chunk_vars = data["_chunks"][ref_key]["_vars"]

            cond_refs = []
            block_cond_texts = "("
            if "questCondition" in chunk_vars:
                cond_refs.append(chunk_vars["questCondition"]["_vars"]["_reference"]["_value"])
            elif "conditions" in chunk_vars:
                for cond in chunk_vars["conditions"]["_elements"]:
                    cond_refs.append(cond["_vars"]["_reference"]["_value"])
            elif chunk_type == "CQuestFactsDBChangingBlock":
                block_cond_texts += f"Set-fact: {chunk_vars['factID']['_value']} = {chunk_vars['value']['_value']},"
            elif chunk_type == "CQuestScriptBlock":
                block_cond_texts += f"Func: {chunk_vars['functionName']['_value']},"

            for cond_ref in cond_refs:
                if cond_ref in data["_chunks"]:
                    cond_chunk = data["_chunks"][cond_ref]
                    # print(cond_chunk["_vars"])
                    if cond_chunk["_type"] == "CQuestFactsDBCondition":
                        fvalue = cond_chunk["_vars"]["value"]["_value"] if "value" in cond_chunk["_vars"] else 0
                        ffact = 0
                        if "factId" in cond_chunk["_vars"]:
                            ffact = cond_chunk["_vars"]["factId"]["_value"]
                        elif "factID" in cond_chunk["_vars"]:
                            ffact = cond_chunk["_vars"]["factID"]["_value"]
                        fcompare = cond_chunk["_vars"]["compareFunc"]["_value"] if "compareFunc" in cond_chunk[
                            "_vars"] else "CF_Equal"
                        block_cond_texts += f"Fact-cond: {ffact} {CF_nice(fcompare)} {fvalue},"
                    else:
                        block_cond_texts += f"Cond: {cond_ref},"
            block_extras[ref_key] = block_cond_texts + ")"

            if "cachedConnections" in chunk_vars:
                if ref_key not in children_data:
                    children_data[ref_key] = list()
                for connection in chunk_vars["cachedConnections"]["_elements"]:
                    if "blocks" in connection["_vars"]:
                        for connection_block_ref in connection["_vars"]["blocks"]["_elements"]:
                            putName = connection_block_ref["_vars"]["putName"]["_value"] if "putName" in \
                                                                                            connection_block_ref[
                                                                                                "_vars"] else ""
                            if "ock" in connection_block_ref["_vars"]:
                                ock_key = connection_block_ref["_vars"]["ock"]["_vars"]["_reference"]["_value"]
                                if ock_key in data["_chunks"]:
                                    children_data[ref_key].append([f"[{putName}]", ock_key])
                                    if ock_key not in parent_data:
                                        parent_data[ock_key] = list()
                                    parent_data[ock_key].append([f"[{putName}]", ref_key])

    graph_info_file.write(f"[{vanilla_path}: {scene} -> {targetScene}]\n")
    print_graph_to_dfs(parent_data, key, "", block_extras, 0)

    if key and key in children_data:
        for block_data in children_data[key]:
            graph_info_file.write(f"\n V\n ")
            key2 = block_data[1]
            graph_info_file.write(f"{block_data[1]} {block_extras[key2]}")
            if key2 in children_data:
                for block_data2 in children_data[key2]:
                    key3 = block_data2[1]
                    graph_info_file.write(f" → {block_data2[0]} {block_data2[1]} {block_extras[key3]}")
                    if key3 in children_data and len(children_data[key3]) > 0:
                        graph_info_file.write(f" <<")
                        for block_data3 in children_data[key3]:
                            key4 = block_data3[1]
                            graph_info_file.write(f" → {block_data3[0]} {block_data3[1]} {block_extras[key4]}")
                        graph_info_file.write(f">>")
                    graph_info_file.write(";")
    graph_info_file.write(f"\n\n")


def print_graph_to_dfs(parent_data, key, extra, block_extras, offset):
    global graph_info_file, dfs_visited

    dfs_visited.add(key)

    if offset:
        graph_info_file.write(" ← " + extra + " " + key + " " + block_extras[key])
        new_offset = offset + len(" ← " + extra + " " + key + " " + block_extras[key])
    else:
        graph_info_file.write(key)
        new_offset = offset + len(key)

    if key in parent_data:
        for i, parent in enumerate(parent_data[key]):
            if parent[1] in dfs_visited:
                continue

            if i > 0:
                # print(f"i = {i}, key = {key}")
                graph_info_file.write("\n" + " " * (new_offset - len(key)) + key)
            print_graph_to_dfs(parent_data, parent[1], parent[0], block_extras, new_offset)

    # graph_info_file.write("\n")


def main():
    global cli_path, data, line_to_line_copy, scene_to_scene_copy, graph_data, graph_visited, mod_key_by_key
    if not os.path.exists(cli_path):
        cli_path = input("CLI path: ")

    with open("string_geralt_replacements.csv", encoding="utf-8", mode="r") as infile:
        for line in infile.readlines():
            line = line[:-1]
            parts = line.split("|")
            line_to_line_copy[parts[0]] = parts[1]

    info(f"Loaded geralt lines: {len(line_to_line_copy)}")

    with open("w2scene_replacements.csv", encoding="utf-8", mode="r") as infile:
        for line in infile.readlines():
            line = line[:-1]
            if line.startswith(";"):
                continue
            parts = line.split("|")
            scene_to_scene_copy[parts[0]] = parts[1]

    info(f"Loaded scenes: {len(scene_to_scene_copy)}")

    dir = "CookedQuests"  # input("Input dir (CookedQuests): ")
    edited_dir = f"{dir}.Final"  # input("Output dir (CookedQuests.Final): ")
    w2quest_paths = list(x for x in Path(dir).rglob("*") if x.is_file() and x.suffix in {".w2quest", ".w2phase"})
    w2quest_edited_paths = list()

    print(f"Going to process quest files: {len(w2quest_paths)}")
    # input_names = dict()
    for w2quest_path in tqdm(w2quest_paths):
        data.clear()
        graph_data.clear()
        graph_visited.clear()
        mod_key_by_key.clear()
        quest_name = str(w2quest_path).split("\\")[-1]
        scene_chunk_keys = list()

        vanilla_path = str(w2quest_path.relative_to(dir)).replace("/", "\\")
        # input_names[vanilla_path] = []

        export_json(str(w2quest_path))
        data = load_json(str(w2quest_path) + ".json")

        for key in data["_chunks"]:
            # chunk = data["_chunks"][key]
            # if chunk["_type"] == "CQuestCutControlBlock" and "cachedConnections" in chunk["_vars"]:
            #    socketNames = set()
            #    for c in chunk["_vars"]["cachedConnections"]["_elements"]:
            #        if "socketId" in c["_vars"]:
            #            socketNames.add(c["_vars"]["socketId"]["_value"])
            #    info(f"CutControl sockets: {socketNames}")

            graph_data[key] = {"in": list(), "thunder": list()}
            if requires_patching(key):
                scene_chunk_keys.append(key)
            '''
            if chunk_type == "CQuestContextDialogBlock" and "scene" in chunk_vars and "targetScene" in chunk_vars:
                scene = chunk_vars["scene"]["_vars"]["_depotPath"]["_value"]
                targetScene = chunk_vars["targetScene"]["_vars"]["_depotPath"]["_value"]
                if scene in scene_to_scene_copy or targetScene in scene_to_scene_copy:
                    if scene in scene_to_scene_copy:
                        scene = scene_to_scene_copy[scene]
                    if targetScene in scene_to_scene_copy:
                        targetScene = scene_to_scene_copy[targetScene]
                    print_graph_to(vanilla_path, key, scene, targetScene)
            '''
        for key in scene_chunk_keys:
            # print(f"Patch chunk: {key}")
            # graph_data.clear()
            # graph_visited.clear()
            parent_key = data["_chunks"][key]["_parentKey"]
            if not parent_key:
                error(f"parent_key is invalid! {key}")
                continue
            parent_chunk = data["_chunks"][parent_key]
            if parent_chunk["_type"] != "CQuestGraph":
                error(f'parent type ({parent_key}) is invalid: {parent_chunk["_type"]}! {key}')
                continue
            for graph_block_ref in parent_chunk["_vars"]["graphBlocks"]["_elements"]:
                build_quest_graph(graph_block_ref["_vars"]["_reference"]["_value"])
            # print("Quest graph: ")
            # pprint(graph_data)
            handle_scene_chunk(key, parent_key, vanilla_path)

        info(f"Quest {quest_name}: {len(scene_chunk_keys)} scene/interaction/context blocks patched.")

        edited_path = edited_dir + "/" + str(w2quest_path.relative_to(dir))
        if scene_chunk_keys:
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


main()
