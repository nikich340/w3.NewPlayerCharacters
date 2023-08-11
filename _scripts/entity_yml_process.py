try:
    import ruamel.yaml.scalarstring
    from ruamel import yaml
    from ruamel.yaml import comments, CommentedMap, CommentedSeq
except:
    import yaml
import json
import time
import enum
from strenum import StrEnum
import re
from pathlib import Path
from frozendict import frozendict

m_convert_json = True
m_save_yml = True
m_save_json = True
m_DLC_DATA = "dlc/dlcnewreplacers/data"
m_FOLDER = "D:/w3.modding/w3.projects/w3.NEW_REPLACERS/_pyscripts"


# rig category
class EG(enum.IntEnum):
    EG_None = 0
    EG_Male = 1
    EG_Female = 2
    EG_Any = 3


# npc category
class EAN(enum.IntEnum):
    EAN_Unknown = 0
    EAN_DLCCustom = 1
    EAN_DLCSecondary = 2
    EAN_VanillaSecondary = 3
    EAN_DLCMain = 4
    EAN_VanillaMain = 5


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
    ENR_SPForceUnloadSlotTemplates = 2


class STR(StrEnum):
    BACK = "2115940103"
    DOT = "0001107617"
    CLEAR_SLOT = "2115940104"
    CAT_DLC_Custom = "2115940089"
    CAT_DLC_Main = "2115940090"
    CAT_DLC_Secondary = "2115940091"
    CAT_Vanilla_Main = "2115940092"
    CAT_Vanilla_Secondary = "2115940093"


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


def category2(path: str, tryMore: bool):
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


def app_template_name(app_template: str, app_template_colorings: dict):
    global m_app_template_colorings
    if not app_template_colorings:
        return app_template

    if not app_template in m_app_template_colorings:
        m_app_template_colorings[app_template] = []
    if not app_template_colorings in m_app_template_colorings[app_template]:
        m_app_template_colorings[app_template].append(app_template_colorings)
    return f"{m_DLC_DATA}/entities/coloring/{friendly_name(app_template)}_coloring_{m_app_template_colorings[app_template].index(app_template_colorings)}.w2ent"


def add_app_template_variant(app_template: str, npc_nameID: int, npc_category: ENR, app_name: str,
                             l_app_template_colorings: dict):
    global m_app_template_data
    # [app_t] = [slot, dict[coloring] = [npc_name_id, category, app_name, colorings]]
    if app_template not in m_app_template_data:
        m_app_template_data[app_template] = [category(app_template), dict(), dict()]

    key_str = "K"
    for comp in sorted(l_app_template_colorings.keys()):
        key_str += f"{comp}"
        for comp_coloring in l_app_template_colorings[comp]:
            key_str += f"{comp_coloring}"
    # print(f"KEY: {key_str}")
    m_app_template_data[app_template][1][key_str] = [npc_nameID, npc_category, app_name, l_app_template_colorings]


def base_template(path: str, root: bool):
    global yml
    if path in m_base_templates:
        return m_base_templates[path]

    m_base_templates[path] = str()
    if category2(path, False) != EAN.EAN_Unknown:
        m_base_templates[path] = path
    else:
        if "includes" in yml["templates"][path]:
            for i in yml["templates"][path]["includes"]:
                res = base_template(i, False)
                if res:
                    m_base_templates[path] = res
                    break
    if root and not m_base_templates[path] and path.find("quests/") >= 0:
        m_base_templates[path] = path
    return m_base_templates[path]


def test_templates(path: str):
    global yml
    if "appearances" in yml["templates"][path] and category2(path, False) == EAN.EAN_Unknown:
        p = path
        while "includes" in yml["templates"][p]:
            p = yml["templates"][p]["includes"][0]
            if p not in yml["templates"]:
                print(f"[-] Template not found! {p}")
                break
            if "appearances" not in yml["templates"][p]:
                # print(f"[-] Appearances not in parent [{p}] of {path}")
                continue
            for app in yml["templates"][path]["appearances"]:
                if app not in yml["templates"][p]["appearances"]:
                    # print(f"[-] Appearance {app} not in parent [{p}] of {path}")
                    continue
                if yml["templates"][p]["appearances"][app]["templates"] != yml["templates"][path]["appearances"][app][
                    "templates"]:
                    print(f"[---] Appearance TEMPLATES {app} != parent [{p}] of {path}")
                    print(
                        f'    {yml["templates"][p]["appearances"][app]["templates"]} != {yml["templates"][path]["appearances"][app]["templates"]}')
                    continue

                if "coloring" in yml["templates"][path]["appearances"][app]:
                    if "coloring" not in yml["templates"][p]["appearances"][app]:
                        # print(f"[-] Missed COLORING {app} in parent [{p}] of [{path}]")
                        continue

                    if yml["templates"][p]["appearances"][app]["coloring"] != \
                            yml["templates"][path]["appearances"][app]["coloring"]:
                        # print(f"[---] Appearance COLORING {app} != parent [{p}] of [{path}]")
                        print(
                            f'    {yml["templates"][p]["appearances"][app]["coloring"]} != {yml["templates"][path]["appearances"][app]["coloring"]}')
                        continue

            if category2(p, False) != EAN.EAN_Unknown:  # characters/ reached
                break


