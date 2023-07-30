try:
    import ruamel.yaml.scalarstring
    from ruamel import yaml
    from ruamel.yaml import comments
except:
    import yaml
import json
import time
import enum
import re
from frozendict import frozendict

m_convert_json = False
m_save_yml = False
m_save_json = False

m_anims_list = []
m_anims = dict()
m_mimics_list = []
m_mimics = dict()
m_effect_names_list = []
m_effect_names = dict()
m_used_templates = set()
m_comp_names = set()
m_entity_names = set()

m_base_templates = dict()
#m_app_template_colorings = dict()  # [template] = [[10, 10, 10], [20, 20, 20, 30, 30, 30], [40, 40, 40]]
#m_template_by_base_by_app = dict()  # [base][app] = [template1.w2ent, template2_coloring_0.w2ent, template3_coloring_1.w2ent]
m_app_template_data = dict()  # [app_t] = [slot, dict[coloring] = [npc_name_id, category, app_name, colorings]]
m_DLC_DATA = "dlc/dlcnewreplacers/data"
m_FOLDER = "/sdcard/APython/w2ent_dump"
yml = None
yml_scene = None
yml_selector = None

class EAN(enum.IntEnum):
    EAN_VanillaMain = 0
    EAN_VanillaSecondary = 1
    EAN_DLCMain = 2
    EAN_DLCSecondary = 3
    EAN_Unknown = 4

class ENR(enum.IntEnum):
    ENR_GSlotUnknown = 0
    ENR_GSlotHair = 1
    ENR_GSlotHead = 2
    ENR_GSlotArmor = 3
    ENR_GSlotGloves = 4
    ENR_GSlotPants = 5
    ENR_GSlotBoots = 6

    ENR_RSlotBody = 7
    ENR_RSlotTorso = 8
    ENR_RSlotDress = 9
    ENR_RSlotArms = 10
    ENR_RSlotGloves = 11
    ENR_RSlotLegs = 12
    ENR_RSlotShoes = 13
    ENR_RSlotNeck = 14
    ENR_RSlotWaist = 15
    ENR_RSlotHairCap = 16
    ENR_RSlotMisc = 17
    # ENR_RSlotHood = 14

def friendly_name(path: str):
    return path.split("/")[-1].split(".")[0]

