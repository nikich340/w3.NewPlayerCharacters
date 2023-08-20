import os
import string

try:
    import ruamel.yaml.scalarstring
    from ruamel import yaml
    from ruamel.yaml import comments, CommentedMap, CommentedSeq
except:
    print(f"Error loading ruamel yml!")
    import yaml
import magic
import xml.etree.ElementTree as XET
import json
import time
import enum
import shutil
from copy import deepcopy
from strenum import StrEnum
from ctypes import c_uint32
import re
from pathlib import Path

# from frozendict import frozendict

m_convert_json = True
m_save_yml = True
m_save_json = True
m_DLC_DATA = "dlc/dlcnewreplacers/data"
m_FOLDER = "D:/w3.modding/w3.projects/w3.NEW_REPLACERS/_pyscripts"


# m_FOLDER = "/storage/emulated/0/Documents/Pydroid3"


# rig category
class EG(enum.IntEnum):
    EG_None = 0
    EG_Male = 1
    EG_Female = 2
    EG_Any = 3


# npc category
class EAN(enum.IntEnum):
    EAN_Unknown = 0
    EAN_VanillaSecondary = 1
    EAN_DLCSecondary = 2
    EAN_VanillaMain = 3
    EAN_DLCMain = 4
    EAN_DLCCustom = 5
    EAN_ArmorSet = 6


# body part category
class ENR(enum.IntEnum):
    ENR_GSlotUnknown = 0
    ENR_GSlotHair = 1
    ENR_GSlotHead = 2
    ENR_GSlotArmor = 3
    ENR_GSlotGloves = 4
    ENR_GSlotPants = 5
    ENR_GSlotBoots = 6

    ENR_RSlotHair = 7
    ENR_RSlotBody = 8
    ENR_RSlotTorso = 9
    ENR_RSlotArms = 10
    ENR_RSlotGloves = 11
    ENR_RSlotDress = 12
    ENR_RSlotLegs = 13
    ENR_RSlotShoes = 14
    ENR_RSlotMisc = 15


# scene selector flags
class SPF(enum.IntEnum):
    ENR_SPDontSaveOnAccept = 1
    ENR_SPForceUnloadAll = 2
    ENR_SPForceUnloadAllExceptHair = 4


class STR(StrEnum):
    BACK = "2115940103"
    DOT = "0001107617"
    CLEAR_SLOT = "2115940104"
    CAT_DLC_Custom = "2115940089"
    CAT_DLC_Main = "2115940090"
    CAT_DLC_Secondary = "2115940091"
    CAT_Vanilla_Main = "2115940092"
    CAT_Vanilla_Secondary = "2115940093"


def uint32(val: int) -> int:
    return c_uint32(val).value


def get_hash(key: str) -> int:
    key_hash = 0
    for c in key:
        key_hash = uint32(key_hash * 31 + ord(c))
    return key_hash


def get_hash_str(key: str) -> str:
    return f"{get_hash(key):x}"


def test_cat(path: str):
    parts = path.split("/")

    if parts[-1].endswith("_body.w2ent") or re.search(
            r"^(b(ody)?\d?)?(t(orso)?\d?)?(w(aist)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(ead)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_",
            parts[-1]) and parts[-1][0] not in ['_', 'i']:
        return True
    else:
        return False