def work1():
    global yml
    # print(f"[*] Loading w2anims list..")
    # with open(f"{m_FOLDER}/result_w2anims.txt", mode="r") as af:
    #    lines = af.readlines()
    #    for line in lines:
    #        path = line[:-1]
    #        m_anims_list.append(path)
    #        m_anims[path] = len(m_anims_list)
    #        # print(f"({len(anims_list)}) = [{path}]")

    # print(f"[*] Loading w2anims mimics list..")
    # with open(f"{m_FOLDER}/result_w2anims_mimics.txt", mode="r") as am:
    #    lines = am.readlines()
    #    for line in lines:
    #        path = line[:-1]
    #        m_mimics_list.append(path)
    #        m_mimics[path] = len(m_mimics_list)
    #        # print(f"({len(mimics_list)}) = [{path}]")

    if m_convert_json:
        print(f"[*] Converting YML->JSON dump..")
        with open(f"{m_FOLDER}/EntityDump.yml", mode="r") as yf:
            start_t = time.time()
            yml = yaml.load(yf, Loader=yaml.CSafeLoader, preserve_quotes=True)
            end_t = time.time()
            print(f"YML loaded in: {end_t - start_t} s")
            with open(f"{m_FOLDER}/EntityDump.json", mode="w") as jf:
                start_t = time.time()
                json.dump(yml, jf, sort_keys=False, indent=2)
                end_t = time.time()
                print(f"JSON saved in: {end_t - start_t} s")

    print(f"[*] Loading JSON dump..")
    with open(f"{m_FOLDER}/EntityDump.json", mode="r") as jf:
        start_t = time.time()
        yml = json.load(jf)
        end_t = time.time()
        print(f"JSON loaded in: {end_t - start_t} s")

    print(f"[*] Preprocessing templates..")
    for template in yml["templates"]:
        if "effects" in yml["templates"][template]:
            for effect in yml["templates"][template]["effects"]:
                if effect not in m_effect_names_list:
                    m_effect_names_list.append(effect)

        if yml["templates"][template]["type"] == "ACTOR" and yml["templates"][template]["gender"] in ["male", "female"] \
                and yml["templates"][template]["rig"] in ["man_base", "woman_base"]:

            base_t = base_template(template, True)
            if not base_t:
                print(f"[--] No base template for: {template}")
                continue

            m_used_templates.add(template)  # !!!
            # yml["templates"][template]["base_template"] = base_t

            if "includes" in yml["templates"][template]:
                for i in yml["templates"][template]["includes"]:
                    m_used_templates.add(i)
            if "appearances" in yml["templates"][template]:
                for app in yml["templates"][template]["appearances"]:
                    if "templates" in yml["templates"][template]["appearances"][app]:
                        for app_template in yml["templates"][template]["appearances"][app]["templates"]:
                            m_used_templates.add(app_template)
                    if "coloring" in yml["templates"][template]["appearances"][app]:
                        # print(f"COLORING: [{app}] {template}")
                        pass
                    #    for compName in yml["templates"][template]["appearances"][app]["coloring"]:
                    #        m_comp_names.add(compName)
            # print(f"{template_name}")

    m_effect_names_list.sort()
    print(f"[+] Saving {len(m_effect_names_list)} effects list..")
    with open(f"{m_FOLDER}/result_effects.txt", mode="w") as oe:
        for i, effect in enumerate(m_effect_names_list):
            m_effect_names[effect] = i
            oe.write(f"{effect}\n")

    l_templatesUseless = []
    l_templatesHead = []
    print(f"[!] Processing templates..")
    for template in yml["templates"]:
        # friendly_name = template.split("/")[-1][:-6]
        # check app slot of item
        if not template in m_used_templates or template.startswith(
                'dlc/bob/data/characters/base_entities/woman_base/appearance_entity_duplicates/'):
            l_templatesUseless.append(template)
            continue

        if yml["templates"][template]["type"] == "ITEM":
            cat = category(template)
            if cat == ENR.ENR_GSlotHead:
                l_templatesHead.append(template)
                l_templatesUseless.append(template)
                continue
            elif cat == ENR.ENR_GSlotUnknown:
                l_templatesUseless.append(template)
                continue
        elif yml["templates"][template]["type"] == "ACTOR" and yml["templates"][template]["nameID"] > 0:
            base_t = base_template(template, True)
            cat = category2(base_t, True)
            if cat == EAN.EAN_Unknown:
                cat = category2(template, True)
            if "appearances" in yml["templates"][template]:
                # if not base_t in m_template_by_base_by_app:
                #    m_template_by_base_by_app[base_t] = dict()
                for app in yml["templates"][template]["appearances"]:
                    l_coloring_by_component = dict()
                    if "coloring" in yml["templates"][template]["appearances"][app]:
                        for comp_name in yml["templates"][template]["appearances"][app]["coloring"]:
                            l_coloring_by_component[comp_name] = \
                                yml["templates"][template]["appearances"][app]["coloring"][comp_name]
                    # print(f"[colorings] {friendly_name(template)}::{app}: {l_coloring_by_component}")
                    if "templates" in yml["templates"][template]["appearances"][app]:
                        # m_template_by_base_by_app[base_t][app] = []
                        for app_template in yml["templates"][template]["appearances"][app]["templates"]:
                            l_app_template_colorings = dict()
                            if "components" in yml["templates"][app_template]:
                                for app_template_comp in yml["templates"][app_template]["components"]:
                                    if app_template_comp in l_coloring_by_component:
                                        l_app_template_colorings[app_template_comp] = l_coloring_by_component[
                                            app_template_comp]
                            # print(f"[app coloring] {friendly_name(template)}::{app}::{friendly_name(app_template)} {l_app_template_colorings}")
                            # print(f"{friendly_name(template)}::{app}::{friendly_name(app_template)} -> {l_app_template}")
                            add_app_template_variant(app_template, yml["templates"][template]["nameID"], cat, app,
                                                     l_app_template_colorings)
                            # m_app_template_data[app_template] = [] # [app_t] = [slot, category, dict[coloring_key] = [npc_name_id, app_name, coloring]]
                            # [app_t] = [slot, category, dict[coloring] = [npc_name_id, app_name]]

            # if not "components" in yml["templates"][template] or not any(x in m_comp_names for x in yml["templates"][template]["components"]):
            #    print(f"USELESS: {template}")
            #    l_templatesUseless.append(template)
            # test_templates(template)

        # convert effect names to numbers
        if "effects" in yml["templates"][template]:
            effect_nums = []  # comments.CommentedSeq()
            for effect in yml["templates"][template]["effects"]:
                effect_nums.append(m_effect_names[effect])
            '''if len(effect_nums) < 10:
                effect_nums.fa.set_flow_style()
            else:
                effect_nums.fa.set_block_style()
            yml["templates"][template]["effects"] = effect_nums'''

            # convert anim paths to numbers
            # if "animations" in yml["templates"][template]:
            #    anim_nums = []  # comments.CommentedSeq()
            #    for anim in yml["templates"][template]["animations"]:
            #        anim_nums.append(m_anims[anim])
            '''if len(anim_nums) < 10:
                anim_nums.fa.set_flow_style()
            else:
                anim_nums.fa.set_block_style()
            yml["templates"][template]["animations"] = anim_nums
            '''

            # convert anim mimic paths to numbers
            # if "mimics" in yml["templates"][template]:
            #    mimic_nums = [] #  comments.CommentedSeq()
            #    for mim in yml["templates"][template]["mimics"]:
            #        mimic_nums.append(m_mimics[mim])
            '''if len(mimic_nums) < 10:
                mimic_nums.fa.set_flow_style()
            else:
                mimic_nums.fa.set_block_style()
            yml["templates"][template]["mimics"] = mimic_nums'''

    print(f"[+] Write scene & selector data..")
    yml_selector = dict()
    yml_selector["templates"] = dict()
    yml_selector["templates"]["nr_selector"] = dict()
    l_nodes = list()

    l_color_cnt = 0
    l_app_templates = set()
    l_cnt = dict()
    for app_t in m_app_template_data:
        l_variant = 0
        print(f"[{app_t}]: {m_app_template_data[app_t][0].name}")
        if m_app_template_data[app_t][0] == ENR.ENR_GSlotUnknown:
            # print(f"[!!!]: CHECKME")
            pass
        for coloring in m_app_template_data[app_t][1]:
            if not m_app_template_data[app_t][1][coloring][1].name in l_cnt:
                l_cnt[m_app_template_data[app_t][1][coloring][1].name] = dict()
            if not m_app_template_data[app_t][0].name in l_cnt[m_app_template_data[app_t][1][coloring][1].name]:
                l_cnt[m_app_template_data[app_t][1][coloring][1].name][m_app_template_data[app_t][0].name] = 0
            l_cnt[m_app_template_data[app_t][1][coloring][1].name][m_app_template_data[app_t][0].name] += 1
            # [app_t] = [slot, category, dict[coloring_key] = [npc_name_id, cat, app_name, coloring]]
            print(f"    [{l_variant}] = {m_app_template_data[app_t][1][coloring]}")
            if m_app_template_data[app_t][1][coloring][1] == EAN.EAN_Unknown:
                print(f"    [!!!] CHECKME2")
            l_node = dict()
            l_node[".type"] = "NR_SceneNode"
            l_nodes.append(l_node)

            l_color_cnt += 1
            l_variant += 1
    yml_selector["templates"]["nr_selector"]["m_nodes"] = l_nodes

    for key in EAN:
        if not key.name in l_cnt:
            continue
        for key2 in ENR:
            if not key2.name in l_cnt[key.name]:
                continue
            print(f"CNT[{key.name}][{key2.name}] = {l_cnt[key.name][key2.name]}")

    print(f"[*] Added {len(m_app_template_data)} app templates, {l_color_cnt} coloring variants: for fixed recoloring")

    print(f"[!] Removing useless templates..")
    for t in l_templatesUseless:
        del yml["templates"][t]
    print(f"Removed useless templates: {len(l_templatesUseless)}, left: {len(yml['templates'])}.")

    print(f"[+] Saving {len(l_templatesHead)} heads list..")
    l_templatesHead.sort()
    with open(f"{m_FOLDER}/result_head_w2ent.txt", mode="w") as oh:
        for i, head in enumerate(l_templatesHead):
            oh.write(f"{head}\n")

    if m_save_yml:
        print(f"[+] Saving YML..")
        with open(f"{m_FOLDER}/EntityDump_ready.yml", mode="w") as oy:
            start_t = time.time()
            yaml.dump(yml, oy, Dumper=yaml.CDumper, indent=2, block_seq_indent=2)  # yaml.RoundTripDumper
            end_t = time.time()
            print(f"YML saved in: {end_t - start_t} s")

    if m_save_json:
        print(f"[+] Saving JSON..")
        with open(f"{m_FOLDER}/EntityDump_readyJson.json", mode="w") as jo:
            start_t = time.time()
            json.dump(yml, jo, sort_keys=False, ensure_ascii=False, indent=2)
            end_t = time.time()
            print(f"JSON saved in: {end_t - start_t} s")

    with open(f"{m_FOLDER}\\SceneSelectorData.yml", mode="w") as oy:
        yaml.dump(yml_selector, oy, Dumper=yaml.RoundTripDumper, indent=2, block_seq_indent=2)

    return