def test_cat(path: str):
    parts = path.split("/")

    if parts[-1].endswith("_body.w2ent") or re.search("^(b(ody)?\d?)?(t(orso)?\d?)?(w(aist)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(ead)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]) and parts[-1][0] not in ['_', 'i']:
        return True
    else:
        return False

def category(path: str):
    parts = path.split("/")

    if test_cat(path):
        if parts[-1].endswith("_body.w2ent") or re.search("^b(ody)?\d?(t(orso)?\d?)?(w(aist)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):  # t1,2,3
            return ENR.ENR_RSlotBody
        elif re.search("^t(orso)?\d?(w(aist)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotTorso
        elif re.search("^w(aist)?\d?(a(rms)?\d?)?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotWaist
        elif re.search("^a(rms)?\d?(l(egs)?\d?)?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotArms
        elif re.search("^l(egs)?\d?(d(ress)?\d?)?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotLegs
        elif re.search("^d(ress)?\d?(a(rms)?\d?)?(l(egs)?\d?)?(n(eck)?\d?)?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotDress
        elif re.search("^n(eck)?\d?(g(loves)?\d?)?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotNeck
        elif re.search("^g(loves)?\d?(s(hoes)?\d?)?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotGloves
        elif re.search("^s(hoes)?\d?(h(h|b|e|air)?)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotShoes
        elif re.search("^h(ead)?((c(ap)?)|(hair)\d?)?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_GSlotHead
        elif re.search("^(c(ap)?)|(hair)\d?(i(tem)?\d?)?_", parts[-1]):
            return ENR.ENR_RSlotHairCap
    elif re.search("^(i\d?_)|(item\d?_)|(hood_)|(pendant)|(necklace)|(feather)|(medallion)|(collar_)|(cloak)|(earrings)|(hairpin)|(crown)|(.*mask)|(fur_)|(cord_)", parts[-1]):
        return ENR.ENR_RSlotMisc
    #elif parts[-1].endswith("traj.w2ent") or parts[-1].find("trajectories") >= 0 \
    #        or re.search("(monsters)|(animals)|(animations)|(base_entities)|(shops_and_craftsmen)\/", path):
    #    return EAS.ENR_GSlotUnknown
    else:
        #print(f"Unknown type: {path}")
        return ENR.ENR_GSlotUnknown

def category2(path: str, tryMore: bool):
    if re.search("^characters/npc_entities/(main_npc)|(secondary_npc)/", path):
        return EAN.EAN_VanillaMain
    elif re.search("^characters/.*/(crowd_npc)|(background_npc)|(monsters)|(community_npcs)/", path):
        return EAN.EAN_VanillaSecondary
    elif re.search("^dlc/.*/data/.*/(main_npc)|(secondary_npc)/", path):
        return EAN.EAN_DLCMain
    elif re.search("^dlc/.*/data/.*/(crowd_npc)|(background_npc)|(monsters)|(community_npcs)/", path):
        return EAN.EAN_DLCSecondary

    if tryMore and re.search("(characters)|(quests)|(living_world)/", path):
        if path.find("main_quests/") >= 0:
            return EAN.EAN_DLCMain if path.startswith("dlc/") else EAN.EAN_VanillaMain
        else:
            return EAN.EAN_DLCSecondary if path.startswith("dlc/") else EAN.EAN_VanillaSecondary
    return EAN.EAN_Unknown


def app_template_name(app_template: str, app_template_colorings: dict):
    global m_app_template_colorings
    if not app_template_colorings:
        return app_template

    if not app_template in m_app_template_colorings:
        m_app_template_colorings[app_template] = []
    if not app_template_colorings in m_app_template_colorings[app_template]:
        m_app_template_colorings[app_template].append(app_template_colorings)
    return f"{m_DLC_DATA}/entities/coloring/{friendly_name(app_template)}_coloring_{m_app_template_colorings[app_template].index(app_template_colorings)}.w2ent"

def add_app_template_variant(app_template: str, npc_nameID: int, npc_category: ENR, app_name: str, l_app_template_colorings: dict):
    global m_app_template_data
    # [app_t] = [slot, dict[coloring] = [npc_name_id, category, app_name, colorings]]
    if app_template not in m_app_template_data:
        m_app_template_data[app_template] = [category(app_template), dict(), dict()]

    key_str = "K"
    for comp in sorted(l_app_template_colorings.keys()):
        key_str += f"{comp}"
        for comp_coloring in l_app_template_colorings[comp]:
            key_str += f"{comp_coloring}"
    #print(f"KEY: {key_str}")
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
                #print(f"[-] Appearances not in parent [{p}] of {path}")
                continue
            for app in yml["templates"][path]["appearances"]:
                if app not in yml["templates"][p]["appearances"]:
                    #print(f"[-] Appearance {app} not in parent [{p}] of {path}")
                    continue
                if yml["templates"][p]["appearances"][app]["templates"] != yml["templates"][path]["appearances"][app]["templates"]:
                    print(f"[---] Appearance TEMPLATES {app} != parent [{p}] of {path}")
                    print(f'    {yml["templates"][p]["appearances"][app]["templates"]} != {yml["templates"][path]["appearances"][app]["templates"]}')
                    continue

                if "coloring" in yml["templates"][path]["appearances"][app]:
                    if "coloring" not in yml["templates"][p]["appearances"][app]:
                        #print(f"[-] Missed COLORING {app} in parent [{p}] of [{path}]")
                        continue

                    if yml["templates"][p]["appearances"][app]["coloring"] != yml["templates"][path]["appearances"][app]["coloring"]:
                        #print(f"[---] Appearance COLORING {app} != parent [{p}] of [{path}]")
                        print(f'    {yml["templates"][p]["appearances"][app]["coloring"]} != {yml["templates"][path]["appearances"][app]["coloring"]}')
                        continue

            if category2(p, False) != EAN.EAN_Unknown:  # characters/ reached
                break

def work1():
    global yml
    print(f"[*] Loading w2anims list..")
    with open(f"{m_FOLDER}/result_w2anims.txt", mode="r") as af:
        lines = af.readlines()
        for line in lines:
            path = line[:-1]
            m_anims_list.append(path)
            m_anims[path] = len(m_anims_list)
            # print(f"({len(anims_list)}) = [{path}]")

    print(f"[*] Loading w2anims mimics list..")
    with open(f"{m_FOLDER}/result_w2anims_mimics.txt", mode="r") as am:
        lines = am.readlines()
        for line in lines:
            path = line[:-1]
            m_mimics_list.append(path)
            m_mimics[path] = len(m_mimics_list)
            # print(f"({len(mimics_list)}) = [{path}]")

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
            #yml["templates"][template]["base_template"] = base_t

            if "includes" in yml["templates"][template]:
                for i in yml["templates"][template]["includes"]:
                    m_used_templates.add(i)
            if "appearances" in yml["templates"][template]:
                for app in yml["templates"][template]["appearances"]:
                    if "templates" in yml["templates"][template]["appearances"][app]:
                        for app_template in yml["templates"][template]["appearances"][app]["templates"]:
                            m_used_templates.add(app_template)
                    if "coloring" in yml["templates"][template]["appearances"][app]:
                        #print(f"COLORING: [{app}] {template}")
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
        if not template in m_used_templates or template.startswith('dlc/bob/data/characters/base_entities/woman_base/appearance_entity_duplicates/'):
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
                #if not base_t in m_template_by_base_by_app:
                #    m_template_by_base_by_app[base_t] = dict()
                for app in yml["templates"][template]["appearances"]:
                    l_coloring_by_component = dict()
                    if "coloring" in yml["templates"][template]["appearances"][app]:
                        for comp_name in yml["templates"][template]["appearances"][app]["coloring"]:
                            l_coloring_by_component[comp_name] = yml["templates"][template]["appearances"][app]["coloring"][comp_name]
                    #print(f"[colorings] {friendly_name(template)}::{app}: {l_coloring_by_component}")
                    if "templates" in yml["templates"][template]["appearances"][app]:
                        #m_template_by_base_by_app[base_t][app] = []
                        for app_template in yml["templates"][template]["appearances"][app]["templates"]:
                            l_app_template_colorings = dict()
                            if "components" in yml["templates"][app_template]:
                                for app_template_comp in yml["templates"][app_template]["components"]:
                                    if app_template_comp in l_coloring_by_component:
                                        l_app_template_colorings[app_template_comp] = l_coloring_by_component[app_template_comp]
                            #print(f"[app coloring] {friendly_name(template)}::{app}::{friendly_name(app_template)} {l_app_template_colorings}")
                            #print(f"{friendly_name(template)}::{app}::{friendly_name(app_template)} -> {l_app_template}")
                            add_app_template_variant(app_template, yml["templates"][template]["nameID"], cat, app, l_app_template_colorings)
                            #m_app_template_data[app_template] = [] # [app_t] = [slot, category, dict[coloring_key] = [npc_name_id, app_name, coloring]]
                            # [app_t] = [slot, category, dict[coloring] = [npc_name_id, app_name]]

            # if not "components" in yml["templates"][template] or not any(x in m_comp_names for x in yml["templates"][template]["components"]):
            #    print(f"USELESS: {template}")
            #    l_templatesUseless.append(template)
            #test_templates(template)

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
        if "animations" in yml["templates"][template]:
            anim_nums = []  # comments.CommentedSeq()
            for anim in yml["templates"][template]["animations"]:
                anim_nums.append(m_anims[anim])
            '''if len(anim_nums) < 10:
                anim_nums.fa.set_flow_style()
            else:
                anim_nums.fa.set_block_style()
            yml["templates"][template]["animations"] = anim_nums
            '''

        # convert anim mimic paths to numbers
        if "mimics" in yml["templates"][template]:
            mimic_nums = [] #  comments.CommentedSeq()
            for mim in yml["templates"][template]["mimics"]:
                mimic_nums.append(m_mimics[mim])
            '''if len(mimic_nums) < 10:
                mimic_nums.fa.set_flow_style()
            else:
                mimic_nums.fa.set_block_style()
            yml["templates"][template]["mimics"] = mimic_nums'''

    print(f"[+] Write scene & selector data..")
    yml_selector = dict()
    yml_selector["templates"] = dict()
    yml_selector["templates"]["nr_selector"] = dict()
    l_nodes = dict()
    
    l_color_cnt = 0
    l_app_templates = set()
    l_cnt = dict()
    for app_t in m_app_template_data:
        l_variant = 0
        print(f"[{app_t}]: {m_app_template_data[app_t][0].name}")
        if m_app_template_data[app_t][0] == ENR.ENR_GSlotUnknown:
            #print(f"[!!!]: CHECKME")
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

    return

def work2():
    with open(f"{m_FOLDER}\\EntityDump_ready.yml", mode="r") as iy:
        yml = yaml.load(iy, Loader=yaml.RoundTripLoader, preserve_quotes=True)

    l_templatesUseless = []
    for template in yml["templates"]:
        friendly_name = template.split("/")[-1][:-6]
        if friendly_name in m_entity_names:
            print(f"DUPL: {friendly_name}")
        m_entity_names.add(friendly_name)

        if yml["templates"][template]["type"] == "ITEM":
            yml["templates"][template]["category"] = yaml.scalarstring.DoubleQuotedScalarString(category(template).name)
            #if template not in m_used_templates:
            #    l_templatesUseless.append(template)
            continue
        else:
            if yml["templates"][template]["rig"] not in ["woman_base", "man_base"]:
                l_templatesUseless.append(template)
                continue
        if "effects" in yml["templates"][template]:
            del yml["templates"][template]["effects"]
        if "animations" in yml["templates"][template]:
            del yml["templates"][template]["animations"]
        if "mimics" in yml["templates"][template]:
            del yml["templates"][template]["mimics"]
    for t in l_templatesUseless:
        del yml["templates"][t]
    print(f"Removed useless templates: {len(l_templatesUseless)}")
    print(f"Left templates: {len(yml['templates'])}")

    with open(f"{m_FOLDER}\\EntityDump_ready2.yml", mode="w") as oy:
        yaml.dump(yml, oy, Dumper=yaml.RoundTripDumper, indent=2, block_seq_indent=2)

def work3():
    start = time.time()
    with open(f"{m_FOLDER}\\EntityDump_ready2.yml", mode="r") as iy:
        yamlll = yaml.YAML(typ='safe')
        yml = yamlll.load(iy)

    end = time.time()
    print(f"Loaded in {end - start} s")
    l_templates = []
    l_searchTemplate = "t3d_02_wa__skellige_warrior_woman"
    # l_friendly_name = l_searchTemplate.split("/")[-1][:-6]
    while True:
        # print(f"Search with friendly name: [{l_friendly_name}]")
        print(f"Searching: {l_searchTemplate}..")
        for template in yml["templates"]:
            if "appearances" in yml["templates"][template]:
                for app, val in yml["templates"][template]["appearances"].items():
                    if "templates" in val and "coloring" in val:
                        if l_searchTemplate in val["coloring"]:
                            print(f"{template}, {app}")
        print("DONE!")
        l_searchTemplate = input("Component to search: ").replace("\\", "/")
        # l_friendly_name = l_searchTemplate.split("/")[-1][:-6]

work1()
#work2()
# work3()
