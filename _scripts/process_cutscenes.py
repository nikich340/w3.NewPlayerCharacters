import json
import pathlib
from pathlib import Path
from tqdm import tqdm
from pyquaternion import Quaternion
from copy import deepcopy
import os


def error(msg):
    print(f"[!] (ERROR) {msg}")


def info(msg):
    print(f"[+] {msg}")


def warning(msg):
    print(f"[*] {msg}")


def load_json(path: str) -> dict:
    if not os.path.exists(path):
        error(f"load_json: file not found: {path}")
        return dict()

    with open(path, mode="r", encoding="utf-8") as file:
        data = json.load(file)
    return data


def save_json(data, path: str):
    dirname = os.path.dirname(path)
    if dirname:
        os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, mode="w", encoding="utf-8") as file:
        json.dump(data, file, sort_keys=False, ensure_ascii=False, indent=2)
    return


def bake_pos(posArray: list, targetFrames: int) -> list:
    res_array = []
    frames = len(posArray)
    if frames > targetFrames:
        error(f"bake_pos: frames = {frames}, targetFrames = {targetFrames}")
        return posArray
    if frames == targetFrames:
        return posArray

    if frames == 1:
        while len(res_array) < targetFrames:
            res_array.append(posArray[0])
        return res_array
    res_array.append(posArray[0])
    part_size = (targetFrames - 1.0) / (frames - 1.0)
    current_part_size = 0.0
    print("blendPos.partSize =", part_size)
    j = 0
    X1, Y1, Z1 = 0.0, 0.0, 0.0
    X2, Y2, Z2 = 0.0, 0.0, 0.0
    for i in range(2, targetFrames, 1):
        current_part_size += 1.0
        if current_part_size > part_size:
            j += 1
            current_part_size -= part_size
        k = current_part_size / part_size
        k = min(1.0, max(0.0, k))
        # [j..j+1]
        X1, Y1, Z1 = float(posArray[j]["x"]), float(posArray[j]["y"]), float(posArray[j]["z"])
        X2, Y2, Z2 = float(posArray[j + 1]["x"]), float(posArray[j + 1]["y"]), float(posArray[j + 1]["z"])
        res_array.append({
            "x": X1 * (1.0 - k) + X2 * k,
            "y": Y1 * (1.0 - k) + Y2 * k,
            "z": Z1 * (1.0 - k) + Z2 * k
        })
    print("blendPos.lastK =", (current_part_size + 1.0) / part_size)
    res_array.append(posArray[-1])
    return res_array


def bake_rot(rotArray: list, targetFrames) -> list:
    res_array = []
    frames = len(rotArray)
    if frames > targetFrames:
        error(f"bake_rot: frames = {frames}, targetFrames = {targetFrames}")
        return rotArray
    if frames == targetFrames:
        return rotArray
    if frames == 1:
        while len(res_array) < targetFrames:
            res_array.append(rotArray[0])
        return res_array
    res_array.append(rotArray[0])
    part_size = (targetFrames - 1.0) / (frames - 1.0)
    current_part_size = 0.0
    j = 0
    X1, Y1, Z1, W1 = 0.0, 0.0, 0.0, 0.0
    X2, Y2, Z2, W2 = 0.0, 0.0, 0.0, 0.0
    for i in range(2, targetFrames, 1):
        current_part_size += 1.0
        if current_part_size > part_size:
            j += 1
            current_part_size -= part_size
        k = current_part_size / part_size
        k = min(1.0, max(0.0, k))
        # [j..j+1]
        X1, Y1, Z1, W1 = float(rotArray[j]["X"]), float(rotArray[j]["Y"]), float(rotArray[j]["Z"]), float(
            rotArray[j]["W"])
        X2, Y2, Z2, W2 = float(rotArray[j + 1]["X"]), float(rotArray[j + 1]["Y"]), float(rotArray[j + 1]["Z"]), float(
            rotArray[j]["W"])
        Q1 = Quaternion(W1, X1, Y1, Z1)
        Q2 = Quaternion(W2, X2, Y2, Z2)
        Q_res = Quaternion.slerp(Q1, Q2, k)
        res_array.append({
            "X": Q_res.x,
            "Y": Q_res.y,
            "Z": Q_res.z,
            "W": Q_res.w
        })
    print("blendRot.lastK = {} (must be around 1.0)".format((current_part_size + 1.0) / part_size))
    res_array.append(rotArray[-1])
    return res_array