def pre_filter_templates():
    if m_convert_json:
        print(f"[*] Converting YML->JSON dump..")
        with open(f"{m_FOLDER}/EntityDump.yml", mode="r") as yf:
            start_t = time.time()
            yml = yaml.load(yf, Loader=yaml.CSafeLoader, preserve_quotes=True)
            end_t = time.time()
            print(f"YML loaded in: {end_t - start_t} s")
            with open(f"{m_FOLDER}/EntityDump.json", mode="w") as jf:
                start_t = time.time()
                json.dump(yml, jf, sort_keys=False, indent=2)
                end_t = time.time()
                print(f"JSON saved in: {end_t - start_t} s")

    print(f"[*] Loading JSON dump..")
    with open(f"{m_FOLDER}/EntityDump.json", mode="r") as ij:
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
            yml["templates"][template]["category"] = yaml.scalarstring.DoubleQuotedScalarString(category(template).name)
            # if template not in m_used_templates:
            #    l_templatesUseless.append(template)
            continue
        else:
            if yml["templates"][template]["rig"] not in ["woman_base", "man_base"]:
                l_templatesUseless.append(template)
                continue
            if yml["templates"][template]["name"] == str(yml["templates"][template]["nameID"]):
                yml["templates"][template]["name"] = str()
                yml["templates"][template]["nameID"] = 0
            yml["templates"][template]["category"] = yaml.scalarstring.DoubleQuotedScalarString(category2(template, True).name)
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

    with open(f"{m_FOLDER}/EntityDump_actors_filtered.yml", mode="w") as oy:
        yaml.dump(yml, oy, Dumper=yaml.RoundTripDumper, indent=2, block_seq_indent=2)

    with open(f"{m_FOLDER}/EntityDump_actors_filtered.json", mode="w") as jo:
        json.dump(yml, jo, sort_keys=False, ensure_ascii=False, indent=2)

    # for discord - cleaned from ITEMs
    l_templatesUseless.clear()
    for t in yml["templates"]:
        if yml["templates"][t]["type"] == "ITEM":
            l_templatesUseless.append(t)

    for t in l_templatesUseless:
        print(f"Removing template: {t}")
        del yml["templates"][t]

    with open(f"{m_FOLDER}/EntityDump_actors_only.json", mode="w") as jo:
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
                "m_stringtable": CommentedSeq()
            }
        }
    }
}
m_dfs_used = set()
m_dfs_category = dict()
m_dfs_children = dict()
m_templates = dict()
m_npc_data = dict()
# name[path] = npc_nameID, npc_name, appearances[app_name][slot_name] = final_w2ent_path, npc_category (rewrite appearances if cat >)
m_stringtable = dict()
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