def category(path: str):
    parts = path.split("/")

    if test_cat(path):
        if re.search(
                r"^b(ody)?\d?(t(orso)?\d?)?(w(aist)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_",
                parts[-1]):  # t1,2,3
            return ENR.ENR_RSlotBody
        elif re.search(
                r"^t(orso)?\d?(w(aist)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_",
                parts[-1]):
            return ENR.ENR_RSlotTorso
        elif re.search(
                "^a(rms)?\d?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_",
                parts[-1]):
            return ENR.ENR_RSlotArms
        elif re.search(
                "^l(egs)?\d?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_",
                parts[-1]):
            return ENR.ENR_RSlotLegs
        elif re.search(
                "^d(ress)?\d?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_",
                parts[-1]):
            return ENR.ENR_RSlotDress
        elif re.search("^g(loves)?\d?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotGloves
        elif re.search("^s(hoes)?\d?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotShoes
        elif re.search("^h(ead)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_GSlotHead
        elif re.search("^(c(ap)?)|(hair)\d?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotHair
        elif parts[-1].endswith("_body.w2ent"):
            return ENR.ENR_RSlotBody
        else:
            return ENR.ENR_GSlotUnknown
    elif re.search(
            "^(i\d?_)|(item\d?_)|(hood_)|(knife)|(pendant)|(necklace)|(feather)|(medallion)|(collar_)|(cloak)|(earrings)|(hairpin)|(crown)|(.*mask)|(fur_)|(cord_)",
            parts[-1]):
        return ENR.ENR_RSlotMisc
    # elif parts[-1].endswith("traj.w2ent") or parts[-1].find("trajectories") >= 0 \
    #        or re.search("(monsters)|(animals)|(animations)|(base_entities)|(shops_and_craftsmen)\/", path):
    #    return EAS.ENR_GSlotUnknown
    else:
        # print(f"Unknown type: {path}")
        return ENR.ENR_GSlotUnknown


def category2(path: str):
    if path.startswith("dlc/"):
        if re.search("(main_npc)|(secondary_npc)", path):
            return EAN.EAN_DLCMain
        else:
            # elif re.search("(gameplay)|(characters)|(quest)|(living_world)|(crowd_npc)|(background_npc)|(monsters)|(community_npcs)/", path):
            return EAN.EAN_DLCSecondary
        # else:
        #    print(f"NO DLC CATEGORY: {path}")
        #    return EAN.EAN_Unknown
    else:
        if re.search("(main_npc)|(secondary_npc)", path):
            return EAN.EAN_VanillaMain
        else:
            # elif re.search("(gameplay)|(characters)|(quest)|(cutscenes)|(living_world)|(crowd_npc)|(background_npc)|(monsters)|(community_npcs)/", path):
            return EAN.EAN_VanillaSecondary
        # else:
        #    print(f"NO VANILLA CATEGORY: {path}")
        #    return EAN.EAN_Unknown


def write_localized_names():
    global m_localized_names
    print(f"[*] Loading JSON dump..")
    with open(f"{m_FOLDER}/EntityDump.json", mode="r", encoding="utf-8") as ij:
        data = json.load(ij)

    print(f"[*] Loading w2ent JSON dump..")
    with open(f"{m_FOLDER}/nr_localizedstrings_storage_BASE.w2ent.json", mode="r", encoding="utf-8") as ij:
        w2ent_data = json.load(ij)

    loc_dict = dict()
    for template in data["templates"]:
        t_data = data["templates"][template]
        if t_data["type"] == "ACTOR" and t_data["nameID"] > 0 and t_data["name"] != str(t_data["nameID"]):
            npc_cat = category2(template)
            if t_data["name"] not in loc_dict or npc_cat.value > loc_dict[t_data["name"]][1].value:
                loc_dict[t_data["name"]] = [t_data["nameID"], npc_cat]
            else:
                # print(f'Duplicate id ({t_data["nameID"]}) for {t_data["name"]}')
                pass

    w2ent_vars = w2ent_data["_chunks"]["NR_LocalizedStringStorage #1"]["_vars"]
    w2ent_fcd_vars = w2ent_data["_chunks"]["CEntityTemplate #0"]["_vars"]["flatCompiledData"]["_chunks"]["flatCompiledData::NR_LocalizedStringStorage #0"]["_vars"]
    for str_name in sorted(loc_dict.keys()):
        str_id = loc_dict[str_name][0]
        npc_cat = loc_dict[str_name][1]

        m_localized_names[npc_cat].append(str(str_id))
        w2ent_vars["stringValues"]["_elements"].append({
            "_type": "LocalizedString",
            "_value": str_id
        })
        w2ent_fcd_vars["stringValues"]["_elements"].append({
            "_type": "LocalizedString",
            "_value": str_id
        })

        w2ent_vars["stringIds"]["_elements"].append({
            "_type": "Int32",
            "_value": str_id
        })
        w2ent_fcd_vars["stringIds"]["_elements"].append({
            "_type": "Int32",
            "_value": str_id
        })

    for i in EAN:
        print(f"[*] {i.name}: {len(m_localized_names[i])} unic localized names added.")

    with open(f"{m_FOLDER}/nr_localizedstrings_storage.w2ent.json", mode="w", encoding="utf-8") as f_json:
        json.dump(w2ent_data, f_json, ensure_ascii=False, sort_keys=False, indent=2)

    with open(f"{m_FOLDER}/DEBUG_npc_names.txt", mode="w", encoding="utf-8") as f_txt:
        for name in sorted(loc_dict.keys()):
            f_txt.write(name + "\n")


def pre_filter_templates():
    if m_convert_json:
        print(f"[*] Converting YML->JSON dump..")
        with open(f"{m_FOLDER}/EntityDump.yml", mode="r", encoding="utf-8") as yf:
            start_t = time.time()
            yml = yaml.load(yf, Loader=yaml.RoundTripLoader, preserve_quotes=True)
            end_t = time.time()
            print(f"YML loaded in: {end_t - start_t} s")
            with open(f"{m_FOLDER}/EntityDump.json", mode="w", encoding="utf-8") as jf:
                start_t = time.time()
                json.dump(yml, jf, sort_keys=False, indent=2)
                end_t = time.time()
                print(f"JSON saved in: {end_t - start_t} s")

    print(f"[*] Loading JSON dump..")
    with open(f"{m_FOLDER}/EntityDump.json", mode="r", encoding="utf-8") as ij:
        yml = json.load(ij)

    print(f"YML Loaded")
    l_templatesUseless = []
    m_entity_names = set()
    for template in yml["templates"]:
        friendly_name = template.split("/")[-1][:-6]
        if friendly_name in m_entity_names:
            print(f"DUPL: {friendly_name}")
        m_entity_names.add(friendly_name)

        if yml["templates"][template]["type"] == "ITEM":
            yml["templates"][template]["category"] = quoted(category(template).name)
            # if template not in m_used_templates:
            #    l_templatesUseless.append(template)
            continue
        else:
            if yml["templates"][template]["rig"] == "noble_woman_base":
                yml["templates"][template]["gender"] = "female"
            if yml["templates"][template]["rig"] not in ["noble_woman_base", "woman_base", "man_base"]:
                l_templatesUseless.append(template)
                continue
            if yml["templates"][template]["name"] == str(yml["templates"][template]["nameID"]):
                yml["templates"][template]["name"] = str()
                yml["templates"][template]["nameID"] = 0
            yml["templates"][template]["category"] = yaml.scalarstring.DoubleQuotedScalarString(category2(template).name)
        if "effects" in yml["templates"][template]:
            del yml["templates"][template]["effects"]
        if "animations" in yml["templates"][template]:
            del yml["templates"][template]["animations"]
        if "mimics" in yml["templates"][template]:
            del yml["templates"][template]["mimics"]

    for t in l_templatesUseless:
        print(f"Removing template: {t}")
        del yml["templates"][t]

    print(f"Removed useless templates: {len(l_templatesUseless)}")
    print(f"Left templates: {len(yml['templates'])}")

    # with open(f"{m_FOLDER}/EntityDump_actors_filtered.yml", mode="w", encoding="utf-8") as oy:
    #    yaml.dump(yml, oy, Dumper=yaml.RoundTripDumper, indent=2, block_seq_indent=2)

    print(f"[*] Dumping json filtered")
    with open(f"{m_FOLDER}/EntityDump_actors_filtered.json", mode="w", encoding="utf-8") as jo:
        json.dump(yml, jo, sort_keys=False, ensure_ascii=False, indent=2)

    # for discord - cleaned from ITEMs
    l_templatesUseless.clear()
    for t in yml["templates"]:
        if yml["templates"][t]["type"] == "ITEM":
            l_templatesUseless.append(t)

    for t in l_templatesUseless:
        print(f"Removing template: {t}")
        del yml["templates"][t]

    with open(f"{m_FOLDER}/EntityDump_actors_only.json", mode="w", encoding="utf-8") as jo:
        json.dump(yml, jo, sort_keys=False, ensure_ascii=False, indent=2)


# shared data
m_data = None
m_scene_yml = None
m_selector_yml = {
    "templates": {
        "nr_scene_selector": {
            "entityObject": {
                ".type": "NR_SceneSelector",
                "m_nodesMale": CommentedSeq(),
                "m_nodesFemale": CommentedSeq(),
                "m_customDLCInfo": CommentedSeq(),
                "m_stringtable": CommentedSeq()
            }
        }
    }
}
m_dfs_used = set()
m_dfs_category = dict()
m_dfs_children = dict()
m_templates = dict()
m_path_by_friendly_name = dict()
m_npc_data = dict()
m_localized_names = {
    j: [] for j in EAN
}
# name[path] = npc_nameID, npc_name, appearances[app_name][slot_name] = final_w2ent_path, npc_category (rewrite appearances if cat >)
m_stringtable = dict()
m_stringtable_copies = 0
m_npc_by_cats = {
    EG.EG_Male: {
        j: [] for j in EAN
    },
    EG.EG_Female: {
        j: [] for j in EAN
    }
}
m_templates_by_cats = {
    EG.EG_Male: {
        i: {j: [] for j in EAN} for i in ENR
    },
    EG.EG_Female: {
        i: {j: [] for j in EAN} for i in ENR
    }
}


def friendly_name(path: str):
    return path.split("/")[-1].split(".")[0]


def friendly_npc_name(name: str):
    ret = name.lower().replace(" ", "_").replace("'", "")
    if ret.startswith("item_name_"):
        ret = ret[len("item_name_"):] + "_item"

    return ret


# friendly npc cat name
def friendly_npc_category(npc_cat: EAN, short: bool = False) -> str:
    if npc_cat == EAN.EAN_Unknown:
        return "un" if short else "unknown"
    elif npc_cat == EAN.EAN_ArmorSet:
        return "as" if short else "armor_set"
    elif npc_cat == EAN.EAN_DLCCustom:
        return "dc" if short else "dlc_custom"
    elif npc_cat == EAN.EAN_DLCMain:
        return "dm" if short else  "dlc_main"
    elif npc_cat == EAN.EAN_DLCSecondary:
        return "ds" if short else  "dlc_secondary"
    elif npc_cat == EAN.EAN_VanillaMain:
        return "vm" if short else  "vanilla_main"
    elif npc_cat == EAN.EAN_VanillaSecondary:
        return "vs" if short else  "vanilla_secondary"


# str npc cat name
def str_npc_category(npc_cat: EAN) -> STR:
    if npc_cat == EAN.EAN_DLCCustom:
        return STR.CAT_DLC_Custom
    elif npc_cat == EAN.EAN_DLCMain:
        return STR.CAT_DLC_Main
    elif npc_cat == EAN.EAN_DLCSecondary:
        return STR.CAT_DLC_Secondary
    elif npc_cat == EAN.EAN_VanillaMain:
        return STR.CAT_Vanilla_Main
    elif npc_cat == EAN.EAN_VanillaSecondary:
        return STR.CAT_Vanilla_Secondary


def is_valid_slot_category(slot_cat: ENR) -> bool:
    return slot_cat in {
        ENR.ENR_GSlotHead,
        ENR.ENR_RSlotHair,
        ENR.ENR_RSlotBody,
        ENR.ENR_RSlotTorso,
        ENR.ENR_RSlotArms,
        ENR.ENR_RSlotGloves,
        ENR.ENR_RSlotDress,
        ENR.ENR_RSlotLegs,
        ENR.ENR_RSlotShoes,
        ENR.ENR_RSlotMisc
    }


# friendly slot cat name
def friendly_slot_category(slot_cat: ENR) -> str:
    if slot_cat == ENR.ENR_GSlotHead:
        return "head"
    elif slot_cat == ENR.ENR_RSlotHair:
        return "hair"
    elif slot_cat == ENR.ENR_RSlotBody:
        return "body"
    elif slot_cat == ENR.ENR_RSlotTorso:
        return "torso"
    elif slot_cat == ENR.ENR_RSlotArms:
        return "arms"
    elif slot_cat == ENR.ENR_RSlotGloves:
        return "gloves"
    elif slot_cat == ENR.ENR_RSlotDress:
        return "dress"
    elif slot_cat == ENR.ENR_RSlotLegs:
        return "legs"
    elif slot_cat == ENR.ENR_RSlotShoes:
        return "shoes"
    elif slot_cat == ENR.ENR_RSlotMisc:
        return "misc"
    else:
        return str()


# unused atm - seems to give no benefit
def dfs_npc_category(key) -> int:
    global m_data, m_dfs_used, m_dfs_children
    print(f"Key = {key}, {m_data[key]['category']}")
    max_cat = EAN[m_data[key]["category"]].value

    if key in m_dfs_used:
        return max_cat

    m_dfs_used.add(key)

    if key in m_dfs_children:
        for child_key in m_dfs_children[key]:
            max_cat = max(max_cat, dfs_npc_category(child_key))

    m_data[key]["category"] = EAN(max_cat).name
    return max_cat


# adds colorings from base to children entities
def dfs_pull_colorings(path) -> dict:
    global m_data
    # print(f"DFS: path = {path}")

    result = dict()
    # add appearance colorings if any
    if "appearances" in m_data[path]:
        for app in m_data[path]["appearances"]:
            if "coloring" in m_data[path]["appearances"][app]:
                result[app] = m_data[path]["appearances"][app]["coloring"]

    # add parent colorings as well
    if "includes" in m_data[path]:
        for v in m_data[path]["includes"]:
            sub_result = dfs_pull_colorings(v)
            for app in sub_result:
                if app not in result:
                    # print(f"DFS: add appearance coloring: {app}")
                    result[app] = sub_result[app]

    return result


def get_app_template_colorings(app_template: str, app_coloring_components) -> dict:
    global m_data
    template_app_colorings = dict()
    if app_coloring_components is None or not app_coloring_components:
        return template_app_colorings

    if "components" in m_data[app_template]:
        for comp_name in m_data[app_template]["components"]:
            if comp_name in app_coloring_components:
                template_app_colorings[comp_name] = app_coloring_components[comp_name]

    return template_app_colorings


def get_app_template_colorings_str(app_template: str, app_coloring_components) -> str:
    template_app_colorings = get_app_template_colorings(app_template, app_coloring_components)
    return json.dumps(template_app_colorings, sort_keys=True)


def get_app_template_coloring_index(app_template: str, app_coloring_components) -> int:
    global m_templates
    coloring_str = get_app_template_colorings_str(app_template, app_coloring_components)

    # mark non-colored coloring as -1
    if coloring_str == "{}":
        return -1
    app_colorings = m_templates[app_template]["colorings"]
    if coloring_str not in app_colorings:
        print("get_app_template_coloring_index: ERROR")
    index = app_colorings.index(coloring_str)
    if index == 0:
        print("get_app_template_coloring_index: ZERO")
    return index


def get_app_template_final_path(app_template: str, coloring_index: int, ignore_head_category: bool = False) -> str:
    global m_templates

    entity_name = friendly_name(app_template)

    # just one duplicate case + handle components names manually
    if app_template == "characters/models/secondary_npc/irina/t_01_wa__novigrad_sorceress.w2ent":
        return "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_t_01_wa__novigrad_sorceress_irina_coloring_1.w2ent"
    elif app_template == "dlc/ep1/data/characters/npc_entities/crowd_npc/ofir_enchanter/t1_14_ma__novigrad_citizen_p04.w2ent":
        return "dlc/dlcnewreplacers/data/entities/colorings/dlc_secondary/nr_t1_14_ma__novigrad_citizen_p04_ep1_coloring_1.w2ent"

    # head - special case
    if not ignore_head_category and m_templates[app_template]["slot_category"] == ENR.ENR_GSlotHead:
        if app_template == "items/quest_items/sq303/sq303_item__crimson_mask/h_01_ma__dandelion.w2ent":
            return "dlc/dlcnewreplacers/data/entities/heads/vanilla_main/nr_h_01_ma__dandelion_crimson_mask.w2ent"

        cat_folder = friendly_npc_category(m_templates[app_template]["npc_category"], False)
        ent_name = friendly_name(app_template)
        if coloring_index < 1:
            return f"dlc/dlcnewreplacers/data/entities/heads/{cat_folder}/nr_{entity_name}.w2ent"
        else:
            return f"dlc/dlcnewreplacers/data/entities/heads/{cat_folder}/nr_{entity_name}_coloring_{coloring_index}.w2ent"

    # non-colored - just use vanilla path
    if coloring_index < 1:
        return app_template

    # colored - use custom dlc path
    npc_cat = m_templates[app_template]["npc_category"]
    # DLC JoWitcheress case
    if app_template.startswith("dlc/dlcjowitcheress/data"):
        ret = f"dlc/dlcjowitcheress/data/entities/colorings/{friendly_npc_category(npc_cat, False)}/nr_{entity_name}_coloring_{coloring_index}.w2ent"
    else:
        ret = f"dlc/dlcnewreplacers/data/entities/colorings/{friendly_npc_category(npc_cat, False)}/nr_{entity_name}_coloring_{coloring_index}.w2ent"
    return ret


def load_data():
    global m_data, m_templates, m_templates_by_cats, m_npc_data, m_npc_by_cats, m_path_by_friendly_name
    # load ready json
    with open(f"{m_FOLDER}/EntityDump_actors_filtered.json", mode="r", encoding="utf-8") as ij:
        m_data = json.load(ij)["templates"]

    # add app templates
    for template in m_data:
        m_path_by_friendly_name[friendly_name(template)] = template
        # pre-generate coloring dict for all
        m_data[template]["coloring_dict"] = dict()
        if "appearances" in m_data[template]:
            m_data[template]["coloring_dict"] = dfs_pull_colorings(template)

        # not actor or no apps - skip
        if m_data[template]["type"] != "ACTOR" or "appearances" not in m_data[template]:
            continue

        coloring_dict = m_data[template]["coloring_dict"]
        npc_category = EAN[m_data[template]["category"]]
        npc_name = m_data[template]["name"]
        npc_nameID = m_data[template]["nameID"]

        npc_gender_val = EG.EG_None.value
        # rig is more important
        if m_data[template]["rig"] == "man_base":
            npc_gender_val = EG.EG_Male.value
        elif m_data[template]["rig"] == "woman_base":
            npc_gender_val = EG.EG_Female.value
        elif m_data[template]["gender"] == "male":
            npc_gender_val = EG.EG_Male.value
        elif m_data[template]["gender"] == "female":
            npc_gender_val = EG.EG_Female.value

        # check every appearance
        for app_name in m_data[template]["appearances"]:
            app = m_data[template]["appearances"][app_name]

            for app_template in app["templates"]:
                # add new app template if wasn't before
                if app_template not in m_templates:
                    m_templates[app_template] = {
                        "path": app_template,
                        "colorings": [
                            "{}"  # default empty coloring for all
                        ],
                        "slot_category": ENR[m_data[app_template]["category"]],
                        "npc_category": npc_category,
                        "name": npc_name,
                        "nameID": npc_nameID,
                        "extraKey": friendly_name(app_template),
                        "gender": npc_gender_val
                    }
                    # Unknown thing, but used by actor - change to misc item category
                    if m_templates[app_template] == ENR.ENR_GSlotUnknown:
                        m_templates[app_template] = ENR.ENR_RSlotMisc
                # update possible gender always
                m_templates[app_template]["gender"] |= npc_gender_val
                # update npc name & cat info
                if npc_nameID > 0 and str(npc_nameID) != npc_name and \
                        (m_templates[app_template]["npc_category"].value < npc_category.value or m_templates[app_template]["nameID"] == 0 or str(m_templates[app_template]["nameID"]) == m_templates[app_template]["name"]):
                    # current npc is cooler, use it
                    m_templates[app_template]["npc_category"] = npc_category
                    m_templates[app_template]["nameID"] = npc_nameID
                    m_templates[app_template]["name"] = npc_name

                # add new coloring variant
                app_colorings = dict()
                if app_name in coloring_dict and "components" in m_data[app_template]:
                    for comp_name in m_data[app_template]["components"]:
                        if comp_name in coloring_dict[app_name]:
                            app_colorings[comp_name] = coloring_dict[app_name][comp_name]

                if app_colorings:
                    coloring_str = json.dumps(app_colorings, sort_keys=True)
                    # not effective but we need to preserve order
                    if coloring_str not in m_templates[app_template]["colorings"]:
                        m_templates[app_template]["colorings"].append(coloring_str)

    # add custom DLC templates & NPC sets
    load_dlc_data()

    # add equipment item templates & Armor sets ?
    load_xml_items()

    m_templates = dict(sorted(m_templates.items()))
    print(f"Appearance templates: {len(m_templates)}")

    # add NPC sets & Armor sets
    # [name] = npc_nameID, npc_name, npc_category (rewrite appearances if cat >), appearances[app_name][slot_name] = final_w2ent_path/[list for misc]
    for template in m_data:
        # NPC set
        if m_data[template]["type"] == "ACTOR":
            coloring_dict = m_data[template]["coloring_dict"]
            npc_name = m_data[template]["name"]
            npc_name_id = m_data[template]["nameID"]
            npc_category = EAN[m_data[template]["category"]]
            if npc_name_id == 0 or str(npc_name_id) == npc_name or "appearances" not in m_data[template]:
                continue

            if npc_name not in m_npc_data:
                npc_gender = EG.EG_None
                # rig is more important
                if m_data[template]["rig"] == "man_base":
                    npc_gender = EG.EG_Male
                elif m_data[template]["rig"] == "woman_base":
                    npc_gender = EG.EG_Female
                elif m_data[template]["gender"] == "male":
                    npc_gender = EG.EG_Male
                elif m_data[template]["gender"] == "female":
                    npc_gender = EG.EG_Female

                # print(f"Add {npc_name}: {template}, npc_category = {npc_category}")
                m_npc_data[npc_name] = {
                    "nameID": m_data[template]["nameID"],
                    "name": m_data[template]["name"],
                    "gender": npc_gender,
                    "category": npc_category,
                    "appearances": dict(),
                }

            has_higher_category = False
            if npc_category.value > m_npc_data[npc_name]["category"].value:
                # print(f"Update category {npc_name}: {template}, npc_category = {npc_category}")
                has_higher_category = True
                m_npc_data[npc_name]["category"] = npc_category
                m_npc_data[npc_name]["nameID"] = m_data[template]["nameID"]

            for app_name in m_data[template]["appearances"]:
                if app_name not in m_npc_data[npc_name] or has_higher_category:
                    # adding/rewriting appearance templates
                    m_npc_data[npc_name]["appearances"][app_name] = {
                        i: str() if i != ENR.ENR_RSlotMisc else [] for i in ENR
                    }
                    # print(f"Update {npc_name} #{app_name}: {template}")
                    app_colorings = None
                    if app_name in coloring_dict:
                        app_colorings = coloring_dict[app_name]

                    for app_template in m_data[template]["appearances"][app_name]["templates"]:
                        slot_category = ENR[m_data[app_template]["category"]]
                        if slot_category != ENR.ENR_RSlotMisc and m_npc_data[npc_name]["appearances"][app_name][
                            slot_category]:
                            # print(f"CONFLICT SLOT {slot_category.name} ({app_template} and {m_npc_data[npc_name]['appearances'][app_name][slot_category]}) {npc_name} #{app_name}: {template}")
                            # set as misc item to avoid rewriting slot
                            slot_category = ENR.ENR_RSlotMisc

                        coloring_index = get_app_template_coloring_index(app_template, app_colorings)
                        final_path = get_app_template_final_path(app_template, coloring_index)
                        if slot_category != ENR.ENR_RSlotMisc:
                            m_npc_data[npc_name]["appearances"][app_name][slot_category] = final_path
                        else:
                            m_npc_data[npc_name]["appearances"][app_name][slot_category].append(final_path)

    # add NPC sets by cats
    for npc_name in m_npc_data:
        m_npc_by_cats[m_npc_data[npc_name]["gender"]][m_npc_data[npc_name]["category"]].append(
            npc_name
        )

    # Sort NPC sets by alphabet
    for gender in [EG.EG_Male, EG.EG_Female]:
        for npc_category in EAN:
            if not m_npc_by_cats[gender][npc_category]:
                continue
            m_npc_by_cats[gender][npc_category] = sorted(
                m_npc_by_cats[gender][npc_category]
            )
            # print info
            cnt = len(m_npc_by_cats[gender][npc_category])
            if cnt > 0:
                print(f"NPC sets[{gender.name}][{npc_category.name}] = {cnt}")

    with open(f"{m_FOLDER}/DEBUG_npc_sets.json", mode="w", encoding="utf-8") as jo:
        start_t = time.time()
        json.dump(m_npc_by_cats, jo, sort_keys=False, ensure_ascii=False, indent=2)
        end_t = time.time()
        print(f"npc sets JSON saved in: {end_t - start_t} s")

    # sort app templates by cats (w/o coloring paths yet - in creating scene)
    for t in m_templates:
        if m_templates[t]["nameID"] > 0 and m_templates[t]["name"] != str(m_templates[t]["nameID"]) and m_templates[t]["npc_category"] != EAN.EAN_Unknown and m_templates[t]["slot_category"] != ENR.ENR_GSlotUnknown:
            for gender in [EG.EG_Male, EG.EG_Female]:
                if m_templates[t]["gender"] == gender.EG_Any:
                    print(f"BIGENDER: {t}")
                if m_templates[t]["gender"] & gender.value:
                    m_templates_by_cats[gender][m_templates[t]["slot_category"]][m_templates[t]["npc_category"]].append(t)

    # sort app templates by alphabet (w/o coloring paths yet - in creating scene)
    for gender in [EG.EG_Male, EG.EG_Female]:
        for slot_category in ENR:
            for npc_category in EAN:
                if not m_templates_by_cats[gender][slot_category][npc_category]:
                    continue
                m_templates_by_cats[gender][slot_category][npc_category] = sorted(
                    m_templates_by_cats[gender][slot_category][npc_category],
                    key=lambda item: m_templates[item]["name"]
                )
                # print info
                cnt = len(m_templates_by_cats[gender][slot_category][npc_category])
                if cnt > 0:
                    print(f"Appearance templates[{gender.name}][{slot_category.name}][{npc_category.name}] = {cnt}")

    with open(f"{m_FOLDER}/DEBUG_app_templates.json", mode="w", encoding="utf-8") as jo:
        start_t = time.time()
        json.dump(m_templates_by_cats, jo, sort_keys=False, ensure_ascii=False, indent=2)
        end_t = time.time()
        print(f"app templates JSON saved in: {end_t - start_t} s")


def load_xml_items():
    global m_data, m_templates, m_npc_data, m_path_by_friendly_name

    encoding_mime = magic.Magic(mime_encoding=True)
    items_checked = set()
    paths_checked = set()

    loc_str_regex_to_npc_name = {
        "item_name_elegant_beauclair_[a-z]*$": "item_name_elegant_beauclair_suit",
        "item_name_guard_lvl1_geralt_[a-z]*$": "item_name_guard_lvl1_geralt_armor",
        "item_name_guard_lvl2_geralt_[a-z]*$": "item_name_guard_lvl2_geralt_armor",
        "item_name_knight_geralt_[a-z]*$": "item_name_knight_geralt_armor",
        "item_name_toussaint_[a-z]*$": "item_name_toussaint_armor",
        "item_name_baw_vampire_[a-z]*$": "item_name_baw_vampire_chest",
        "item_name_baw_vampire_[a-z]*_2$": "item_name_baw_vampire_chest_2",
        "item_name_beauclair_(shoes|suit_01|pants)$": "item_name_beauclair_suit_01",
        "item_name_beauclair_prison_[a-z]*$": "item_name_beauclair_prison_shirt",
        "item_name_lynx_(armor|[b-z][a-z]*_1)$": "item_name_lynx_armor",
        "item_name_lynx_(armor_1|[b-z][a-z]*_2)$": "item_name_lynx_armor_1",
        "item_name_lynx_(armor_2|[b-z][a-z]*_3)$": "item_name_lynx_armor_2",
        "item_name_lynx_(armor_3|[b-z][a-z]*_4)$": "item_name_lynx_armor_3",
        "item_name_lynx_(armor_4|[b-z][a-z]*_5)$": "item_name_lynx_armor_4",
        "item_name_gryphon_(armor|[b-z][a-z]*_1)$": "item_name_gryphon_armor",
        "item_name_gryphon_(armor_1|[b-z][a-z]*_2)$": "item_name_gryphon_armor_1",
        "item_name_gryphon_(armor_2|[b-z][a-z]*_3)$": "item_name_gryphon_armor_2",
        "item_name_gryphon_(armor_3|[b-z][a-z]*_4)$": "item_name_gryphon_armor_3",
        "item_name_gryphon_(armor_4|[b-z][a-z]*_5)$": "item_name_gryphon_armor_4",
        "item_name_bear_(armor|[b-z][a-z]*_1)$": "item_name_bear_armor",
        "item_name_bear_(armor_1|[b-z][a-z]*_2)$": "item_name_bear_armor_1",
        "item_name_bear_(armor_2|[b-z][a-z]*_3)$": "item_name_bear_armor_2",
        "item_name_bear_(armor_3|[b-z][a-z]*_4)$": "item_name_bear_armor_3",
        "item_name_bear_(armor_4|[b-z][a-z]*_5)$": "item_name_bear_armor_4",
        "item_name_wolf_(armor|[b-z][a-z]*_1)$": "item_name_wolf_armor",
        "item_name_wolf_(armor_1|[b-z][a-z]*_2)$": "item_name_wolf_armor_1",
        "item_name_wolf_(armor_2|[b-z][a-z]*_3)$": "item_name_wolf_armor_2",
        "item_name_wolf_(armor_3|[b-z][a-z]*_4)$": "item_name_wolf_armor_3",
        "item_name_wolf_(armor_4|[b-z][a-z]*_5)$": "item_name_wolf_armor_4",
        "item_name_red_wolf_[a-z]*_1$": "item_name_red_wolf_armor_1",
        "item_name_newgame_red_wolf_[a-z]*_1$": "item_name_newgame_red_wolf_armor_1",
        "item_name_newgame_wolf_(armor|[b-z][a-z]*_1)$": "item_name_newgame_wolf_armor",
        "item_name_newgame_wolf_(armor_1|[b-z][a-z]*_2)$": "item_name_newgame_wolf_armor_1",
        "item_name_newgame_wolf_(armor_2|[b-z][a-z]*_3)$": "item_name_newgame_wolf_armor_2",
        "item_name_newgame_wolf_(armor_3|[b-z][a-z]*_4)$": "item_name_newgame_wolf_armor_3",
        "item_name_ofir_[a-z]*$": "item_name_ofir_armor",
        "item_name_thief_borsody_[a-z]*$": "item_name_thief_borsody_armor",
        "item_name_rose_[a-z]*$": "item_name_rose_armor",
        "item_name_hoscorset_[a-z]*$": "item_name_hoscorset_armor",
        "ui_gog_reward_[a-z]*$": "ui_gog_reward_armor",
        "item_name_ngu_tiger_[a-z]*$": "item_name_ngu_tiger_armor",
        "item_name_skellige_(suit01|casual_pants01|casual_shoes)$": "item_name_skellige_suit01",
        "item_name_netflix_[a-z]*_dlc$": "item_name_netflix_armour_dlc",
        "item_name_netflix_[a-z]*_dlc_1$": "item_name_netflix_armour_dlc_1",
        "item_name_netflix_[a-z]*_dlc_2$": "item_name_netflix_armour_dlc_2",
        # not matching but to be
        "item_name_heavy_[a-z]*_01$": "item_name_heavy_armor_01",
        "item_name_heavy_[a-z]*_02$": "item_name_heavy_armor_02",
        "item_name_heavy_[a-z]*_03$": "item_name_heavy_armor_03",
        "item_name_heavy_[a-z]*_04$": "item_name_heavy_armor_04",
    }
    # groups = dict()

    for fake_npc_name in loc_str_regex_to_npc_name.values():
        m_npc_data[fake_npc_name] = {
            "nameID": 1,
            "name": fake_npc_name,
            # "extraKey": fake_npc_name,
            "selector_flag": SPF.ENR_SPForceUnloadAllExceptHair.value,
            "gender": EG.EG_Male,
            "category": EAN.EAN_ArmorSet,
            "appearances": dict()
        }
        # some sets are locked for female atm
        if fake_npc_name in {
            "ui_gog_reward_armor",
            "item_name_ngu_tiger_armor",
            "item_name_netflix_armour_dlc_1",
            "item_name_netflix_armour_dlc_2",
        }:
            continue
        # add female variant for JoWitcheress dlc
        m_npc_data[fake_npc_name + "_female"] = {
            "nameID": 1,
            "name": fake_npc_name,
            "dlc_id": "dlc_jowitcheress",
            "dlc_name_key": "dlc_name_jowitcheress",
            # "extraKey": fake_npc_name,
            "selector_flag": SPF.ENR_SPForceUnloadAllExceptHair.value,
            "gender": EG.EG_Female,
            "category": EAN.EAN_ArmorSet,
            "appearances": dict()
        }
    # unload hair for feline hood
    m_npc_data["item_name_lynx_armor_4"]["selector_flag"] = SPF.ENR_SPForceUnloadAll.value
    m_npc_data["item_name_lynx_armor_4" + "_female"]["selector_flag"] = SPF.ENR_SPForceUnloadAll.value

    cooked_w2ent_dir = "D:/w3.modding/w3.projects/w3.NEW_REPLACERS/_pyscripts/w2ent_nge_dump/files/Mod/Cooked"
    # Manually add naked geralt
    m_npc_data["fake_key_x288_e"] = {
        "name": "fake_key_x288_e",
        "nameID": 1,
        "gender": EG.EG_Male,
        "category": EAN.EAN_ArmorSet,
        "appearances": {
            "naked": {
                i: str() if i != ENR.ENR_RSlotMisc else [] for i in ENR
            },
            "naked_towel": {
                i: str() if i != ENR.ENR_RSlotMisc else [] for i in ENR
            },
            "naked_wet": {
                i: str() if i != ENR.ENR_RSlotMisc else [] for i in ENR
            }
        }
    }
    m_npc_data["fake_key_x288_e"]["appearances"]["naked"][ENR.ENR_RSlotTorso] = m_path_by_friendly_name["t_01_mg__body_medalion"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked"][ENR.ENR_RSlotGloves] = m_path_by_friendly_name["g_01_mg__body"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked"][ENR.ENR_RSlotLegs] = m_path_by_friendly_name["l_01_mg__body_underwear"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked"][ENR.ENR_RSlotShoes] = m_path_by_friendly_name["s_01_mg__body"]

    m_npc_data["fake_key_x288_e"]["appearances"]["naked_towel"][ENR.ENR_RSlotTorso] = m_path_by_friendly_name["t_01_mg__body_towel"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked_towel"][ENR.ENR_RSlotGloves] = m_path_by_friendly_name["g_01_mg__body"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked_towel"][ENR.ENR_RSlotLegs] = m_path_by_friendly_name["l_01_mg__body_underwear"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked_towel"][ENR.ENR_RSlotShoes] = m_path_by_friendly_name["s_01_mg__body"]

    m_npc_data["fake_key_x288_e"]["appearances"]["naked_wet"][ENR.ENR_RSlotTorso] = m_path_by_friendly_name["t_01_mg__body_wet_hires"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked_wet"][ENR.ENR_RSlotGloves] = m_path_by_friendly_name["g_01_mg__body_wet"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked_wet"][ENR.ENR_RSlotLegs] = m_path_by_friendly_name["l_01_mg__body_wet"]
    m_npc_data["fake_key_x288_e"]["appearances"]["naked_wet"][ENR.ENR_RSlotShoes] = m_path_by_friendly_name["s_01_mg__body_wet"]

    # item_name_rose_armor: legs: dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_s_01_mb__skellige_villager_coloring_2.w2ent
    # item_name_rose_armor: shoes: dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_l0_02_ma__novigrad_guard_coloring_5.w2ent

    # item_name_beauclair_suit_01: gloves: quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/g_01_ma__body.w2ent

    # item_name_elegant_beauclair_suit: gloves: quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/g_01_ma__body.w2ent

    # item_name_skellige_suit01: gloves: quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/g_01_ma__body.w2ent

    # item_name_beauclair_prison_shirt: gloves: characters/models/crowd_npc/skellige_villager/gloves/g_04_ma__skellige_villager.w2ent
    # item_name_beauclair_prison_shirt: shoes: characters/models/crowd_npc/nml_villager/shoes/s_02_ma__nml_villager.w2ent

    for xml_path in Path("XML").rglob("*.xml"):
        encoding = encoding_mime.from_file(str(xml_path))
        # print(f"Parse xml: {str(xml_path)} [{encoding}]")

        root_node = XET.parse(str(xml_path), parser=XET.XMLParser(encoding=encoding)).getroot()
        for child in root_node.findall('definitions/items/item'):
            item_name = child.get("name")
            if item_name in items_checked:
                continue
            items_checked.add(item_name)

            if all(x in child.attrib for x in ["name", "category", "equip_template", "localisation_key_name"]) and child.get("category") in {"armor", "pants", "boots", "gloves"}:

                tags = child.find("tags").text.replace("	", "").replace(" ", "").replace("\n", "").split(",")
                if "NoShow" in tags or "NoDrop" in tags:
                    continue

                set_name = str()
                for tag in tags:
                    if tag.endswith("Set"):
                        set_name = tag
                        # print(f"SET PART: {tag}")

                # print(f"Tags = [{tags}]")
                slot = ENR.ENR_RSlotMisc
                if child.get("category") == "armor":
                    slot = ENR.ENR_RSlotTorso
                elif child.get("category") == "pants":
                    slot = ENR.ENR_RSlotLegs
                elif child.get("category") == "boots":
                    slot = ENR.ENR_RSlotShoes
                elif child.get("category") == "gloves":
                    slot = ENR.ENR_RSlotArms

                friendly_path = child.get("equip_template")
                if friendly_path not in m_path_by_friendly_name:
                    continue

                if friendly_path in paths_checked:
                    pass
                    # continue
                paths_checked.add(friendly_path)

                full_path = m_path_by_friendly_name[friendly_path]
                colorings = ["{}"]
                app_names = ["default"]
                if "appearances" in m_data[full_path]:
                    if "dye_default" in m_data[full_path]["appearances"]:
                        # dyeable CItemEntity
                        assert (len(m_data[full_path]["appearances"]["dye_default"]["templates"]) == 1)
                        new_full_path = m_data[full_path]["appearances"]["dye_default"]["templates"][0]
                        m_data[new_full_path]["appearances"] = m_data[full_path]["appearances"]
                        full_path = new_full_path
                        # dye_default always first
                        colorings.append(
                            get_app_template_colorings_str(full_path, m_data[full_path]["appearances"]["dye_default"]["coloring"])
                        )
                        app_names.append("dye_default")
                        for app_name in sorted(m_data[full_path]["appearances"].keys()):
                            if app_name == "dye_default":
                                continue
                            colorings.append(
                                get_app_template_colorings_str(full_path, m_data[full_path]["appearances"][app_name]["coloring"])
                            )
                            app_names.append(app_name)
                    else:
                        # just search for non-empty appearance?
                        for app_name in m_data[full_path]["appearances"].keys():
                            if len(m_data[full_path]["appearances"][app_name]["templates"]) > 0:
                                assert (len(m_data[full_path]["appearances"][app_name]["templates"]) == 1)
                                new_full_path = m_data[full_path]["appearances"][app_name]["templates"][0]
                                m_data[new_full_path]["appearances"] = m_data[full_path]["appearances"]
                                full_path = new_full_path

                                if "coloring" in m_data[full_path]["appearances"][app_name]:
                                    colorings.append( get_app_template_colorings_str(full_path, m_data[full_path]["appearances"][app_name]["coloring"]) )
                                    app_names.append(app_name)
                                break
                else:
                    # simple CEntity
                    # colorings.append("{}")
                    # app_names.append("default")
                    pass

                loc_name = child.get("localisation_key_name")

                m_templates[full_path] = {
                    "path": full_path,
                    "colorings": colorings,
                    "slot_category": slot,
                    "npc_category": EAN.EAN_VanillaMain if set_name else EAN.EAN_VanillaSecondary,
                    "name": "Geralt",
                    "nameID": 318188,
                    "extraKey": loc_name,
                    "gender": EG.EG_Male
                }

                # DLC JO Witcheress
                full_path_female = f"dlc/dlcjowitcheress/data/entities/{full_path.replace('.w2ent', '_jo.w2ent')}"
                os.makedirs(os.path.dirname(f"{cooked_w2ent_dir}/{full_path_female}"), exist_ok=True)
                shutil.copy2(f"{cooked_w2ent_dir}/{full_path}", f"{cooked_w2ent_dir}/{full_path_female}")
                m_data[full_path_female] = deepcopy(m_data[full_path])
                m_templates[full_path_female] = {
                    "path": full_path_female,
                    "colorings": colorings,
                    "slot_category": slot,
                    "npc_category": EAN.EAN_DLCCustom,
                    "dlc_id": "dlc_jowitcheress",
                    "dlc_name_key": "dlc_name_jowitcheress",
                    "name": "Geralt",
                    "nameID": 318188,
                    "extraKey": loc_name,
                    "gender": EG.EG_Female
                }

                print(f"Add item: {child.get('name')} ({loc_name}) [{child.get('category')} -> {slot.name}], colorings: {colorings}")

                for regex in loc_str_regex_to_npc_name:
                    if re.match(regex, loc_name):
                        fake_npc_name = loc_str_regex_to_npc_name[regex]
                        fake_npc_name_female = fake_npc_name + "_female"
                        print(f"Add to npc set: {loc_name} -> {regex} -> {fake_npc_name}")
                        for i, app_name in enumerate(app_names):
                            if len(app_names) > 1 and i == 0:
                                # skip empty coloring if there are another
                                continue

                            for gender in [EG.EG_Male, EG.EG_Female]:
                                t_path = full_path if gender == EG.EG_Male else full_path_female
                                t_npc_name = fake_npc_name if gender == EG.EG_Male else fake_npc_name_female
                                # some sets are locked for female atm
                                if t_npc_name not in m_npc_data:
                                    continue

                                app_coloring = m_data[t_path].get("appearances", {}).get(app_name, {}).get("coloring", "{}")

                                coloring_index = get_app_template_coloring_index(t_path, app_coloring)
                                final_path = get_app_template_final_path(t_path, coloring_index)

                                print(f"Add fake [{t_npc_name}]<{gender.name}> template: {final_path}")

                                if app_name not in m_npc_data[t_npc_name]["appearances"]:
                                    m_npc_data[t_npc_name]["appearances"][app_name] = {
                                        i: str() if i != ENR.ENR_RSlotMisc else [] for i in ENR
                                    }

                                test0 = loc_name
                                test3 = gender
                                test4 = app_name
                                test5 = child.get('name')
                                if slot == ENR.ENR_RSlotMisc or (m_npc_data[t_npc_name]["appearances"][app_name][slot] and m_npc_data[t_npc_name]["appearances"][app_name][slot] != final_path):
                                    pass
                                    # m_npc_data[t_npc_name]["appearances"][app_name][ENR.ENR_RSlotMisc].append(final_path)
                                else:
                                    m_npc_data[t_npc_name]["appearances"][app_name][slot] = final_path

                        break

    m_npc_data["item_name_rose_armor"]["appearances"]["default"][ENR.ENR_RSlotLegs] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_s_01_mb__skellige_villager_coloring_2.w2ent"
    m_npc_data["item_name_rose_armor"]["appearances"]["default"][ENR.ENR_RSlotShoes] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_l0_02_ma__novigrad_guard_coloring_5.w2ent"

    m_npc_data["item_name_rose_armor" + "_female"]["appearances"]["default"][ENR.ENR_RSlotLegs] = "dlc/dlcnewreplacers/data/entities/colorings/dlc_secondary/nr_l_01_wa__olgierds_gang_member_woman_coloring_1.w2ent"

    m_npc_data["item_name_beauclair_suit_01"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/g_01_ma__body.w2ent"
    m_npc_data["item_name_elegant_beauclair_suit"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/g_01_ma__body.w2ent"
    m_npc_data["item_name_skellige_suit01"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "quests/part_2/quest_files/q106_tower/characters/ghost_npc_body_parts/popiel/g_01_ma__body.w2ent"

    m_npc_data["item_name_beauclair_suit_01" + "_female"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "dlc/bob/data/characters/models/secondary_npc/hananna_von_kagen/g_01_wa__hanna_von_kagen.w2ent"
    m_npc_data["item_name_elegant_beauclair_suit" + "_female"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "dlc/bob/data/characters/models/secondary_npc/hananna_von_kagen/g_01_wa__hanna_von_kagen.w2ent"
    m_npc_data["item_name_skellige_suit01" + "_female"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "dlc/bob/data/characters/models/secondary_npc/hananna_von_kagen/g_01_wa__hanna_von_kagen.w2ent"

    m_npc_data["item_name_beauclair_prison_shirt"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "characters/models/crowd_npc/skellige_villager/gloves/g_04_ma__skellige_villager.w2ent"
    m_npc_data["item_name_beauclair_prison_shirt"]["appearances"]["default"][ENR.ENR_RSlotShoes] = "characters/models/crowd_npc/nml_villager/shoes/s_02_ma__nml_villager.w2ent"

    m_npc_data["item_name_beauclair_prison_shirt" + "_female"]["appearances"]["default"][ENR.ENR_RSlotGloves] = "characters/models/common/woman_average/body/g_01_wa__old_body.w2ent"
    m_npc_data["item_name_beauclair_prison_shirt" + "_female"]["appearances"]["default"][ENR.ENR_RSlotShoes] = "characters/models/crowd_npc/nml_villager_woman/shoes/s_02_wa__nml_villager.w2ent"

def load_dlc_data():
    global m_templates, m_npc_data, m_selector_yml, m_path_by_friendly_name

    for dlc_file in Path("DLCCustom").rglob("*.json"):
        with open(dlc_file, mode="r", encoding="utf-8") as ij:
            data = json.load(ij)
            m_selector_yml["templates"]["nr_scene_selector"]["entityObject"]["m_customDLCInfo"].append({
                ".type": "NR_SceneCustomDLCInfo",
                "m_dlcID": quoted(data["dlc_id"]),
                "m_dlcNameKey": quoted(data["dlc_name_key"]),
                "m_dlcAuthor": quoted(data["dlc_author_nickname"]),
                "m_dlcLink": quoted(data["dlc_link"])
            })
            # print(data)
            for i, t_path in enumerate(data["dlc_appearance_templates"]):
                m_path_by_friendly_name[friendly_name(t_path)] = t_path
                t_data = data["dlc_appearance_templates"][t_path]
                m_templates[t_path] = {
                    "path": t_path,
                    "colorings": [
                        json.dumps(t_data["template_coloring"], sort_keys=True) if "template_coloring" in t_data else "{}"  # default empty coloring for all
                    ],
                    "slot_category": ENR[t_data["template_slot"]],
                    "npc_category": EAN.EAN_DLCCustom,
                    "dlc_id": data["dlc_id"],
                    "dlc_name_key": data["dlc_name_key"],
                    "nameID": 1,  # means we use "name" as loc_key instead of "nameID" as loc_id
                    "name": "_skip_",
                    "gender": EG.EG_Any
                }
                if "template_name_key" in t_data:
                    m_templates[t_path]["extraKey"] = t_data["template_name_key"]
                else:
                    m_templates[t_path]["extraKey"] = friendly_name(t_path)

                if t_data["template_rig"] == "male":
                    m_templates[t_path]["gender"] = EG.EG_Male
                elif t_data["template_rig"] == "female":
                    m_templates[t_path]["gender"] = EG.EG_Female

            for gender_str in ["male", "female"]:
                if len(data[f"dlc_{gender_str}_appearance_sets"]) > 0:
                    npc_name = data["dlc_name_key"] + "_" + gender_str
                    m_npc_data[npc_name] = {
                        "nameID": 1,
                        "name": "_skip_",
                        "dlc_id": data["dlc_id"],
                        "dlc_name_key": data["dlc_name_key"],
                        "gender": EG.EG_Male if gender_str == "male" else EG.EG_Female,
                        "category": EAN.EAN_DLCCustom,
                        "appearances": dict()
                    }
                    for i, app_name in enumerate(data[f"dlc_{gender_str}_appearance_sets"]):
                        m_npc_data[npc_name]["appearances"][app_name] = {
                            j: str() if j != ENR.ENR_RSlotMisc else [] for j in ENR
                        }
                        for j, npc_template in enumerate(data[f"dlc_{gender_str}_appearance_sets"][app_name]):
                            slot = m_templates[npc_template]["slot_category"]
                            if slot != ENR.ENR_RSlotMisc and not m_npc_data[npc_name]["appearances"][app_name][slot]:
                                m_npc_data[npc_name]["appearances"][app_name][slot] = npc_template
                            else:
                                m_npc_data[npc_name]["appearances"][app_name][ENR.ENR_RSlotMisc].append(npc_template)


def write_yml_nicely(path, data):
    with open(path, mode="w", encoding="utf-8") as f_yml:
        start_t = time.time()
        yaml_dumper = ruamel.yaml.YAML()
        yaml_dumper.indent(mapping=2, sequence=4, offset=2)
        yaml_dumper.width = 1000000
        yaml_dumper.dump(data, f_yml)
        end_t = time.time()
        print(f"YML saved in: {end_t - start_t} s: {path}")


# vanilla_path | custom_path | components_count (int) | old_comp_1 | new_comp_1 | old_comp_N | new_comp_N
def write_coloring_files():
    global m_templates
    m_coloring_yml = {
        EG.EG_Male: {
            "coloringEntries": []
        },
        EG.EG_Female: {
            "coloringEntries": []
        }
    }

    custom_paths = set()
    known_components = {
        EG.EG_Male.value: set(),
        EG.EG_Female.value: set(),
        EG.EG_Any.value: set(),
    }
    known_colorings = {
        EG.EG_Male.value: dict(),
        EG.EG_Female.value: dict(),
        EG.EG_Any.value: dict(),
    }

    with open("WKIT_rename_components.txt", mode="w", encoding="utf-8") as f_comp_out:
        for i, t in enumerate(m_templates):
            if len(m_templates[t]["colorings"]) > 0:
                vanilla_path = t
                npc_gender = m_templates[t]["gender"]
                for j, coloring in enumerate(m_templates[t]["colorings"]):
                    if j == 0:
                        if coloring == "{}":
                            continue
                        else:
                            print(f"ADD DEFAULT COLORING: {coloring} ({vanilla_path})")
                            custom_path = t
                    else:
                        custom_path = get_app_template_final_path(t, j, True)

                    component_dict = json.loads(coloring)
                    component_cnt = len(component_dict)
                    if custom_path in custom_paths:
                        print(f"TEMPLATE DUPLICATE: {custom_path} ({vanilla_path})")
                    custom_paths.add(custom_path)

                    if j > 0:
                        f_comp_out.write(f"{vanilla_path}|{custom_path}|{component_cnt}")

                    for comp_name in component_dict:
                        new_comp_name = comp_name
                        if j > 0:
                            new_comp_name = f"{comp_name}_coloring_{j}"

                        comp_coloring = json.dumps(component_dict[comp_name])
                        use_existing = False
                        if comp_name in known_colorings[npc_gender] and comp_coloring in known_colorings[npc_gender][comp_name]:
                            new_comp_name = known_colorings[npc_gender][comp_name][comp_coloring]
                            use_existing = True
                            print(f"Use known component: {comp_name} -> {new_comp_name} ({t}) {comp_coloring}")
                        elif new_comp_name in known_components[npc_gender]:
                            coloring_num = 0
                            while new_comp_name in known_components[npc_gender]:
                                coloring_num += 1
                                new_comp_name = f"{comp_name}_coloring_{coloring_num}"

                            print(f"Handle component duplicate: {new_comp_name} ({t}) {comp_coloring}")

                        known_components[npc_gender].add(new_comp_name)
                        if comp_name not in known_colorings[npc_gender]:
                            known_colorings[npc_gender][comp_name] = dict()
                        known_colorings[npc_gender][comp_name][comp_coloring] = new_comp_name

                        # write
                        if j > 0:
                            f_comp_out.write(f"|{comp_name}|{new_comp_name}")

                        #if new_comp_name == "shoes_coloring_83":
                        #    breakpoint()

                        if not use_existing:
                            coloring_entry_yml = {
                                ".type": "SEntityTemplateColoringEntry",
                                "appearance": "nr_player",
                                "componentName": new_comp_name
                            }
                            if any(component_dict[comp_name][i] != 0 for i in range(0, 3)):
                                coloring_entry_yml["colorShift1"] = dict()
                                if component_dict[comp_name][0] != 0:
                                    coloring_entry_yml["colorShift1"]["hue"] = component_dict[comp_name][0]
                                if component_dict[comp_name][1] != 0:
                                    coloring_entry_yml["colorShift1"]["saturation"] = component_dict[comp_name][1]
                                if component_dict[comp_name][2] != 0:
                                    coloring_entry_yml["colorShift1"]["luminance"] = component_dict[comp_name][2]

                            if len(component_dict[comp_name]) > 3 and any(component_dict[comp_name][i] != 0 for i in range(3, 6)):
                                coloring_entry_yml["colorShift2"] = dict()
                                if component_dict[comp_name][3] != 0:
                                    coloring_entry_yml["colorShift2"]["hue"] = component_dict[comp_name][3]
                                if component_dict[comp_name][4] != 0:
                                    coloring_entry_yml["colorShift2"]["saturation"] = component_dict[comp_name][4]
                                if component_dict[comp_name][5] != 0:
                                    coloring_entry_yml["colorShift2"]["luminance"] = component_dict[comp_name][5]

                            if npc_gender & EG.EG_Male.value:
                                m_coloring_yml[EG.EG_Male]["coloringEntries"].append(coloring_entry_yml)
                            if npc_gender & EG.EG_Female.value:
                                m_coloring_yml[EG.EG_Female]["coloringEntries"].append(coloring_entry_yml)

                    if j > 0:
                        f_comp_out.write("\n")

    print(f"COMPONENTS WKIT data saved.")

    for i in [EG.EG_Male, EG.EG_Female]:
        m_coloring_yml[i] = {
            "templates": {
                "replacer": m_coloring_yml[i]
            }
        }
        write_yml_nicely(f"{m_FOLDER}/RADISH_{i.name}_colorings.yml", m_coloring_yml[i])

    # raise Exception("DEBUG STOP")


# vanilla_path | entity_new_name (nr_<name>[_coloring_x]) | npc_category_friendly
def write_rename_head_files():
    global m_templates

    custom_paths = set()
    with open("nr_def_head_items.xml", mode="w", encoding="utf-16-le") as f_head_xml:
        f_head_xml.write("<?xml version='1.0' encoding='UTF-16'?>\n")
        f_head_xml.write("<redxml>\n")
        f_head_xml.write("    <definitions>\n")
        f_head_xml.write("        <items>\n")
        with open("WKIT_rename_heads.txt", mode="w", encoding="utf-8") as f_head_out:
            for i, t in enumerate(m_templates):
                if m_templates[t]["slot_category"] == ENR.ENR_GSlotHead:
                    for j, coloring in enumerate(m_templates[t]["colorings"]):
                        if j == 0:
                            vanilla_path = t
                        else:
                            vanilla_path = get_app_template_final_path(t, j, True)
                        custom_path = get_app_template_final_path(t, j)
                        if custom_path in custom_paths:
                            print(f"HEAD DUPLICATE: {custom_path} ({vanilla_path})")
                        custom_paths.add(custom_path)

                        f_head_out.write(f"{vanilla_path}|{custom_path}\n")
                        head_name = friendly_name(custom_path)
                        f_head_xml.write(f'            <item name="{head_name}" category="head" equip_template="{head_name}" ability_mode="OnMount">\n')
                        f_head_xml.write(f'                <!-- {m_templates[t]["name"]} #{j} -->\n')
                        f_head_xml.write(f'                <tags>NoShow,NoDrop,Body</tags>\n')
                        f_head_xml.write(f'                <base_abilities></base_abilities>\n')
                        f_head_xml.write(f'            </item>\n')

        f_head_xml.write("        </items>\n")
        f_head_xml.write("    </definitions>\n")
        f_head_xml.write("</redxml>\n")

    print(f"HEADS XML data saved.")


def string_id(text: str) -> int:
    global m_stringtable, m_stringtable_copies
    if text == "dlc/ep1/data/characters/models/geralt/armor/armor_viper_v2/t_01_mg__viper_v2_meshes.w2ent":
        breakpoint()
    if text not in m_stringtable:
        new_id = len(m_stringtable)
        m_stringtable[text] = new_id
    else:
        m_stringtable_copies += 1

    return m_stringtable[text]


def pre_script(to_section_name: str):
    return f"script_{to_section_name}"


def slot_cam(slot: ENR) -> str:
    if slot == ENR.ENR_GSlotHead:
        return "cam_5_head1"
    elif slot == ENR.ENR_RSlotHair:
        return "cam_5_head1"
    elif slot == ENR.ENR_RSlotBody:
        return "cam_2_body"
    elif slot == ENR.ENR_RSlotTorso:
        return "cam_2_body"
    elif slot == ENR.ENR_RSlotArms:
        return "cam_4_hands"
    elif slot == ENR.ENR_RSlotGloves:
        return "cam_4_hands"
    elif slot == ENR.ENR_RSlotDress:
        return "cam_3_dress"
    elif slot == ENR.ENR_RSlotLegs:
        return "cam_8_legs"
    elif slot == ENR.ENR_RSlotShoes:
        return "cam_8_legs"
    elif slot == ENR.ENR_RSlotMisc:
        return "cam_1_main"
    else:
        return "cam_1_main"


# get section trans name, create dummy if lazy_add and section doesn't exist
def trans(from_section_name: str, to_section_name: str, lazy_add: bool = False):
    global m_scene_yml

    if from_section_name == to_section_name:
        trans_name = f"section_trans_{from_section_name[len('section_'):]}_to_itself"
    else:
        trans_name = f"section_trans_{from_section_name[len('section_'):]}_to_{to_section_name[len('section_'):]}"
    if lazy_add and trans_name not in m_scene_yml["dialogscript"]:
        print(f"Lazy-adding trans: {from_section_name} -> {to_section_name}.")
        add_trans_section(trans_name, to_section_name)

    return trans_name


# get shot trans name
def shot_trans(from_section_name: str, to_section_name: str):
    return f"shot_trans_{from_section_name[len('section_'):]}_to_{to_section_name[len('section_'):]}"


# adds choice to choice_section, to_section is used raw
def add_choice(text: str, from_section_name: str, to_section_name: str, is_exit=False, cond=None):
    global m_scene_yml

    if from_section_name not in m_scene_yml["dialogscript"]:
        print(f"ERROR: {from_section_name} not exists.")

    if to_section_name not in m_scene_yml["dialogscript"]:
        print(f"WARN: {to_section_name} not exists.")

    choice_obj = {
        "choice": flowed([text, to_section_name, "exit"]) if is_exit else flowed([text, to_section_name]),
        "emphasize": True
    }
    if cond:
        choice_obj["condition"] = flowed(cond)

    m_scene_yml["dialogscript"][from_section_name][0]["CHOICE"].append(choice_obj)


# adds formatted choice to choice_section, to_section is used raw
# example: "I{ }like {0000300169}." -> "I&nbsp;like Philippa Eilhart."
def add_choice_formatted(prefix: str, text_str: str, from_section_name: str, to_section_name: str, is_exit: bool = False, cond=None, ignore_missed: bool = False):
    global m_scene_yml

    if from_section_name not in m_scene_yml["dialogscript"]:
        print(f"ERROR: {from_section_name} not exists.")

    if not ignore_missed and to_section_name not in m_scene_yml["dialogscript"]:
        print(f"WARN: {to_section_name} not exists.")

    choice_obj = {
        "choice": flowed([prefix, to_section_name, "exit"]) if is_exit else flowed([prefix, to_section_name]),
        "emphasize": True,
        "scriptAction": {
            ".class": "NR_FormattedLocChoiceAction",
            "str": text_str
        }
    }
    if cond:
        choice_obj["condition"] = flowed(cond)

    m_scene_yml["dialogscript"][from_section_name][0]["CHOICE"].append(choice_obj)


# adds scripted (preview) choice to choice_section, to_section is used raw
def add_choice_scripted(text: str, from_section_name: str, to_section_name: str, template_obj: dict, index: int = 0, variants: int = 0, extra_name_key: str = ""):
    global m_scene_yml

    if from_section_name not in m_scene_yml["dialogscript"]:
        print(f"ERROR: {from_section_name} not exists.")

    if to_section_name not in m_scene_yml["dialogscript"]:
        print(f"WARN: {to_section_name} not exists.")

    choice_obj = {
        "choice": flowed([text, to_section_name]),
        "emphasize": True,
        "scriptAction": {
            ".class": "NR_LocalizedPreviewChoiceAction",
        }
    }

    if "dlc_id" in template_obj:
        choice_obj["scriptAction"]["dlc_id"] = template_obj["dlc_id"]

    if "dlc_name_key" in template_obj:
        choice_obj["scriptAction"]["dlc_name_key"] = template_obj["dlc_name_key"]

    if "nameID" in template_obj and template_obj["name"] != "_skip_":
        if template_obj["nameID"] == 1:
            choice_obj["scriptAction"]["prefix_name_key"] = template_obj["name"]
        else:
            choice_obj["scriptAction"]["prefix_id"] = template_obj["nameID"]

    if "extraKey" in template_obj:
        choice_obj["scriptAction"]["extra_name_key"] = template_obj["extraKey"]
    elif extra_name_key:
        choice_obj["scriptAction"]["extra_name_key"] = extra_name_key

    if index > 0:
        choice_obj["scriptAction"]["index"] = index

    if variants > 0:
        choice_obj["scriptAction"]["variants"] = variants

    m_scene_yml["dialogscript"][from_section_name][0]["CHOICE"].append(choice_obj)


# adds CHOICE section with self-trans section
# 1 cam = static cam, 2 cams = blend, 3 cams = blend in center and back
def add_choice_section(section_name: str, cams=None):
    global m_scene_yml

    trans_name = trans(section_name, section_name)
    if trans_name in m_scene_yml["dialogscript"]:
        print(f"WARN: {trans_name} exists.")

    m_scene_yml["dialogscript"][trans_name] = CommentedSeq([
        {
            "PAUSE": 0.0
        },
        {
            "NEXT": section_name
        }
    ])
    m_scene_yml["dialogscript"].yaml_set_comment_before_after_key(trans_name, before="\n")

    if section_name in m_scene_yml["dialogscript"]:
        print(f"WARN: {section_name} exists.")

    m_scene_yml["dialogscript"][section_name] = CommentedSeq([
        {
            "CHOICE": []
        }
    ])
    m_scene_yml["dialogscript"].yaml_set_comment_before_after_key(section_name, before="\n")
    if cams:
        shot_name = section_name.replace("section_", "shot_")
        events = []
        if len(cams) == 1:
            events = [
                {
                    "cam": flowed([0.0, cams[0]])
                }
            ]
        elif len(cams) == 2:
            events = [
                {
                    "cam.blend.start": flowed([0.0, cams[0], "smooth"])
                },
                {
                    "cam.blend.end": flowed([0.999, cams[1], "smooth"])
                }
            ]
        elif len(cams) == 3:
            events = [
                {
                    "cam.blend.start": flowed([0.0, cams[0], "smooth"])
                },
                {
                    "cam.blend.end": flowed([0.48, cams[1], "smooth"])
                },
                {
                    "cam.blend.start": flowed([0.52, cams[1], "smooth"])
                },
                {
                    "cam.blend.end": flowed([0.98, cams[2], "smooth"])
                }
            ]
        else:
            print(f"ERROR: unusual cam num {len(cams)}: {section_name}")

        m_scene_yml["storyboard"][section_name] = CommentedMap({
            shot_name: events
        })
        m_scene_yml["storyboard"].yaml_set_comment_before_after_key(section_name, before="\n")


# adds transition section, NEXT is used raw
# 1 cam = static cam, 2 cams = blend, 3 cams = blend in center and back
def add_trans_section(section_name: str, next_section_name: str, cams=None):
    global m_scene_yml

    if section_name in m_scene_yml["dialogscript"]:
        print(f"WARN: {section_name} exists.")

    if cams:
        shot_name = section_name.replace("section_", "shot_")
        events = []
        if len(cams) == 2:
            events = [
                {
                    "cam.blend.start": flowed([0.0, cams[0], "smooth"])
                },
                {
                    "cam.blend.end": flowed([0.999, cams[1], "smooth"])
                }
            ]
        else:
            print(f"ERROR: unusual cam num {len(cams)}: {section_name}")

        m_scene_yml["dialogscript"][section_name] = CommentedSeq([
            {
                "CUE": shot_name
            },
            {
                "PAUSE": 0.5
            },
            {
                "NEXT": next_section_name
            }
        ])
        m_scene_yml["storyboard"][section_name] = CommentedMap({
            shot_name: events
        })
        m_scene_yml["storyboard"].yaml_set_comment_before_after_key(section_name, before="\n")
        m_scene_yml["dialogscript"].yaml_set_comment_before_after_key(section_name, before="\n")
    else:
        m_scene_yml["dialogscript"][section_name] = CommentedSeq([
            {
                "PAUSE": 0.0
            },
            {
                "NEXT": next_section_name
            }
        ])
        m_scene_yml["dialogscript"].yaml_set_comment_before_after_key(section_name, before="\n")


# adds pre script section, NEXT is raw
def add_pre_script_section(script_section_name: str, next_section_name: str, data_index: int, choice_offset: int):
    global m_scene_yml

    if script_section_name in m_scene_yml["dialogscript"]:
        print(f"WARN: {script_section_name} exists.")

    if next_section_name not in m_scene_yml["dialogscript"]:
        print(f"WARN: {next_section_name} not exists.")

    m_scene_yml["dialogscript"][script_section_name] = CommentedSeq([
        {
            "SCRIPT": {
                "function": "NR_SetPreviewDataIndex_S",
                "parameter": [
                    {
                        "data_index": data_index
                    },
                    {
                        "choice_offset": choice_offset
                    }
                ]
            }
        },
        {
            "NEXT": next_section_name
        }
    ])
    m_scene_yml["dialogscript"].yaml_set_comment_before_after_key(script_section_name, before="\n")


# adds custom script section, NEXT is raw
def add_custom_script_section(script_section_name: str, next_section_name: str, function_name: str, params: list):
    global m_scene_yml

    if script_section_name in m_scene_yml["dialogscript"]:
        print(f"WARN: {script_section_name} exists.")

    if next_section_name not in m_scene_yml["dialogscript"]:
        print(f"WARN: {next_section_name} not exists.")

    m_scene_yml["dialogscript"][script_section_name] = CommentedSeq([
        {
            "SCRIPT": {
                "function": function_name,
                "parameter": params
            }
        },
        {
            "NEXT": next_section_name
        }
    ])
    m_scene_yml["dialogscript"].yaml_set_comment_before_after_key(script_section_name, before="\n")


def CNAME(value: str):
    return f"CNAME_{value}"


def quoted(text: str):
    return yaml.scalarstring.DoubleQuotedScalarString(text)


def STR_quoted(text: STR) -> str:
    return quoted(f"{text.value}|{text.name}")


def flowed(seq: list):
    ret = comments.CommentedSeq(seq)
    ret.fa.set_flow_style()
    return ret


def create_scene(gender: EG):
    global m_scene_yml, m_templates, m_templates_by_cats, m_selector_yml, m_localized_names
    with open(f"{m_FOLDER}/scene.01.player_change_BASE.yml", mode="r", encoding="utf-8") as f_yml:
        start_t = time.time()
        m_scene_yml = yaml.load(f_yml, Loader=yaml.RoundTripLoader, preserve_quotes=True)
        end_t = time.time()
        print(f"Scene YML loaded in: {end_t - start_t} s")

    selector_nodes = m_selector_yml["templates"]["nr_scene_selector"]["entityObject"]["m_nodesMale" if gender == EG.EG_Male else "m_nodesFemale"]

    # Create display name selection
    valid_npc_cats = []
    for i, npc_cat in enumerate(EAN):
        if npc_cat in m_localized_names and len(m_localized_names[npc_cat]) > 0:
            valid_npc_cats.append(npc_cat)
            cat_section_name = f"section_choice_player_display_name_{friendly_npc_category(npc_cat, short=True)}"
            add_choice_section(section_name=cat_section_name)
            add_choice(STR_quoted(str_npc_category(npc_cat)), "section_choice_player_display_name", cat_section_name)
            add_choice(STR_quoted(STR.BACK), cat_section_name, "section_choice_player_display_name", is_exit=True)

    for i, npc_cat in enumerate(valid_npc_cats):
        cat_section_name = f"section_choice_player_display_name_{friendly_npc_category(npc_cat, short=True)}"
        next_npc_cat = valid_npc_cats[(i + 1) % len(valid_npc_cats)]
        next_cat_section_name = f"section_choice_player_display_name_{friendly_npc_category(next_npc_cat, short=True)}"
        add_choice_formatted(quoted(f"{STR.DOT.value}|.[Next category: {next_npc_cat.name}]"), quoted(f"[{{368969}}: {{{str_npc_category(next_npc_cat)}}}]"), cat_section_name, next_cat_section_name, ignore_missed=True)
        for j, nameID in enumerate(m_localized_names[npc_cat]):
            script_section_name = f"script_set_display_name_{friendly_npc_category(next_npc_cat, short=True)}_{nameID}"
            add_custom_script_section(script_section_name, trans(cat_section_name, cat_section_name), "NR_SetPlayerDisplayName_S", [
                {
                    "nameID": int(nameID)
                }
            ])
            while len(nameID) < 10:
                nameID = "0" + nameID

            add_choice(quoted(f"{nameID}|"), cat_section_name, script_section_name)

        print(f"[*] Added display name variants[{npc_cat.name}] = {len(m_localized_names[npc_cat])}")

    # Create slot templates in section_choice_player_appearance
    valid_slots = []
    for slot in ENR:
        if not is_valid_slot_category(slot):
            continue
        valid_slots.append(slot)
    for i, slot in enumerate(valid_slots):
        slot_section_name = f"section_choice_{friendly_slot_category(slot)}"

        preview_cams = []
        if slot in {ENR.ENR_GSlotHead, ENR.ENR_RSlotHair}:
            preview_cams = ["cam_5_head1", "cam_5_head1_rotate", "cam_5_head1"]

        add_choice_section(section_name=slot_section_name, cams=preview_cams)

        # to slot and back
        add_trans_section(trans("section_choice_player_appearance", slot_section_name), slot_section_name, cams=["cam_1_main", slot_cam(slot)])
        add_choice(quoted(f"SLOT: {friendly_slot_category(slot).capitalize()}"), "section_choice_player_appearance",
                   trans("section_choice_player_appearance", slot_section_name))
        add_trans_section(trans(slot_section_name, "section_choice_player_appearance"), "section_choice_player_appearance", cams=[slot_cam(slot), "cam_1_main"])
        add_choice(STR_quoted(STR.BACK), slot_section_name, trans(slot_section_name, "section_choice_player_appearance"), is_exit=True)

        # clear slot
        add_custom_script_section(f"script_clear_{friendly_slot_category(slot)}", trans(slot_section_name, slot_section_name), "NR_ClearAppearanceSlot_S", params=[
            {
                "slot_index": slot.value
            }
        ])
        add_choice(STR_quoted(STR.CLEAR_SLOT), slot_section_name, f"script_clear_{friendly_slot_category(slot)}")

        # to next slot
        next_slot = valid_slots[(i + 1) % len(valid_slots)]
        next_section_name = f"section_choice_{friendly_slot_category(next_slot)}"
        add_trans_section(trans(slot_section_name, next_section_name), next_section_name, cams=[slot_cam(slot), slot_cam(next_slot)])
        add_choice(quoted(f"[Next Slot: {friendly_slot_category(next_slot).capitalize()}]"), slot_section_name, trans(slot_section_name, next_section_name))

        # add categories
        valid_npc_cats = []
        for npc_cat in EAN:
            if len(m_templates_by_cats[gender][slot][npc_cat]) > 0:
                valid_npc_cats.append(npc_cat)

        for j, npc_cat in enumerate(valid_npc_cats):
            cat_section_name = f"section_choice_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat, True)}"
            add_choice_section(cat_section_name, cams=preview_cams)
            cat_script_name = f"script_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat, True)}"

            selector_nodes.append({
                ".type": "NR_SceneNode",
                "m_onPreviewChoice": CommentedSeq()
            })
            selector_node_index = len(selector_nodes) - 1
            selector_nodes.yaml_set_comment_before_after_key(selector_node_index, before=f"node index = {selector_node_index}", indent=8)
            add_custom_script_section(cat_script_name, trans(cat_section_name, cat_section_name), "NR_SetPreviewDataIndex_S", [
                {
                    "data_index": selector_node_index
                },
                {
                    "choice_offset": 2,  # BACK, NEXT CAT
                }
            ])

            # to npc category and back
            add_choice(STR_quoted(str_npc_category(npc_cat)), slot_section_name, cat_script_name)
            add_choice(STR_quoted(STR.BACK), cat_section_name, slot_section_name, is_exit=True)

            # to next category
            next_npc_cat = valid_npc_cats[(j + 1) % len(valid_npc_cats)]
            next_cat_script_name = f"script_{friendly_slot_category(slot)}_{friendly_npc_category(next_npc_cat, True)}"
            add_choice_formatted(quoted(f"{STR.DOT.value}|.[Next category: {next_npc_cat.name}]"), quoted(f"[{{368969}}: {{{str_npc_category(next_npc_cat)}}}]"), cat_section_name, next_cat_script_name, ignore_missed=True)
            sub_cnt = 0

            # add preview subsection and preview leaves
            for k, path in enumerate(m_templates_by_cats[gender][slot][npc_cat]):
                t_data = m_templates[path]

                if len(t_data["colorings"]) > 2:
                    # Add preview subsection
                    sub_cnt += 1
                    subcat_section_name = f"section_choice_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat, True)}_sub{sub_cnt}"
                    add_choice_section(subcat_section_name, cams=preview_cams)
                    subcat_script_name = f"script_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat, True)}_sub{sub_cnt}"

                    selector_nodes.append({
                        ".type": "NR_SceneNode",
                        "m_onPreviewChoice": CommentedSeq()
                    })
                    subcat_selector_node_index = len(selector_nodes) - 1
                    selector_nodes.yaml_set_comment_before_after_key(subcat_selector_node_index, before=f"(sub)node index = {subcat_selector_node_index}", indent=8)
                    add_custom_script_section(subcat_script_name, trans(subcat_section_name, subcat_section_name), "NR_SetPreviewDataIndex_S", [
                        {
                            "data_index": subcat_selector_node_index
                        },
                        {
                            "choice_offset": 1,  # BACK
                        }
                    ])

                    # Add BACK to cat
                    add_choice(STR_quoted(STR.BACK), subcat_section_name, cat_script_name, is_exit=True)

                    # Add choice link itself
                    variants_cnt = len(t_data["colorings"]) - 1
                    add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{t_data['name']}: {variants_cnt} variants"), from_section_name=cat_section_name, to_section_name=subcat_script_name,
                                        template_obj=t_data, variants=variants_cnt)
                    selector_nodes[selector_node_index]["m_onPreviewChoice"].append(
                        {
                            ".type": "NR_ScenePreviewData",
                            "m_slots": flowed([slot.value]),
                            "m_flags": SPF.ENR_SPDontSaveOnAccept.value
                        }
                    )

                    # Add 1st coloring for preview
                    first_path = get_app_template_final_path(path, 1)
                    if slot == ENR.ENR_GSlotHead:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][-1]["m_headName"] = friendly_name(first_path)
                    else:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][-1]["m_pathIDs"] = flowed([string_id(first_path)])

                    for coloring_index, coloring in enumerate(t_data["colorings"]):
                        if coloring_index == 0:
                            continue
                        # Add preview leaf
                        final_path = get_app_template_final_path(path, coloring_index)
                        add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{t_data['name']}: {friendly_name(path)} #{coloring_index}"), from_section_name=subcat_section_name, to_section_name=subcat_script_name,
                                            template_obj=t_data, index=coloring_index)
                        selector_nodes[subcat_selector_node_index]["m_onPreviewChoice"].append(
                            {
                                ".type": "NR_ScenePreviewData",
                                "m_slots": flowed([slot.value])
                            }
                        )
                        subcat_selector_choice_index = len(selector_nodes[subcat_selector_node_index]["m_onPreviewChoice"]) - 1
                        selector_nodes[subcat_selector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(subcat_selector_choice_index, before=f"(sub)choice index = {subcat_selector_choice_index}", indent=12)

                        if slot == ENR.ENR_GSlotHead:
                            selector_nodes[subcat_selector_node_index]["m_onPreviewChoice"][subcat_selector_choice_index]["m_headName"] = friendly_name(final_path)
                        else:
                            selector_nodes[subcat_selector_node_index]["m_onPreviewChoice"][subcat_selector_choice_index]["m_pathIDs"] = flowed([string_id(final_path)])

                else:
                    # Add preview leaf
                    coloring_index = len(t_data["colorings"]) - 1
                    # no colorings (0) or one coloring, ignore non-colored version (1)
                    final_path = get_app_template_final_path(path, coloring_index)

                    add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{t_data['name']}: {t_data['extraKey']} #{coloring_index}"), from_section_name=cat_section_name, to_section_name=cat_script_name,
                                        template_obj=t_data, index=coloring_index)

                    selector_nodes[selector_node_index]["m_onPreviewChoice"].append(
                        {
                            ".type": "NR_ScenePreviewData",
                            "m_slots": flowed([slot.value])
                        }
                    )
                    selector_choice_index = len(selector_nodes[selector_node_index]["m_onPreviewChoice"]) - 1
                    selector_nodes[selector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(selector_choice_index, before=f"choice index = {selector_choice_index}", indent=12)

                    if slot == ENR.ENR_GSlotHead:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_headName"] = friendly_name(final_path)
                    else:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"] = flowed([string_id(final_path)])

    # Create geralt armor sets in section_geralt_sets
    script_name_armor_main = "script_geralt_armor_sets"
    section_name_armor_main = "section_choice_geralt_armor_sets"
    add_choice_section(section_name_armor_main)
    add_choice(STR_quoted(STR.BACK), section_name_armor_main, "section_choice_player_appearance", is_exit=True)

    selector_nodes.append({
        ".type": "NR_SceneNode",
        "m_onPreviewChoice": CommentedSeq()
    })
    selector_node_index = len(selector_nodes) - 1
    selector_nodes.yaml_set_comment_before_after_key(selector_node_index, before=f"node index = {selector_node_index}", indent=8)
    add_custom_script_section(script_name_armor_main, trans(section_name_armor_main, section_name_armor_main), "NR_SetPreviewDataIndex_S", [
        {
            "data_index": selector_node_index
        },
        {
            "choice_offset": 1,  # BACK
        }
    ])

    for i, armor_set_name in enumerate(m_npc_by_cats[gender][EAN.EAN_ArmorSet]):
        # print(f"Add armor set: {armor_set_name}")
        npc_data = m_npc_data[armor_set_name]
        # duplicate of NPC sets code below
        app_cnt = len(npc_data["appearances"])
        if app_cnt > 1:
            # add preview using 1st app
            npc_app_name = list(m_npc_data[armor_set_name]["appearances"].keys())[0]
            app = m_npc_data[armor_set_name]["appearances"][npc_app_name]
            selector_nodes[selector_node_index]["m_onPreviewChoice"].append(
                {
                    ".type": "NR_ScenePreviewData",
                    "m_flags": m_npc_data[armor_set_name].get("selector_flag", SPF.ENR_SPForceUnloadAll.value) | SPF.ENR_SPDontSaveOnAccept.value,
                    "m_slots": flowed([]),
                    "m_pathIDs": flowed([])
                }
            )
            selector_choice_index = len(selector_nodes[selector_node_index]["m_onPreviewChoice"]) - 1
            selector_nodes[selector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(selector_choice_index, before=f"choice index = {selector_choice_index}", indent=12)

            # fill slots for 1st app
            for m, slot in enumerate(app):
                if not app[slot]:
                    continue

                if slot == ENR.ENR_GSlotHead:
                    selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_headName"] = friendly_name(app[slot])
                elif slot == ENR.ENR_RSlotMisc:
                    for n, item_path in enumerate(app[slot]):
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(item_path))
                else:
                    selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                    selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(app[slot]))

            # create subsection
            subcat_section_name = f"section_choice_geralt_armor_sets_{friendly_npc_name(armor_set_name)}"
            subcat_script_name = f"script_geralt_armor_sets_{friendly_npc_name(armor_set_name)}"
            add_choice_section(subcat_section_name)
            selector_nodes.append({
                ".type": "NR_SceneNode",
                "m_onPreviewChoice": CommentedSeq()
            })
            subselector_node_index = len(selector_nodes) - 1
            selector_nodes.yaml_set_comment_before_after_key(subselector_node_index, before=f"(sub)node index = {subselector_node_index}", indent=8)
            add_custom_script_section(subcat_script_name, trans(subcat_section_name, subcat_section_name), "NR_SetPreviewDataIndex_S", [
                {
                    "data_index": subselector_node_index
                },
                {
                    "choice_offset": 1,  # BACK
                }
            ])

            add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: {app_cnt} variants"), from_section_name=section_name_armor_main, to_section_name=subcat_script_name,
                                template_obj=npc_data, variants=app_cnt)

            add_choice(STR_quoted(STR.BACK), subcat_section_name, script_name_armor_main, is_exit=True)

            # fill preview choice for every app
            for l, npc_app_name in enumerate(m_npc_data[armor_set_name]["appearances"]):
                app = m_npc_data[armor_set_name]["appearances"][npc_app_name]
                selector_nodes[subselector_node_index]["m_onPreviewChoice"].append(
                    {
                        ".type": "NR_ScenePreviewData",
                        "m_flags": m_npc_data[armor_set_name].get("selector_flag", SPF.ENR_SPForceUnloadAll.value),
                        "m_slots": flowed([]),
                        "m_pathIDs": flowed([])
                    }
                )
                subselector_choice_index = len(selector_nodes[subselector_node_index]["m_onPreviewChoice"]) - 1
                selector_nodes[subselector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(subselector_choice_index, before=f"(sub)choice index = {subselector_choice_index}", indent=12)

                #if npc_app_name.startswith("dye_"):
                #    add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: #{l}"), from_section_name=subcat_section_name, to_section_name=subcat_script_name,
                #                template_obj=npc_data, index=l)
                #else:
                add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: #{l}"), from_section_name=subcat_section_name, to_section_name=subcat_script_name,
                                    template_obj=npc_data, extra_name_key=npc_app_name)
                # fill slots for app
                for m, slot in enumerate(app):
                    if not app[slot]:
                        continue

                    if slot == ENR.ENR_GSlotHead:
                        selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_headName"] = friendly_name(app[slot])
                    elif slot == ENR.ENR_RSlotMisc:
                        for n, item_path in enumerate(app[slot]):
                            selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_slots"].append(slot.value)
                            selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_pathIDs"].append(string_id(item_path))
                    else:
                        selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_slots"].append(slot.value)
                        selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_pathIDs"].append(string_id(app[slot]))
        else:
            # Add leaf choice preview
            npc_app_name = list(m_npc_data[armor_set_name]["appearances"].keys())[0]
            app = m_npc_data[armor_set_name]["appearances"][npc_app_name]
            selector_nodes[selector_node_index]["m_onPreviewChoice"].append(
                {
                    ".type": "NR_ScenePreviewData",
                    "m_flags": m_npc_data[armor_set_name].get("selector_flag", SPF.ENR_SPForceUnloadAll.value),
                    "m_slots": flowed([]),
                    "m_pathIDs": flowed([])
                }
            )
            selector_choice_index = len(selector_nodes[selector_node_index]["m_onPreviewChoice"]) - 1
            selector_nodes[selector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(selector_choice_index, before=f"choice index = {selector_choice_index}", indent=12)

            add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: {npc_app_name}"), from_section_name=section_name_armor_main, to_section_name=script_name_armor_main,
                                template_obj=npc_data, extra_name_key=npc_app_name)

            # fill slots for app
            for m, slot in enumerate(app):
                if not app[slot]:
                    continue

                if slot == ENR.ENR_GSlotHead:
                    selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_headName"] = friendly_name(app[slot])
                elif slot == ENR.ENR_RSlotMisc:
                    for n, item_path in enumerate(app[slot]):
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(item_path))
                else:
                    selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                    selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(app[slot]))
    print(f"Added armor sets: {len(m_npc_by_cats[gender][EAN.EAN_ArmorSet])}")

    # Create NPC sets in section_npcs_main
    main_sets_section = "section_choice_npcs_main"
    add_choice_section(main_sets_section)
    add_choice(STR_quoted(STR.BACK), main_sets_section, "section_choice_player_appearance", is_exit=True)
    valid_npc_cats = []
    for npc_cat in EAN:
        if npc_cat != EAN.EAN_ArmorSet and len(m_npc_by_cats[gender][npc_cat]) > 0:
            valid_npc_cats.append(npc_cat)

    for j, npc_cat in enumerate(valid_npc_cats):
        cat_section_name = f"section_choice_npcs_{friendly_npc_category(npc_cat, True)}"
        cat_script_name = f"script_npcs_{friendly_npc_category(npc_cat, True)}"
        add_choice_section(cat_section_name)
        selector_nodes.append({
            ".type": "NR_SceneNode",
            "m_onPreviewChoice": CommentedSeq()
        })
        selector_node_index = len(selector_nodes) - 1
        selector_nodes.yaml_set_comment_before_after_key(selector_node_index, before=f"node index = {selector_node_index}", indent=8)
        add_custom_script_section(cat_script_name, trans(cat_section_name, cat_section_name), "NR_SetPreviewDataIndex_S", [
            {
                "data_index": selector_node_index
            },
            {
                "choice_offset": 2,  # BACK, NEXT CAT
            }
        ])

        # to npc category and back
        add_choice(STR_quoted(str_npc_category(npc_cat)), main_sets_section, cat_script_name)
        add_choice(STR_quoted(STR.BACK), cat_section_name, main_sets_section, is_exit=True)

        # to next category
        next_npc_cat = valid_npc_cats[(j + 1) % len(valid_npc_cats)]
        next_cat_script_name = f"script_npcs_{friendly_npc_category(next_npc_cat, True)}"
        add_choice_formatted(quoted(f"{STR.DOT.value}|.[Next category: {next_npc_cat.name}]"), quoted(f"[{{368969}}: {{{str_npc_category(next_npc_cat)}}}]"), cat_section_name, next_cat_script_name, ignore_missed=True)

        for k, npc_name in enumerate(m_npc_by_cats[gender][npc_cat]):
            npc_data = m_npc_data[npc_name]
            app_cnt = len(npc_data["appearances"])
            if app_cnt > 1:
                # add preview using 1st app
                npc_app_name = list(m_npc_data[npc_name]["appearances"].keys())[0]
                app = m_npc_data[npc_name]["appearances"][npc_app_name]
                selector_nodes[selector_node_index]["m_onPreviewChoice"].append(
                    {
                        ".type": "NR_ScenePreviewData",
                        "m_flags": m_npc_data[npc_name].get("selector_flag", SPF.ENR_SPForceUnloadAll.value) | SPF.ENR_SPDontSaveOnAccept.value,
                        "m_slots": flowed([]),
                        "m_pathIDs": flowed([])
                    }
                )
                selector_choice_index = len(selector_nodes[selector_node_index]["m_onPreviewChoice"]) - 1
                selector_nodes[selector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(selector_choice_index, before=f"choice index = {selector_choice_index}", indent=12)

                # fill slots for 1st app
                for m, slot in enumerate(app):
                    if not app[slot]:
                        continue

                    if slot == ENR.ENR_GSlotHead:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_headName"] = friendly_name(app[slot])
                    elif slot == ENR.ENR_RSlotMisc:
                        for n, item_path in enumerate(app[slot]):
                            selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                            selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(item_path))
                    else:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(app[slot]))

                # create subsection
                subcat_section_name = f"section_choice_npcs_{friendly_npc_category(npc_cat, True)}_{friendly_npc_name(npc_name)}"
                subcat_script_name = f"script_npcs_{friendly_npc_category(npc_cat, True)}_{friendly_npc_name(npc_name)}"
                add_choice_section(subcat_section_name)
                selector_nodes.append({
                    ".type": "NR_SceneNode",
                    "m_onPreviewChoice": CommentedSeq()
                })
                subselector_node_index = len(selector_nodes) - 1
                selector_nodes.yaml_set_comment_before_after_key(subselector_node_index, before=f"(sub)node index = {subselector_node_index}", indent=8)
                add_custom_script_section(subcat_script_name, trans(subcat_section_name, subcat_section_name), "NR_SetPreviewDataIndex_S", [
                    {
                        "data_index": subselector_node_index
                    },
                    {
                        "choice_offset": 1,  # BACK
                    }
                ])

                add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: {app_cnt} variants"), from_section_name=cat_section_name, to_section_name=subcat_script_name,
                                    template_obj=npc_data, variants=app_cnt)

                add_choice(STR_quoted(STR.BACK), subcat_section_name, cat_script_name, is_exit=True)

                # fill preview choice for every app
                for l, npc_app_name in enumerate(m_npc_data[npc_name]["appearances"]):
                    app = m_npc_data[npc_name]["appearances"][npc_app_name]
                    selector_nodes[subselector_node_index]["m_onPreviewChoice"].append(
                        {
                            ".type": "NR_ScenePreviewData",
                            "m_flags": m_npc_data[npc_name].get("selector_flag", SPF.ENR_SPForceUnloadAll.value),
                            "m_slots": flowed([]),
                            "m_pathIDs": flowed([])
                        }
                    )
                    subselector_choice_index = len(selector_nodes[subselector_node_index]["m_onPreviewChoice"]) - 1
                    selector_nodes[subselector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(subselector_choice_index, before=f"(sub)choice index = {subselector_choice_index}", indent=12)

                    #if npc_app_name.startswith("dye_"):
                    #    add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: #{l}"), from_section_name=subcat_section_name, to_section_name=subcat_script_name,
                    #                template_obj=npc_data, index=l)
                    #else:
                    add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: #{l}"), from_section_name=subcat_section_name, to_section_name=subcat_script_name,
                                        template_obj=npc_data, extra_name_key=npc_app_name)
                    # fill slots for app
                    for m, slot in enumerate(app):
                        if not app[slot]:
                            continue

                        if slot == ENR.ENR_GSlotHead:
                            selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_headName"] = friendly_name(app[slot])
                        elif slot == ENR.ENR_RSlotMisc:
                            for n, item_path in enumerate(app[slot]):
                                selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_slots"].append(slot.value)
                                selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_pathIDs"].append(string_id(item_path))
                        else:
                            selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_slots"].append(slot.value)
                            selector_nodes[subselector_node_index]["m_onPreviewChoice"][subselector_choice_index]["m_pathIDs"].append(string_id(app[slot]))

            else:
                # Add leaf choice preview
                npc_app_name = list(m_npc_data[npc_name]["appearances"].keys())[0]
                app = m_npc_data[npc_name]["appearances"][npc_app_name]
                selector_nodes[selector_node_index]["m_onPreviewChoice"].append(
                    {
                        ".type": "NR_ScenePreviewData",
                        "m_flags": m_npc_data[npc_name].get("selector_flag", SPF.ENR_SPForceUnloadAll.value),
                        "m_slots": flowed([]),
                        "m_pathIDs": flowed([])
                    }
                )
                selector_choice_index = len(selector_nodes[selector_node_index]["m_onPreviewChoice"]) - 1
                selector_nodes[selector_node_index]["m_onPreviewChoice"].yaml_set_comment_before_after_key(selector_choice_index, before=f"choice index = {selector_choice_index}", indent=12)

                add_choice_scripted(text=quoted(f"{STR.DOT.value}|.{npc_data['name']}: {npc_app_name}"), from_section_name=cat_section_name, to_section_name=cat_script_name,
                                    template_obj=npc_data, extra_name_key=npc_app_name)

                # fill slots for app
                for m, slot in enumerate(app):
                    if not app[slot]:
                        continue

                    if slot == ENR.ENR_GSlotHead:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_headName"] = friendly_name(app[slot])
                    elif slot == ENR.ENR_RSlotMisc:
                        for n, item_path in enumerate(app[slot]):
                            selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                            selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(item_path))
                    else:
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_slots"].append(slot.value)
                        selector_nodes[selector_node_index]["m_onPreviewChoice"][selector_choice_index]["m_pathIDs"].append(string_id(app[slot]))
        print(f"Added npc sets[{npc_cat.name}]: {len(m_npc_by_cats[gender][npc_cat])}")

    write_yml_nicely(f"{m_FOLDER}/scene.01.player_change_{'male' if gender == EG.EG_Male else 'female'}.yml", m_scene_yml)


def write_selector_file():
    global m_selector_yml, m_stringtable, m_stringtable_copies

    for i, key in enumerate(m_stringtable):
        if m_stringtable[key] != i:
            print(f"STRINGTABLE ERROR: i = {i}, key = {key}, val = {m_stringtable[key]}")
        x = 1
        m_selector_yml["templates"]["nr_scene_selector"]["entityObject"]["m_stringtable"].append(key)

    print(f"Stringtable size = {len(m_stringtable)}, copies = {m_stringtable_copies}")
    write_yml_nicely(f"{m_FOLDER}/def.entities.nr_selector.yml", m_selector_yml)


# make paths relative to depot
# rename \ -> /
# rename <tab> -> <spaces>
# rename x.w2rig -> x
# fix quests/part_1/quest_files/q205_frozen_coast/characters/q205_wild_hunt_elf_riders.w2ent
# remove all except _10 app in Anna Henrietta
# fix ""
# replace: dlc/bob/data/characters/models/main_npc/oriana/body_01_wa__oriana.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/body_01_wa__oriana.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_03_wa__bob_woman_noble.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/d_03_wa__bob_woman_noble_px.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_06_wa__bob_woman_noble_px.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/d_06_wa__bob_woman_noble_px.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_06_wa__bob_woman_noble_px_p02.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/d_06_wa__bob_woman_noble_px_p02.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_06_wa__bob_woman_noble_px_p03.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/d_06_wa__bob_woman_noble_px_p03.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/torso/t2_07_wa__bob_woman_noble_p01.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/t2_07_wa__bob_woman_noble_p01.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/torso/t2_07_wa__bob_woman_noble_p02.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/t2_07_wa__bob_woman_noble_p02.w2ent
# replace: dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/torso/t2_07b_wa__bob_woman_noble_p02.w2ent -> dlc/dlcnewreplacers/data/entities/woman_fixed/t2_07b_wa__bob_woman_noble_p02.w2ent
# pre_filter_templates()
write_localized_names()
load_data()
write_coloring_files()
write_rename_head_files()
create_scene(EG.EG_Male)
create_scene(EG.EG_Female)
write_selector_file()