def crop_bones_num(bones):
    for bone in bones:
        for type in ["position", "rotation", "scale"]:
            if len(bone[f"{type}Frames"]) > 1:
                bone[f"{type}Frames"] = bone[f"{type}Frames"][:1]
                bone[f"{type}_numFrames"] = 1
                info(f"Really crop {type} in {bone['BoneName']}")


class JsonCutsceneTool(object):
    def __init__(self):
        return

    def merge_cutscene_anims(self, jsons_dir, actor_voicetag_filter, output_file):
        if not os.path.exists(jsons_dir):
            error(f"merge_cutscene_anims: dir not found: {jsons_dir}")
            return

        json_files = list(str(x) for x in Path(jsons_dir).rglob("*.json") if x.is_file())
        final_data = {
            "animations": []
        }
        anim_names = set()
        info(f"merge_cutscene_anims: {len(json_files)} files")
        for j in tqdm(json_files):
            anim_data = load_json(j)
            cs_name = j.split("\\")[-1].split(".w2cutscene")[0]
            info(f"Processing {cs_name}")

            if not "SCutsceneActorDefs" in anim_data:
                error(f"merge_cutscene_anims: {j}: no SCutsceneActorDefs")
                continue
            if not "animations" in anim_data:
                error(f"merge_cutscene_anims: {j}: no animations")
                continue

            actor_name = ""
            actor_names = []
            for actor in anim_data["SCutsceneActorDefs"]["Content"]:
                vtag = ""
                name = ""
                for var in actor["Content"]:
                    if var["Name"] == "name":
                        name = var["val"]
                    if var["Name"] == "voiceTag":
                        vtag = var["Value"]
                if vtag.upper() == actor_voicetag_filter or name.upper() == actor_voicetag_filter:
                    actor_name = name
                    continue
                actor_names.append(name)
            if not actor_name:
                warning(
                    f"merge_cutscene_anims: actor not found with vtag: {actor_voicetag_filter}\n\tactors: {actor_names}")
                continue
            anim_found = False
            for anim in anim_data["animations"]:
                name = anim["animation"]["name"]
                # if "numTracks" in anim["animation"]["animBuffer"] and int(anim["animation"]["animBuffer"]["numTracks"]) > 0:
                #    info(f"numTracks: {name} = {anim['animation']['animBuffer']['numTracks']}")
                if name.startswith(f"{actor_name}:Root"):
                    anim["animation"].pop("motionExtraction")
                    if "parts" in anim["animation"]["animBuffer"]:
                        parts_cnt = len(anim["animation"]["animBuffer"]["parts"])
                        info(f"Adding multipart cs anim {name} ({parts_cnt})")
                        for i, part in enumerate(anim["animation"]["animBuffer"]["parts"]):
                            part_name = name + "+" + str(i) + ":" + cs_name
                            if part_name in anim_names:
                                error(f"Duplicate anim name: {part_name}")
                            anim_names.add(part_name)
                            part_anim = {
                                "animation": {
                                    "name": part_name,
                                    "framesPerSecond": anim["animation"]["framesPerSecond"],
                                    "duration": anim["animation"]["duration"],
                                    "animBuffer": {
                                        "numFrames": part["numFrames"],
                                        "duration": part["duration"],
                                        "dt": part["dt"],
                                        "version": part["version"],
                                        "bones": part["bones"],
                                        # "firstFrame": anim["animation"]["animBuffer"]["firstFrames"][i]
                                    }
                                }
                            }

                            '''
                            for bone in part_anim["animation"]["animBuffer"]["bones"]:
                                if bone["BoneName"] == "r_weapon" and int(bone["position_numFrames"]) + int(bone["rotation_numFrames"]) > 2:
                                    info(f"Has R weapon MOTION: {part_name}")
                                if bone["BoneName"] == "l_weapon" and int(bone["position_numFrames"]) + int(bone["rotation_numFrames"]) > 2:
                                    info(f"Has L weapon MOTION: {part_name}")
                            '''
                            final_data["animations"].append(part_anim)
                    else:
                        info(f"Adding single cs anim {name}")
                        single_name = name + ":" + cs_name
                        anim["animation"]["name"] = single_name
                        if single_name in anim_names:
                            error(f"Duplicate anim name: {single_name}")
                        anim_names.add(single_name)
                        anim["animation"]["animBuffer"].pop("tracks")

                        '''
                        for bone in anim["animation"]["animBuffer"]["bones"]:
                            if bone["BoneName"] == "r_weapon" and int(bone["position_numFrames"]) + int(bone["rotation_numFrames"]) > 2:
                                info(f"Has R weapon MOTION: {single_name}")
                            if bone["BoneName"] == "l_weapon" and int(bone["position_numFrames"]) + int(bone["rotation_numFrames"]) > 2:
                                info(f"Has L weapon MOTION: {single_name}")
                        '''
                        final_data["animations"].append(anim)

        info(f"Merged cs contains {len(final_data['animations'])} anims")
        save_json(final_data, output_file)
        info(f"Merged cs saved to {output_file}")

    def replace_ciri_player(self, jsons_dir, depot_suffix, output_dir):
        if not os.path.exists(jsons_dir):
            error(f"replace_ciri_player: dir not found: {jsons_dir}")
            return

        json_files = list(str(x) for x in Path(jsons_dir).rglob("*.json") if x.is_file())
        final_data = {
            "animations": []
        }
        info(f"replace_ciri_player: {len(json_files)} files")
        for j in json_files:
            info(f"Processing {j}")
            anim_data = load_json(j)
            if not "SCutsceneActorDefs" in anim_data:
                error(f"replace_ciri_player: {j}: no SCutsceneActorDefs")
                continue

            actor_name = ""
            actor_names = []
            ciri_found = False
            for i, actor in enumerate(anim_data["SCutsceneActorDefs"]["Content"]):
                is_ciri = False
                name = ""
                for var in actor["Content"]:
                    if var["Name"] == "name":
                        name = var["val"]
                    elif var["Name"] == "template":
                        if var["DepotPath"].endswith(depot_suffix):
                            is_ciri = True
                            break
                if is_ciri:
                    ciri_found = True
                    info(f"Replacing {name} with GERALT")
                    anim_data["SCutsceneActorDefs"]["Content"][i]["Content"] = [
                        {
                            "val": name,
                            "Name": "name",
                            "Type": "String"
                        },
                        {
                            "Type": "TagList",
                            "Name": "tag",
                            "Content": [
                                {
                                    "Value": "PLAYER",
                                    "Type": "CName"
                                }
                            ]
                        },
                        {
                            "Value": "GERALT",
                            "Name": "voiceTag",
                            "Type": "CName"
                        },
                        {
                            "DepotPath": "dlc\\dlcnewreplacers\\data\\entities\\nr_replacer_sorceress.w2ent",
                            "ClassName": "CEntityTemplate",
                            "Flags": 4,
                            "Name": "template",
                            "Type": "soft:CEntityTemplate"
                        },
                        {
                            "Value": "CAT_Actor",
                            "Name": "type",
                            "Type": "ECutsceneActorType"
                        },
                        {
                            "val": True,
                            "Name": "useMimic",
                            "Type": "Bool"
                        }
                    ]
                    break
            if ciri_found:
                new_path = j.replace(jsons_dir, output_dir)
                info(f"Saving replaced json as {new_path}")
                save_json(anim_data, new_path)
            else:
                warning(f"CIRI player not found in scene!")

    def patch_cutscene_jsons(self, cs_jsons_dir, anims_jsons_dir, actor_voicetag_filter, output_dir):
        if not os.path.exists(cs_jsons_dir):
            error(f"patch_cutscene_jsons: cs dir not found: {cs_jsons_dir}")
            return

        cs_json_files = list(x for x in Path(cs_jsons_dir).rglob("*.json") if x.is_file())
        anims_json_files = list(x for x in Path(anims_jsons_dir).rglob("*.json") if x.is_file())
        retarget_anims = dict()
        edited_cutscene_paths = list()
        data = dict()

        for j in tqdm(anims_json_files):
            data.clear()
            data = load_json(j)
            name = data["animation"]["name"]
            cs_name = name.split(":")[-1]

            anim_name = str()
            anim_num = 0
            if "+" in name:
                anim_name = name.split("+")[0]
                anim_num = int(name.split("+")[1].split(":")[0])
            else:
                anim_name = name.rsplit(":", 1)[0]

            if cs_name not in retarget_anims:
                retarget_anims[cs_name] = dict()
                retarget_anims[cs_name]["anim"] = dict()
            retarget_anims[cs_name]["anim_name"] = anim_name
            retarget_anims[cs_name]["anim"][anim_num] = data["animation"]

        info(f"Loaded {len(retarget_anims)} cs retarget_anims info")

        for j in tqdm(cs_json_files):
            data.clear()
            data = load_json(str(j))
            cs_name = str(j).split("\\")[-1].split(".w2cutscene")[0]
            if cs_name not in retarget_anims:
                info(f"CS not in retarget list: {cs_name}")
                continue

            edited_cutscene_paths.append(str(j.relative_to(cs_jsons_dir)))
            anim_found = False
            for anim in data["animations"]:
                anim_name = anim["animation"]["name"]
                if anim_name == retarget_anims[cs_name]["anim_name"]:
                    if "parts" in anim["animation"]["animBuffer"]:
                        parts_cnt = len(anim["animation"]["animBuffer"]["parts"])
                        if parts_cnt != len(retarget_anims[cs_name]["anim"]):
                            error(f"PARTS mismatch: {parts_cnt} != {len(retarget_anims[cs_name]['anim'])}")
                            continue
                        for ii in range(parts_cnt):
                            anim["animation"]["animBuffer"]["parts"][ii]["bones"] = \
                                retarget_anims[cs_name]["anim"][ii]["animBuffer"]["bones"]
                            num_frames1 = anim["animation"]["animBuffer"]["parts"][ii]["numFrames"]
                            num_frames2 = retarget_anims[cs_name]["anim"][ii]["animBuffer"]["numFrames"]
                            if num_frames1 == 1 and num_frames2 > 1:
                                crop_bones_num(anim["animation"]["animBuffer"]["parts"][ii]["bones"])
                                num_frames2 = 1

                            assert num_frames1 == num_frames2, f"NUM FRAMES mismatch in {cs_name}, {anim_name}, #{ii}: {num_frames1} != {num_frames2}"
                    else:
                        anim["animation"]["animBuffer"]["bones"] = retarget_anims[cs_name]["anim"][0]["animBuffer"][
                            "bones"]
                        num_frames1 = anim["animation"]["animBuffer"]["numFrames"]
                        num_frames2 = retarget_anims[cs_name]["anim"][0]["animBuffer"]["numFrames"]
                        if num_frames1 == 1 and num_frames2 > 1:
                            crop_bones_num(anim["animation"]["animBuffer"]["bones"])
                            num_frames2 = 1

                        assert num_frames1 == num_frames2, f"NUM FRAMES mismatch in {cs_name}, {anim_name}: {num_frames1} != {num_frames2}"

                    if "motionExtraction" in anim["animation"] and anim["animation"]["motionExtraction"] is None:
                        anim["animation"].pop("motionExtraction")
                    data["animations"] = [anim]
                    data["animevents"] = None
                    data["effects"] = None
                    anim_found = True
                    # info(f"Anim patched: {anim_name}")
                    break

            assert anim_found is True, f"CS anim not found in set! {cs_name}"

            save_path = output_dir + "/" + str(j.relative_to(cs_jsons_dir))
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            save_json(data, save_path)

            info(f"CS patched: {cs_name}")

        with open(f"edited_w2cutscene.csv", encoding="utf-8", mode="w") as outfile:
            for path in edited_cutscene_paths:
                outfile.write(str(path) + "\n")
        info(f"CS patched in total: {len(edited_cutscene_paths)}")


def main():
    tool = JsonCutsceneTool()
    # tool.merge_cutscene_anims(jsons_dir="cs_dumped", actor_voicetag_filter="GERALT", output_file="cs_anims_merged5.w2anims.json")
    # tool.move_weapon_bones(input_json="cs503_geralt_departure_weapon_test.w2anims.json", original_json="cs_anims_merged.w2anims.json", output_json="cs503_geralt_departure_weapon_test_OUT.w2anims.json")
    # tool.replace_ciri_player(jsons_dir="cs_dumped", depot_suffix="ciri_player.w2ent", output_dir="cs_dumped_ciri_replaced")
    tool.patch_cutscene_jsons(cs_jsons_dir="cs_dumped", anims_jsons_dir="cs_dumped.retargeted", actor_voicetag_filter="GERALT", output_dir="cs_dumped.patched")


main()