# friendly npc cat name
def friendly_npc_category(npc_cat: EAN) -> str:
    if npc_cat == EAN.EAN_Unknown:
        return "unknown"
    elif npc_cat == EAN.EAN_DLCCustom:
        return "dlc_custom"
    elif npc_cat == EAN.EAN_DLCMain:
        return "dlc_main"
    elif npc_cat == EAN.EAN_DLCSecondary:
        return "dlc_secondary"
    elif npc_cat == EAN.EAN_VanillaMain:
        return "vanilla_main"
    elif npc_cat == EAN.EAN_VanillaSecondary:
        return "vanilla_secondary"


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
    index = m_templates[app_template]["colorings"].index(coloring_str)
    if index == 0:
        print("get_app_template_coloring_index: ZERO")
    return index


def get_app_template_final_path(app_template: str, coloring_index: int, ignore_head_category: bool = False) -> str:
    global m_templates

    entity_name = friendly_name(app_template)

    # just one duplicate case
    if app_template == "characters/models/secondary_npc/irina/t_01_wa__novigrad_sorceress.w2ent":
        return "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_t_01_wa__novigrad_sorceress_irina_coloring_1.w2ent"

    # head - special case
    if not ignore_head_category and m_templates[app_template]["slot_category"] == ENR.ENR_GSlotHead:
        if app_template == "items/quest_items/sq303/sq303_item__crimson_mask/h_01_ma__dandelion.w2ent":
            return "dlc/dlcnewreplacers/data/entities/heads/vanilla_main/nr_h_01_ma__dandelion_crimson_mask.w2ent"

        cat_folder = friendly_npc_category(m_templates[app_template]["npc_category"])
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
    ret = f"dlc/dlcnewreplacers/data/entities/colorings/{friendly_npc_category(npc_cat)}/nr_{entity_name}_coloring_{coloring_index}.w2ent"
    # just one duplicate case
    return ret


def load_data():
    global m_data, m_templates, m_templates_by_cats, m_npc_data, m_npc_by_cats
    # load ready json
    with open(f"{m_FOLDER}/EntityDump_actors_filtered.json", mode="r") as ij:
        m_data = json.load(ij)["templates"]

    # dfs: category = max( dfs(children) )
    # for template in m_data:
    #    if m_data[template]["type"] != "ACTOR" or "includes" not in m_data[template]:
    #        continue
    #    for parent in m_data[template]["includes"]:
    #        if parent not in m_dfs_children:
    #            m_dfs_children[parent] = []
    #        m_dfs_children[parent].append(template)

    # for template in m_data:
    #    if m_data[template]["type"] == "ACTOR":
    #        dfs_npc_category(template)

    # every actor template
    for template in m_data:
        # not actor or no apps - skip
        if m_data[template]["type"] != "ACTOR" or "appearances" not in m_data[template]:
            continue
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
            app_template_by_component = dict()
            app_colorings_by_template = dict()
            if "coloring" in app:
                # if there's coloring, create map to find template by coloring component name
                for app_template in app["templates"]:
                    app_colorings_by_template[app_template] = dict()
                    for comp_name in m_data[app_template]["components"]:
                        app_template_by_component[comp_name] = app_template
                # create map to check if app template has colorings
                for comp_name in app["coloring"]:
                    # some colorings are just not removed by devs?
                    if comp_name not in app_template_by_component:
                        # print(f"Component {comp_name} in coloring not point to any app template? ({template}{app_name})")
                        continue
                    app_colorings_by_template[app_template_by_component[comp_name]][comp_name] = app["coloring"][
                        comp_name]

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
                        "npc_name": npc_name,
                        "npc_nameID": npc_nameID,
                        "npc_gender": npc_gender_val
                    }
                    # Unknown thing, but used by actor - change to misc item category
                    if m_templates[app_template] == ENR.ENR_GSlotUnknown:
                        m_templates[app_template] = ENR.ENR_RSlotMisc
                # update possible gender always
                m_templates[app_template]["npc_gender"] |= npc_gender_val
                # update npc name & cat info
                if npc_nameID > 0 and str(npc_nameID) != npc_name and \
                        (m_templates[app_template]["npc_category"].value < npc_category.value or m_templates[app_template]["npc_nameID"] == 0 or str(m_templates[app_template]["npc_nameID"]) == m_templates[app_template]["npc_name"]):
                    # current npc is cooler, use it
                    if app_template.endswith("h_01_ma__regis.w2ent"):
                        print(f"REGIS TEST: set -> {npc_category}, {npc_nameID}")
                    m_templates[app_template]["npc_category"] = npc_category
                    m_templates[app_template]["npc_nameID"] = npc_nameID
                    m_templates[app_template]["npc_name"] = npc_name

                # add new coloring variant
                if app_template in app_colorings_by_template:
                    coloring_str = json.dumps(app_colorings_by_template[app_template], sort_keys=True)
                    # not effective but we need to preserve order
                    if coloring_str not in m_templates[app_template]["colorings"]:
                        m_templates[app_template]["colorings"].append(coloring_str)

    m_templates = dict(sorted(m_templates.items()))
    print(f"Appearance templates: {len(m_templates)}")

    # add NPC sets
    # [name] = npc_nameID, npc_name, npc_category (rewrite appearances if cat >), appearances[app_name][slot_name] = final_w2ent_path/[list for misc]
    for template in m_data:
        if m_data[template]["type"] == "ACTOR":
            coloring_dict = dfs_pull_colorings(template)
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
                    if "coloring" in m_data[template]["appearances"][app_name]:
                        app_colorings = m_data[template]["appearances"][app_name]["coloring"]

                    for app_template in m_data[template]["appearances"][app_name]["templates"]:
                        slot_category = ENR[m_data[app_template]["category"]]
                        if slot_category != ENR.ENR_RSlotMisc and m_npc_data[npc_name]["appearances"][app_name][
                            slot_category]:
                            # print(f"CONFLICT SLOT {slot_category.name} ({app_template} and {m_npc_data[npc_name]['appearances'][app_name][slot_category]}) {npc_name} #{app_name}: {template}")
                            # set as misc item to avoid rewriting slot
                            slot_category = ENR.ENR_RSlotMisc

                        coloring_index = get_app_template_coloring_index(app_template, app_colorings)
                        if slot_category != ENR.ENR_RSlotMisc:
                            m_npc_data[npc_name]["appearances"][app_name][slot_category] = get_app_template_final_path(
                                app_template, coloring_index)
                        else:
                            m_npc_data[npc_name]["appearances"][app_name][slot_category].append(
                                get_app_template_final_path(app_template, coloring_index))

    for npc_name in m_npc_data:
        m_npc_by_cats[m_npc_data[npc_name]["gender"]][m_npc_data[npc_name]["category"]].append(
            npc_name
        )

    # sort NPC sets by alphabet
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

    with open(f"{m_FOLDER}/DEBUG_npc_sets.json", mode="w") as jo:
        start_t = time.time()
        json.dump(m_npc_by_cats, jo, sort_keys=False, ensure_ascii=False, indent=2)
        end_t = time.time()
        print(f"npc sets JSON saved in: {end_t - start_t} s")

    # sort app templates by cats (w/o coloring paths yet - in creating scene)
    for t in m_templates:
        if m_templates[t]["npc_nameID"] > 0 and m_templates[t]["npc_name"] != str(m_templates[t]["npc_nameID"]) and m_templates[t]["npc_category"] != EAN.EAN_Unknown and m_templates[t]["slot_category"] != ENR.ENR_GSlotUnknown:
            for gender in [EG.EG_Male, EG.EG_Female]:
                if m_templates[t]["npc_gender"] == gender.EG_Any:
                    print(f"BIGENDER: {t}")
                if m_templates[t]["npc_gender"] & gender.value:
                    m_templates_by_cats[gender][m_templates[t]["slot_category"]][m_templates[t]["npc_category"]].append(t)

    # sort app templates by alphabet (w/o coloring paths yet - in creating scene)
    for gender in [EG.EG_Male, EG.EG_Female]:
        for slot_category in ENR:
            for npc_category in EAN:
                if not m_templates_by_cats[gender][slot_category][npc_category]:
                    continue
                m_templates_by_cats[gender][slot_category][npc_category] = sorted(
                    m_templates_by_cats[gender][slot_category][npc_category],
                    key=lambda item: m_templates[item]["npc_name"]
                )
                # print info
                cnt = len(m_templates_by_cats[gender][slot_category][npc_category])
                if cnt > 0:
                    print(f"Appearance templates[{gender.name}][{slot_category.name}][{npc_category.name}] = {cnt}")

    with open(f"{m_FOLDER}/DEBUG_app_templates.json", mode="w") as jo:
        start_t = time.time()
        json.dump(m_templates_by_cats, jo, sort_keys=False, ensure_ascii=False, indent=2)
        end_t = time.time()
        print(f"app templates JSON saved in: {end_t - start_t} s")


def write_yml_nicely(path, data):
    with open(path, mode="w", encoding="utf-8") as f_yml:
        start_t = time.time()
        yaml_dumper = ruamel.yaml.YAML()
        yaml_dumper.indent(mapping=2, sequence=4, offset=2)
        yaml_dumper.width = 4096
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

    with open("WKIT_rename_components.txt", mode="w", encoding="utf-8") as f_comp_out:
        for i, t in enumerate(m_templates):
            if len(m_templates[t]["colorings"]) > 1:
                vanilla_path = t
                npc_gender_val = m_templates[t]["npc_gender"]
                for j, coloring in enumerate(m_templates[t]["colorings"]):
                    if j == 0:
                        continue
                    custom_path = get_app_template_final_path(t, j, True)
                    component_dict = json.loads(coloring)
                    component_cnt = len(component_dict)
                    if custom_path in custom_paths:
                        print(f"TEMPLATE DUPLICATE: {custom_path} ({vanilla_path})")
                    custom_paths.add(custom_path)
                    f_comp_out.write(f"{vanilla_path}|{custom_path}|{component_cnt}")

                    for comp_name in component_dict:
                        new_comp_name = f"{comp_name}_coloring_{j}"
                        f_comp_out.write(f"|{comp_name}|{new_comp_name}")

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

                        if len(component_dict[comp_name]) > 3 and any(
                                component_dict[comp_name][i] != 0 for i in range(3, 6)):
                            coloring_entry_yml["colorShift2"] = dict()
                            if component_dict[comp_name][3] != 0:
                                coloring_entry_yml["colorShift2"]["hue"] = component_dict[comp_name][3]
                            if component_dict[comp_name][4] != 0:
                                coloring_entry_yml["colorShift2"]["saturation"] = component_dict[comp_name][4]
                            if component_dict[comp_name][5] != 0:
                                coloring_entry_yml["colorShift2"]["luminance"] = component_dict[comp_name][5]

                        if npc_gender_val & EG.EG_Male.value:
                            m_coloring_yml[EG.EG_Male]["coloringEntries"].append(coloring_entry_yml)
                        if npc_gender_val & EG.EG_Female.value:
                            m_coloring_yml[EG.EG_Female]["coloringEntries"].append(coloring_entry_yml)

                    f_comp_out.write("\n")

    print(f"COMPONENTS WKIT data saved.")

    for i in [EG.EG_Male, EG.EG_Female]:
        m_coloring_yml[i] = {
            "templates": {
                "replacer": m_coloring_yml[i]
            }
        }
        write_yml_nicely(f"{m_FOLDER}/RADISH_{i.name}_colorings.yml", m_coloring_yml[i])


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
                        f_head_xml.write(f'                <!-- {m_templates[t]["npc_name"]} #{j} -->\n')
                        f_head_xml.write(f'                <tags>NoShow,NoDrop,Body</tags>\n')
                        f_head_xml.write(f'                <base_abilities></base_abilities>\n')
                        f_head_xml.write(f'                <base_abilities></base_abilities>\n')
                        f_head_xml.write(f'            </item>\n')

        f_head_xml.write("        </items>\n")
        f_head_xml.write("    </definitions>\n")
        f_head_xml.write("</redxml>\n")


def load_dlc_data():
    dlc_files = [str(x) for x in Path("DLCCustom").rglob("*.json") if x.is_file()]
    for dlc_file in dlc_files:
        with open(dlc_file, mode="r", encoding="utf-8") as ij:
            data = json.load(ij)
            # print(data)
            for i, template_data in enumerate(data["dlc_appearance_templates"]):
                print(template_data)


def string_id(text: str) -> int:
    global m_stringtable
    if text not in m_stringtable:
        new_id = len(m_stringtable)
        m_stringtable[text] = new_id

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
def add_choice_formatted(prefix: str, text_str: str, from_section_name: str, to_section_name: str, is_exit=False, cond=None, ignore_missed=False):
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
def add_choice_scripted(text: str, from_section_name: str, to_section_name: str, prefix_id: int, extra_name: str, coloring_index: int = 0, variants: int = 0, is_exit: bool = False, cond=None):
    global m_scene_yml

    if from_section_name not in m_scene_yml["dialogscript"]:
        print(f"ERROR: {from_section_name} not exists.")

    if to_section_name not in m_scene_yml["dialogscript"]:
        print(f"WARN: {to_section_name} not exists.")

    choice_obj = {
        "choice": flowed([text, to_section_name, "exit"]) if is_exit else flowed([text, to_section_name]),
        "emphasize": True,
        "scriptAction": {
            ".class": "NR_LocalizedPreviewChoiceAction",
            "prefix_id": prefix_id,
            "extra_name": extra_name
        }
    }
    if variants > 0:
        choice_obj["scriptAction"]["variants"] = variants

    if coloring_index > 0:
        choice_obj["scriptAction"]["coloring_index"] = coloring_index

    if cond:
        choice_obj["condition"] = flowed(cond)

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
    global m_scene_yml, m_templates, m_templates_by_cats, m_selector_yml
    with open(f"{m_FOLDER}/scene.01.player_change_BASE.yml", mode="r", encoding="utf-8") as f_yml:
        start_t = time.time()
        m_scene_yml = yaml.load(f_yml, Loader=yaml.RoundTripLoader, preserve_quotes=True)
        end_t = time.time()
        print(f"Scene YML loaded in: {end_t - start_t} s")

    selector_nodes = m_selector_yml["templates"]["nr_scene_selector"]["entityObject"]["m_nodesMale" if gender == EG.EG_Male else "m_nodesFemale"]

    # Create slots in section_choice_player_appearance
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
            cat_section_name = f"section_choice_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat)}"
            add_choice_section(cat_section_name, cams=preview_cams)
            cat_script_name = f"script_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat)}"

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
            next_cat_script_name = f"script_{friendly_slot_category(slot)}_{friendly_npc_category(next_npc_cat)}"
            add_choice_formatted(quoted(f"{STR.DOT.value}|."), quoted(f"[{{368969}}: {{str_npc_category(next_npc_cat)}}]"), cat_section_name, next_cat_script_name, ignore_missed=True)
            sub_cnt = 0

            # add preview subsection and preview leaves
            for k, path in enumerate(m_templates_by_cats[gender][slot][npc_cat]):
                t_data = m_templates[path]

                if len(t_data["colorings"]) > 2:
                    # Add preview subsection
                    sub_cnt += 1
                    subcat_section_name = f"section_choice_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat)}_sub{sub_cnt}"
                    add_choice_section(subcat_section_name, cams=preview_cams)
                    subcat_script_name = f"script_{friendly_slot_category(slot)}_{friendly_npc_category(npc_cat)}_sub{sub_cnt}"

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
                    add_choice_scripted(quoted(f"{STR.DOT.value}|.{t_data['npc_name']}: {variants_cnt} variants"), cat_section_name, subcat_script_name, t_data["npc_nameID"], friendly_name(path), 0, variants_cnt)
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
                        add_choice_scripted(quoted(f"{STR.DOT.value}|.{t_data['npc_name']}: {friendly_name(path)} #{coloring_index}"), subcat_section_name, trans(subcat_section_name, subcat_section_name), t_data["npc_nameID"], friendly_name(path), coloring_index)
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
                    coloring_index = len(t_data["colorings"])
                    if coloring_index == 1:
                        # no colorings
                        final_path = get_app_template_final_path(path, 0)
                    else:
                        # one coloring, ignore non-colored version
                        final_path = get_app_template_final_path(path, 1)

                    add_choice_scripted(quoted(f"{STR.DOT.value}|.{t_data['npc_name']}: {friendly_name(path)} #{coloring_index}"), cat_section_name, trans(cat_section_name, cat_section_name), t_data["npc_nameID"], friendly_name(path), coloring_index)
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

    write_yml_nicely(f"{m_FOLDER}/scene.01.player_change_{'male' if gender == EG.EG_Male else 'female'}.yml", m_scene_yml)


def write_selector_file():
    global m_selector_yml, m_stringtable

    for i, key in enumerate(m_stringtable):
        if m_stringtable[key] != i:
            print(f"STRINGTABLE ERROR: i = {i}, key = {key}, val = {m_stringtable[key]}")
        x = 1
        m_selector_yml["templates"]["nr_scene_selector"]["entityObject"]["m_stringtable"].append(key)

    write_yml_nicely(f"{m_FOLDER}/def.entities.nr_selector.yml", m_selector_yml)


# make paths relative to depot
# rename \ -> /
# rename <tab> -> <spaces>
# rename x.w2rig -> x
# fix quests/part_1/quest_files/q205_frozen_coast/characters/q205_wild_hunt_elf_riders.w2ent
# fix ""

# pre_filter_templates()
load_data()
write_coloring_files()
write_rename_head_files()
load_dlc_data()
create_scene(EG.EG_Male)
create_scene(EG.EG_Female)
write_selector_file()
