import enum

import ruamel.yaml.scalarstring
from ruamel import yaml
from ruamel.yaml import comments
import time
from enum import IntEnum, auto
from strenum import StrEnum
import shutil

m_yml_scene = None
m_str_dot = "0001107617|."
class STR(StrEnum):
    BACK = "2115940103"
    dot = "0001107617"
    #yennefer = "0000162823"
    #keira = "0000334714"
    #triss = "0000162822"
    #philippa = "0000300169"
    #lynx = "0001157557"
    light_attacks = "2115940118"
    light_ratio = "2115940119"
    type = "2115940120"
    color = "2115940121"
    slash = "2115940122"
    throw = "2115940140"
    lightning = "2115940141"
    projectile = "2115940142"
    hand_effect = "2115940143"
    teleport = "2115940144"
    ft_teleport = "2115940145"
    heavy_attacks = "2115940146"
    heavy_ratio = "2115940147"
    rocks = "2115940148"
    bomb = "2115940149"
    rocks_wave = "2115940150"
    push = "2115940151"
    special_spells = "2115940152"
    tornado = "2115940153"
    control = "2115940154"
    meteor = "2115940155"
    sphere = "2115940156"
    golem = "2115940157"
    special_spells_binding = "2115940158"

m_mages = {
    "yennefer": {
        "id": 162823,
        "str": "0000162823|Yennefer",
    },
    "keira": {
        "id": 334714,
        "str": "0000334714|Keira Metz",
    },
    "triss": {
        "id": 162822,
        "str": "0000162822|Triss",
    },
    "lynx": {
        "id": 1157557,
        "str": "0001157557|Witch of Lynx Crag",
    },
    "philippa": {
        "id": 300169,
        "str": "0000300169|Philippa Eilhart",
    },
    "caranthir": {
        "id": 335803,
        "str": "0000335803|Caranthir",
    },
    "eredin": {
        "id": 335796,
        "str": "0000335796|Eredin",
    },
    "djinn": {
        "id": 583032,
        "str": "0000583032|Djinn",
    },
    "ofieri": {
        "id": 1105972,
        "str": "0001105972|Ofieri Mage",
    },
    "hermit": {
        "id": 1119070,
        "str": "0001119070|Hermit",
    },
    "default": {
        "id": 1224932,
        "str": "0001224932|Default",
    },
    "wild_hunt": {
        "id": 535322,
        "str": "0000535322|Wild Hunt Mage",
    },
}

m_sorc_anims = {
    "AttackNoStamina": [
        {
            "name": "woman_sorceress_effect_immobile_nulify",
            "perform": 0.0,
            "duration": 0.0
        }
    ],
    "AttackLightSlash": [
        {
            "name": "woman_sorceress_attack_slash_left_lp",
            "perform": 0.8,
            "duration": 2.3
        },
        {
            "name": "woman_sorceress_attack_slash_right_lp",
            "perform": 0.8,
            "duration": 2.3
        }
    ],
    "AttackLightThrow": [
        {
            "name": "woman_sorceress_attack_throw_lp_04",  # throw from shoulder
            "perform": 1.2,
            "duration": 2.0
        }
    ],
    "AttackHeavyRock": [
        {
            "name": "woman_sorceress_attack_rock_rhand_lp",
            "perform": 1.9,
            "duration": 3.0
        },
        {
            "name": "woman_sorceress_attack_rock_lhand_lp",
            "perform": 1.9,
            "duration": 3.0
        },
        {
            "name": "woman_sorceress_attack_rock_bhand_lp",
            "perform": 1.9,
            "duration": 3.0
        }
    ],
    "AttackHeavyThrow": [
        {
            "name": "woman_sorceress_attack_throw_lp_03",  # throw from shoulder
            "perform": 1.2,
            "duration": 2.0
        },
        {
            "name": "woman_sorceress_attack_throw_lp_04",  # throw from down
            "perform": 1.2,
            "duration": 2.0
        }
    ],
    "AttackFinisher": [
        {
            "name": "woman_sorceress_rip_apart_kill_lp",
            "perform": 3.0,
            "duration": 4.5
        }
    ],
    "AttackPush": [
        {
            "name": "woman_sorceress_attack_push_lp_02",
            "perform": 0.2,
            "duration": 0.7
        }
    ],
    "AttackTeleport": [
        {
            "name": "woman_sorceress_teleport_lp",
            "perform": 1.14,
            "duration": 2.5
        }
    ],
    "AttackSpecialFireball": [
        {
            "name": "woman_sorceress_special_attack_fireball_lp",
            "perform": 1.32,
            "duration": 3.0
        }
    ],
    "AttackSpecialElectricity": [
        {
            "name": "woman_sorceress_special_attack_electricity_lp",
            "perform": 1.7,
            "duration": 3.33
        }
    ],
    "AttackSpecialPray": [
        {
            "name": "woman_sorceress_pray_cast_lp",
            "perform": 1.6667,
            "duration": 2.8
        }
    ],
    "AttackSpecialHeal": [
        {
            "name": "woman_sorceress_heal_lp",
            "perform": 2.0,
            "duration": 3.0
        }
    ],
    "AttackSpecialTransform": [
        {
            "name": "woman_sorceress_transform_lp",
            "perform": 1.6667,
            "duration": 4.166
        }
    ]
}

m_willey_anims = {
    "front_down_rp": {
        "name": "anim_12144_man_geralt_sword_hit_front_down_rp_01",
        "duration": 1.5
    },
    "front_lp": {
        "name": "anim_12148_man_geralt_sword_hit_front_lp_01",
        "duration": 1.5
    },
    "front_left_lp": {
        "name": "anim_12146_man_geralt_sword_hit_front_left_lp_01",
        "duration": 1.5
    },
    "front_up_lp": {
        "name": "anim_12147_man_geralt_sword_hit_front_left_up_lp_01",
        "duration": 1.5
    },
    "front_left_down_lp": {
        "name": "anim_12145_man_geralt_sword_hit_front_left_down_lp_01",
        "duration": 1.5
    },
    "hit1": {
        "name": "anim_7613_low_standing_paralyzed_gesture_question_01",
        "duration": 5.4667,
    },
    "hit2": {
        "name": "anim_7611_low_standing_paralyzed_gesture_explain_02",
        "duration": 4.0,
    },
    "hit3": {
        "name": "anim_7608_low_standing_paralyzed_die_to_low_lying_dead",
        "duration": 6.0,
    }
}

m_pain_mimic_name = "mimicsanim_168_geralt_reaction_pain_face"
#section_entry_section = dict()

class ENR_MA(IntEnum):
    ENR_Unknown = 0
    ENR_LightAbstract = auto()
    ENR_Slash = auto()
    ENR_ThrowAbstract = auto()
    ENR_Lightning = auto()
    ENR_Projectile = auto()
    ENR_ProjectileWithPrepare = auto()
    ENR_HeavyAbstract = auto()
    ENR_Rock = auto()
    ENR_BombExplosion = auto()
    ENR_RipApart = auto()
    ENR_CounterPush = auto()
    ENR_SpecialAbstract = auto()
    ENR_SpecialControl = auto()
    ENR_SpecialGolem = auto()
    ENR_SpecialMeteor = auto()
    ENR_SpecialTornado = auto()
    ENR_SpecialSphere = auto()
    ENR_SpecialAbstractAlt = auto()
    ENR_SpecialTransform = auto()
    ENR_SpecialMeteorFall = auto()
    ENR_SpecialLightningFall = auto()
    ENR_SpecialLumos = auto()
    ENR_SpecialHeal = auto()
    ENR_Teleport = auto()
    ENR_HandFx = auto()
    ENR_FastTravelTeleport = auto()

class ENR_MC(IntEnum):
    ENR_ColorBlack = 0
    ENR_ColorGrey = auto()
    ENR_ColorWhite = auto()
    ENR_ColorYellow = auto()
    ENR_ColorOrange = auto()
    ENR_ColorRed = auto()
    ENR_ColorPink = auto()
    ENR_ColorViolet = auto()
    ENR_ColorBlue = auto()
    ENR_ColorSeagreen = auto()
    ENR_ColorGreen = auto()
    ENR_ColorSpecial1 = auto()
    ENR_ColorSpecial2 = auto()
    ENR_ColorSpecial3 = auto()

m_colors = [
    ["Black", "2115940124|Black"],
    ["Grey", "2115940125|Grey"],
    ["White", "2115940126|White"],
    ["Yellow", "2115940127|Yellow"],
    ["Orange", "2115940128|Orange"],
    ["Red", "2115940129|Red"],
    ["Pink", "2115940130|Pink"],
    ["Violet", "2115940131|Violet"],
    ["Blue", "2115940132|Blue"],
    ["Seagreen", "2115940133|Seagreen"],
    ["Green", "2115940134|Green"],
    ["Special1", "2115940135|Special1"],
    ["Special2", "2115940136|Special2"],
    ["Special3", "2115940137|Special3"],
]
m_signs = [
    ["Aard", 1061945, "0001061945|Aard"],
    ["Axii", 1066290, "0001066290|Axii"],
    ["Igni", 1066291, "0001066291|Igni"],
    ["Quen", 1066292, "0001066292|Quen"],
    ["Yrden", 1066293, "0001066293|Yrden"],
]

def transition_name(from_section_name: str, to_section_name: str):
    return f"section_trans_{from_section_name[len('section_'):]}_to_{to_section_name[len('section_'):]}"

def shot_transition_name(from_section_name: str, to_section_name: str):
    return f"shot_trans_{from_section_name[len('section_'):]}_to_{to_section_name[len('section_'):]}"

def CNAME(value: str):
    return f"CNAME_{value}"

def quoted(text: str):
    return yaml.scalarstring.DoubleQuotedScalarString(text)

def flowed(seq: list):
    ret = comments.CommentedSeq(seq)
    ret.fa.set_flow_style()
    return ret

def add_preview_section(section_name: str, shot_name: str, duration_s: float):
    global m_yml_scene
    m_yml_scene["dialogscript"][section_name] = [{"CUE": shot_name}, {"PAUSE": duration_s}]
    m_yml_scene["dialogscript"].yaml_set_comment_before_after_key(key=section_name, before='\n')
    return

def add_dummy_section(section_name: str, duration_s: float):
    global m_yml_scene
    m_yml_scene["dialogscript"][section_name] = [{"PAUSE": duration_s}]
    m_yml_scene["dialogscript"].yaml_set_comment_before_after_key(key=section_name, before='\n')
    return

def add_preview_sbui_section(section_name: str, shot_name: str, sorc_anim: dict, willey_anim: dict):
    global m_yml_scene
    m_yml_scene["storyboard"][section_name] = {
        shot_name: [
            {
                "actor.anim": {
                    ".@pos": flowed([sorc_anim.get("start", 0.0), sorc_anim["name"]]),
                    "actor": "sorceress",
                    "blendin": sorc_anim.get("blendin", 0.4),
                    "blendout": sorc_anim.get("blendout", 0.4)
                    # "motionExtraction": false
                }
            }
        ]
    }
    if willey_anim:
        m_yml_scene["storyboard"][section_name][shot_name].append(
            {
                "actor.anim": {
                    ".@pos": flowed([willey_anim.get("start", 0.2), willey_anim["name"]]),
                    "actor": "willey",
                    "blendin": willey_anim.get("blendin", 0.4),
                    "blendout": willey_anim.get("blendout", 0.4),
                    "clipfront": willey_anim.get("clipfront", 0.0),
                    "clipend": willey_anim.get("clipend", 2.0)
                }
            }
        )
        m_yml_scene["storyboard"][section_name][shot_name].append(
            {
                "actor.anim.mimic": {
                    ".@pos": flowed([willey_anim.get("start", 0.2), m_pain_mimic_name]),
                    "actor": "willey",
                    "blendin": 0.4,
                    "blendout": 0.4
                }
            }
        )
    m_yml_scene["dialogscript"].yaml_set_comment_before_after_key(key=section_name, before='\n')
    return

def add_script_section(section_name: str, func_name: str, func_params: dict):
    global m_yml_scene
    m_yml_scene["dialogscript"][section_name] = [
        {
            "SCRIPT": {
                "function": func_name
            }
        }
    ]
    if func_params:
        m_yml_scene["dialogscript"][section_name][0]["SCRIPT"]["parameter"] = []
    for p in func_params.keys():
        m_yml_scene["dialogscript"][section_name][0]["SCRIPT"]["parameter"].append(
            {
                p: func_params[p]
            }
        )
    m_yml_scene["dialogscript"].yaml_set_comment_before_after_key(key=section_name, before='\n')
    return

def add_choice_section(section_name: str):
    global m_yml_scene
    m_yml_scene["dialogscript"][section_name] = [
        {
            "CHOICE": []
        }
    ]
    m_yml_scene["dialogscript"].yaml_set_comment_before_after_key(key=section_name, before='\n')
    return

def add_choice_option(in_section: str, text: str, to_section: str, condition=[], script_action=None):
    global m_yml_scene

    l_node_map = dict(
        {
            "choice": flowed([quoted(text), to_section]),
            "emphasize": True
        }
    )
    if text.startswith(STR.BACK):
        l_node_map["choice"] += ["exit"]
    if len(condition) > 0:
        l_node_map["condition"] = flowed(condition)
    if script_action is not None:
        l_node_map["scriptAction"] = script_action
    m_yml_scene["dialogscript"][in_section][0]["CHOICE"].append(l_node_map)
    return

def connect_sections(sections: list):
    from_section = ""
    for to_section in sections:
        if from_section != "":
            if m_yml_scene["dialogscript"][from_section] and "NEXT" in m_yml_scene["dialogscript"][from_section][-1]:
                print(f"[!] Connect_sections: connection already exists for section {from_section}")
                raise Exception(f"sections = {sections}")
                m_yml_scene["dialogscript"][from_section].pop()

            m_yml_scene["dialogscript"][from_section].append(
                {
                    "NEXT": to_section
                }
            )
        from_section = to_section
    return

def add_slash_type_option(sign: list):
    slash_types = [ "yennefer", "triss", "lynx", "philippa" ]
    lsign = sign[0].lower()
    preview_slashtype_script_section = f"script_preview_light_{lsign}_slash_type"
    # LIGHT: {SIGN> : Slash type section
    add_choice_section(f"section_choice_light_{lsign}_slash_type")
    # LIGHT: {SIGN> : Slash type section (preview stuff)
    add_script_section(preview_slashtype_script_section, "NR_SetMagicActionType_S",
                       {"actionType": ENR_MA.ENR_Slash.value})
    shot_duration = m_sorc_anims["AttackLightSlash"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackLightSlash"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_light_{lsign}_slash_type", f"shot_preview_light_{lsign}_slash_type", shot_duration)
    add_preview_sbui_section(f"section_preview_light_{lsign}_slash_type", f"shot_preview_light_{lsign}_slash_type",
        {
         "name": m_sorc_anims["AttackLightSlash"][0]["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit1"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_slashtype_script_section, f"section_preview_light_{lsign}_slash_type", f"section_choice_light_{lsign}_slash_type"])
    add_choice_option(f"section_choice_light_{lsign}", STR.type + "|", f"section_choice_light_{lsign}_slash_type", [],
    {
        ".class": "NR_FormattedLocChoiceAction",
        "str": f"{{{sign[1]}}}: {{{STR.slash}}}: ",  # SIGN name
    })
    add_choice_option(f"section_choice_light_{lsign}_slash_type", STR.BACK + "|",
                      f"section_choice_light_{lsign}")
    for type in slash_types:
        script_set_section = f"script_light_{lsign}_slash_type_{type}"
        add_script_section(script_set_section, "NR_SetMagicParamName_S", {
            "signName": CNAME(sign[0]),
            "varName": f"style_{ENR_MA.ENR_Slash.name}",
            "varValue": CNAME(type)
        })
        # <SIGN}: {Slash type}: {TYPE>
        add_choice_option(f"section_choice_light_{lsign}_slash_type", f"{m_mages[type]['str']}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.slash}}}: ",  # SIGN name: Slash type
        })
        connect_sections([script_set_section, preview_slashtype_script_section])

def add_slash_color_option(sign: list):
    global m_colors
    lsign = sign[0].lower()
    preview_slashcolor_script_section = f"script_preview_light_{lsign}_slash_color"
    add_choice_section(f"section_choice_light_{lsign}_slash_color")

    add_script_section(preview_slashcolor_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_Slash.value})
    shot_duration = m_sorc_anims["AttackLightSlash"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackLightSlash"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_light_{lsign}_slash_color", f"shot_preview_light_{lsign}_slash_color", shot_duration)
    add_preview_sbui_section(f"section_preview_light_{lsign}_slash_color", f"shot_preview_light_{lsign}_slash_color",
        {
         "name": m_sorc_anims["AttackLightSlash"][0]["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit1"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_slashcolor_script_section, f"section_preview_light_{lsign}_slash_color", f"section_choice_light_{lsign}_slash_color"])
    add_choice_option(f"section_choice_light_{lsign}", STR.color, f"section_choice_light_{lsign}_slash_color", [],
    {
        ".class": "NR_FormattedLocChoiceAction",
        "str": f"{{{sign[1]}}}: {{{STR.slash}}}: ",  # SIGN name
    })
    add_choice_option(f"section_choice_light_{lsign}_slash_color", STR.BACK + "|", f"section_choice_light_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in {"Black", "Grey", "Special1", "Special2", "Special3"}:
            continue
        script_set_section = f"script_light_{lsign}_slash_color_{color[0].lower()}"
        add_script_section(script_set_section, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"color_{ENR_MA.ENR_Slash.name}",
            "varValue": color_i
        })
        # <SIGN}: Slash color: {COLOR>
        add_choice_option(f"section_choice_light_{lsign}_slash_color", f"{color[-1]}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.slash}}}: ",  # SIGN name: Slash color
        })
        connect_sections([script_set_section, preview_slashcolor_script_section])

def add_throw_type_option(sign: list):
    lightning_types = [ "keira", "lynx" ]
    projectile_types = [ "triss", "philippa", "caranthir" ]
    lsign = sign[0].lower()
    suffix = "throw_type"
    preview_type_script_section = f"script_preview_light_{lsign}_{suffix}"
    add_choice_section(f"section_choice_light_{lsign}_{suffix}")
    add_script_section(preview_type_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_ThrowAbstract.value})
    shot_duration = m_sorc_anims["AttackLightThrow"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackLightThrow"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_light_{lsign}_{suffix}", f"shot_preview_light_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_light_{lsign}_{suffix}", f"shot_preview_light_{lsign}_{suffix}",
        {
         "name": m_sorc_anims["AttackLightThrow"][0]["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit3"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_type_script_section, f"section_preview_light_{lsign}_{suffix}", f"section_choice_light_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_light_{lsign}", f"{STR.type}|", f"section_choice_light_{lsign}_{suffix}", [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{STR.throw}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_light_{lsign}_{suffix}", STR.BACK + "|",
                      f"section_choice_light_{lsign}")

    for type_i, type_v in enumerate(lightning_types):
        script_set_section = f"script_light_{lsign}_{suffix}_lightning_{type_v}_1"
        add_script_section(script_set_section, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"type_{ENR_MA.ENR_ThrowAbstract.name}",
            "varValue": ENR_MA.ENR_Lightning.value
        })
        script_set_section2 = f"script_light_{lsign}_{suffix}_lightning_{type_v}_2"
        add_script_section(script_set_section2, "NR_SetMagicParamName_S", {
            "signName": CNAME(sign[0]),
            "varName": f"style_{ENR_MA.ENR_Lightning.name}",
            "varValue": CNAME(type_v)
        })
        add_choice_option(f"section_choice_light_{lsign}_{suffix}", f"{m_mages[type_v]['str']}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.lightning}}}: "
        })
        connect_sections([script_set_section, script_set_section2, preview_type_script_section])

    for type_i, type_v in enumerate(projectile_types):
        script_set_section = f"script_light_{lsign}_{suffix}_projectile_{type_v}_1"
        add_script_section(script_set_section, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"type_{ENR_MA.ENR_ThrowAbstract.name}",
            "varValue": ENR_MA.ENR_ProjectileWithPrepare.value
        })
        script_set_section2 = f"script_light_{lsign}_{suffix}_projectile_{type_v}_2"
        add_script_section(script_set_section2, "NR_SetMagicParamName_S", {
            "signName": CNAME(sign[0]),
            "varName": f"style_{ENR_MA.ENR_ProjectileWithPrepare.name}",
            "varValue": CNAME(type_v)
        })
        add_choice_option(f"section_choice_light_{lsign}_{suffix}", f"{m_mages[type_v]['str']}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.projectile}}}: "
        })
        connect_sections([script_set_section, script_set_section2, preview_type_script_section])

def add_throw_color_option(sign: list):
    global m_colors
    lsign = sign[0].lower()
    preview_throwcolor_script_section = f"script_preview_light_{lsign}_throw_color"
    add_choice_section(f"section_choice_light_{lsign}_throw_color")
    add_script_section(preview_throwcolor_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_ThrowAbstract.value})
    shot_duration = m_sorc_anims["AttackLightThrow"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackLightThrow"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_light_{lsign}_throw_color", f"shot_preview_light_{lsign}_throw_color", shot_duration)
    add_preview_sbui_section(f"section_preview_light_{lsign}_throw_color", f"shot_preview_light_{lsign}_throw_color",
        {
         "name": m_sorc_anims["AttackLightThrow"][0]["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit3"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_throwcolor_script_section, f"section_preview_light_{lsign}_throw_color",
                      f"section_choice_light_{lsign}_throw_color"])
    add_choice_option(f"section_choice_light_{lsign}", STR.color + "|", f"section_choice_light_{lsign}_throw_color", [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{STR.throw}}}:"  # SIGN name
        })
    add_choice_option(f"section_choice_light_{lsign}_throw_color", STR.BACK + "|",
                      f"section_choice_light_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in {"Black", "Grey", "Special1", "Special2", "Special3"}:
            continue
        script_set_color_name = f"script_light_{lsign}_throw_color_{color[0].lower()}"
        add_script_section(script_set_color_name, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"color_{ENR_MA.ENR_ThrowAbstract.name}",
            "varValue": color_i
        })
        add_choice_option(f"section_choice_light_{lsign}_throw_color", f"{color[-1]}", script_set_color_name, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.throw}}}: "  # SIGN name: Throw color
        })
        connect_sections([script_set_color_name, preview_throwcolor_script_section])

def add_hand_type_option(sign: list):
    hand_types = [ "yennefer", "keira", "triss", "philippa" ]
    lsign = sign[0].lower()
    suffix = "type"
    prefix = "hand"
    add_choice_option(f"section_choice_{prefix}_{lsign}", STR.type + "|", f"section_choice_{prefix}_{lsign}_{suffix}", [], {
        ".class": "NR_FormattedLocChoiceAction",
        "str": f"{{{sign[1]}}}: {{{STR.hand_effect}}}: "  # SIGN name
    })
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_dummy_section(f"section_entry_{prefix}_{lsign}_{suffix}", 0.0)  # NO PREVIEW!
    connect_sections([f"section_entry_{prefix}_{lsign}_{suffix}", f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", STR.BACK + "|",
                      f"section_choice_{prefix}_{lsign}")

    for type_i, type_v in enumerate(hand_types):
        script_set_section = f"script_{prefix}_{lsign}_{suffix}_{type_v}"
        add_script_section(script_set_section, "NR_SetMagicParamName_S", {
            "signName": CNAME(sign[0]),
            "varName": f"style_{ENR_MA.ENR_HandFx.name}",
            "varValue": CNAME(type_v)
        })
        script_upd_section = f"script_{prefix}_{lsign}_{suffix}_{type_v}_upd"
        add_script_section(script_upd_section, "NR_SetMagicUpdateHandFx_S", {})
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{m_mages[type_v]['str']}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.hand_effect}}}: "
        })
        connect_sections([script_set_section, script_upd_section, f"section_entry_{prefix}_{lsign}_{suffix}"])

def add_hand_color_option(sign: list):
    global m_colors
    lsign = sign[0].lower()
    suffix = "color"
    prefix = "hand"
    add_choice_option(f"section_choice_{prefix}_{lsign}", STR.color + "|", f"section_choice_{prefix}_{lsign}_{suffix}", [], {
        ".class": "NR_FormattedLocChoiceAction",
        "str": f"{{{sign[1]}}}: {{{STR.hand_effect}}}: "  # SIGN name
    })
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_dummy_section(f"section_entry_{prefix}_{lsign}_{suffix}", 0.0)  # NO PREVIEW!
    connect_sections([f"section_entry_{prefix}_{lsign}_{suffix}", f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", STR.BACK + "|",
                      f"section_choice_{prefix}_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in {"Black", "Grey", "Special1", "Special2", "Special3"}:
            continue
        script_set_section = f"script_{prefix}_{lsign}_{suffix}_{color[0].lower()}"
        add_script_section(script_set_section, "NR_SetMagicParamInt_S", {
            "signName": CNAME(sign[0]),
            "varName": f"color_{ENR_MA.ENR_HandFx.name}",
            "varValue": color_i
        })
        script_upd_section = f"script_{prefix}_{lsign}_{suffix}_{color[0].lower()}_upd"
        add_script_section(script_upd_section, "NR_SetMagicUpdateHandFx_S", {})
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{color[-1]}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.hand_effect}}}: "  # SIGN name: Hand effect color
        })
        connect_sections([script_set_section, script_upd_section, f"section_entry_{prefix}_{lsign}_{suffix}"])

def add_rocks_type_option(sign: list):
    rocks_types = [ "keira", "djinn" ]
    lsign = sign[0].lower()
    suffix = "rocks_type"
    prefix = "heavy"
    preview_type_script_section = f"script_preview_{prefix}_{lsign}_{suffix}"
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_script_section(preview_type_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_Rock.value})

    shot_duration = m_sorc_anims["AttackHeavyRock"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackHeavyRock"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}",
        {
            "name": m_sorc_anims["AttackHeavyRock"][0]["name"]
        },
        {
             "start": willey_start_s / shot_duration,
             "name": m_willey_anims["hit3"]["name"],
             "clipend": shot_duration - willey_start_s + 0.5,
             "clipfront": 0.5
        }
    )
    connect_sections([preview_type_script_section, f"section_preview_{prefix}_{lsign}_{suffix}", f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{STR.type}|", f"section_choice_{prefix}_{lsign}_{suffix}", [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{STR.rocks}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for type_i, type_v in enumerate(rocks_types):
        script_set_section = f"script_{prefix}_{lsign}_{suffix}_{type_v}"
        add_script_section(script_set_section, "NR_SetMagicParamName_S", {
            "signName": CNAME(sign[0]),
            "varName": f"style_{ENR_MA.ENR_Rock.name}",
            "varValue": CNAME(type_v)
        })
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{m_mages[type_v]['str']}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.rocks}}}: "
        })
        connect_sections([script_set_section, preview_type_script_section])

def add_rocks_color_option(sign: list):
    global m_colors
    lsign = sign[0].lower()
    suffix = "rocks_color"
    prefix = "heavy"
    preview_throwcolor_script_section = f"script_preview_{prefix}_{lsign}_{suffix}"
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_script_section(preview_throwcolor_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_Rock.value})
    shot_duration = m_sorc_anims["AttackHeavyRock"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackHeavyRock"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}",
        {
         "name": m_sorc_anims["AttackHeavyRock"][0]["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit3"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_throwcolor_script_section, f"section_preview_{prefix}_{lsign}_{suffix}",
                      f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{STR.color}|", f"section_choice_{prefix}_{lsign}_{suffix}", [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{STR.rocks}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in {"Black", "Grey", "Special1", "Special2", "Special3"}:
            continue
        script_set_color_name = f"script_{prefix}_{lsign}_{suffix}_{color[0].lower()}"
        add_script_section(script_set_color_name, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"color_{ENR_MA.ENR_Rock.name}",
            "varValue": color_i
        })
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{color[-1]}", script_set_color_name, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.rocks}}}: "  # SIGN name: Throw color
        })
        connect_sections([script_set_color_name, preview_throwcolor_script_section])

def add_rocks_cone_color_option(sign: list):
    global m_colors
    lsign = sign[0].lower()
    suffix = "rocks_cone"
    prefix = "heavy"
    preview_throwcolor_script_section = f"script_preview_{prefix}_{lsign}_{suffix}"
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_script_section(preview_throwcolor_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_Rock.value})
    shot_duration = m_sorc_anims["AttackHeavyRock"][0]["duration"] + 0.5
    willey_start_s = m_sorc_anims["AttackHeavyRock"][0]["perform"] - 0.1
    add_preview_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}",
        {
         "name": m_sorc_anims["AttackHeavyRock"][0]["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit3"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_throwcolor_script_section, f"section_preview_{prefix}_{lsign}_{suffix}",
                      f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{STR.color}|", f"section_choice_{prefix}_{lsign}_{suffix}", [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{STR.rocks_wave}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in {"Black", "Grey", "Special1", "Special2", "Special3"}:
            continue
        script_set_color_name = f"script_{prefix}_{lsign}_{suffix}_{color[0].lower()}"
        add_script_section(script_set_color_name, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"color_cone_{ENR_MA.ENR_Rock.name}",
            "varValue": color_i
        })
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{color[-1]}", script_set_color_name, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.rocks_wave}}}: "  # SIGN name: Throw color
        })
        connect_sections([script_set_color_name, preview_throwcolor_script_section])

def add_bomb_color_option(sign: list):
    global m_colors
    lsign = sign[0].lower()
    suffix = "bomb_color"
    prefix = "heavy"
    cast_anim = m_sorc_anims["AttackHeavyThrow"][0]

    preview_throwcolor_script_section = f"script_preview_{prefix}_{lsign}_{suffix}"
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_script_section(preview_throwcolor_script_section, "NR_SetMagicActionType_S", {"actionType": ENR_MA.ENR_BombExplosion.value})
    shot_duration = cast_anim["duration"] + 0.5
    willey_start_s = cast_anim["perform"] - 0.1
    add_preview_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}",
        {
         "name": cast_anim["name"]
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims["hit3"]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        }
    )
    connect_sections([preview_throwcolor_script_section, f"section_preview_{prefix}_{lsign}_{suffix}",
                      f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{STR.color}|", f"section_choice_{prefix}_{lsign}_{suffix}", [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{STR.bomb}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in {"Black", "Grey", "Special1", "Special2", "Special3"}:
            continue
        script_set_color_name = f"script_{prefix}_{lsign}_{suffix}_{color[0].lower()}"
        add_script_section(script_set_color_name, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"color_{ENR_MA.ENR_BombExplosion.name}",
            "varValue": color_i
        })
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{color[-1]}", script_set_color_name, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{STR.bomb}}}: "  # SIGN name: Throw color
        })
        connect_sections([script_set_color_name, preview_throwcolor_script_section])

def add_teleport_type_option(sign: list):
    teleport_types = [ "yennefer", "triss", "ofieri", "hermit" ]
    not_colorized_types = { "ofieri" }
    suffix = "type"
    prefix = "teleport"
    choice_str0 = STR.teleport
    choice_str1 = STR.type
    action = ENR_MA.ENR_Teleport
    deny_fact = f"nr_denied_type_{action.name}"
    color_deny_fact = f"nr_denied_color_{action.name}"
    cast_anim = m_sorc_anims["AttackTeleport"][0]
    willey_anim_name = str()  # "hit3"
    add_generic_type_option(teleport_types, not_colorized_types, sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, color_deny_fact, cast_anim, willey_anim_name)

def add_teleport_color_option(sign: list):
    suffix = "color"
    prefix = "teleport"
    choice_str0 = STR.teleport
    choice_str1 = STR.color
    action = ENR_MA.ENR_Teleport
    deny_fact = f"nr_denied_color_{action.name}"
    cast_anim = m_sorc_anims["AttackTeleport"][0]
    willey_anim_name = str()  # "hit3"
    forbidden_colors = {"Black", "Grey", "Special1", "Special2", "Special3"}
    add_generic_color_option(sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, cast_anim, willey_anim_name, forbidden_colors)

def add_generic_type_option(action_types, not_colorized_types, sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, color_deny_fact, cast_anim, willey_anim_name):
    lsign = sign[0].lower()
    preview_type_script_section = f"script_preview_{prefix}_{lsign}_{suffix}"
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_script_section(preview_type_script_section, "NR_SetMagicActionType_S", {"actionType": action.value})

    shot_duration = cast_anim["duration"] + 0.5
    willey_start_s = cast_anim["perform"] - 0.1
    add_preview_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}",
        {
            "name": cast_anim["name"]
        },
        {
             "start": willey_start_s / shot_duration,
             "name": m_willey_anims[willey_anim_name]["name"],
             "clipend": shot_duration - willey_start_s + 0.5,
             "clipfront": 0.5
        } if willey_anim_name else {}
    )
    connect_sections([preview_type_script_section, f"section_preview_{prefix}_{lsign}_{suffix}", f"section_choice_{prefix}_{lsign}_{suffix}"])
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{choice_str1}|", f"section_choice_{prefix}_{lsign}_{suffix}", [deny_fact, "<", 1] if deny_fact else [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{choice_str0}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for type_i, type_v in enumerate(action_types):
        script_set_section = f"script_{prefix}_{lsign}_{suffix}_{type_v}"
        add_script_section(script_set_section, "NR_SetMagicParamName_S", {
            "signName": CNAME(sign[0]),
            "varName": f"style_{action.name}",
            "varValue": CNAME(type_v)
        })
        script_set_section2 = script_set_section
        if not_colorized_types and color_deny_fact:
            script_set_section2 = f"script_{prefix}_{lsign}_{suffix}_{type_v}_2"
            if type_v in not_colorized_types:
                add_script_section(script_set_section2, "AddFact_S", {
                    "factName": color_deny_fact,
                    "value": 1,
                    "validFor": -1,
                    "telemetryEvent": False
                })
                connect_sections([script_set_section, script_set_section2])
            else:
                add_script_section(script_set_section2, "RemoveFact_S", {
                    "factId": color_deny_fact
                })
                connect_sections([script_set_section, script_set_section2])

        connect_sections([script_set_section2, preview_type_script_section])
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{m_mages[type_v]['str']}", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{choice_str0}}}: "
        })

def add_generic_color_option(sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, cast_anim, willey_anim_name, forbidden_colors):
    global m_colors
    lsign = sign[0].lower()
    preview_throwcolor_script_section = f"script_preview_{prefix}_{lsign}_{suffix}"
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_script_section(preview_throwcolor_script_section, "NR_SetMagicActionType_S", {"actionType": action.value})
    shot_duration = cast_anim["duration"] + 0.5
    willey_start_s = cast_anim["perform"] - 0.1
    add_preview_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}", shot_duration)
    add_preview_sbui_section(f"section_preview_{prefix}_{lsign}_{suffix}", f"shot_preview_{prefix}_{lsign}_{suffix}",
        {
            "name": cast_anim["name"],
            "blendin": min(cast_anim["duration"] * 0.25, 0.4),
            "blendout": min(cast_anim["duration"] * 0.25, 0.4),
        },
        {
         "start": willey_start_s / shot_duration,
         "name": m_willey_anims[willey_anim_name]["name"],
         "clipend": shot_duration - willey_start_s + 0.5,
         "clipfront": 0.5
        } if willey_anim_name else {}
    )
    connect_sections([preview_throwcolor_script_section, f"section_preview_{prefix}_{lsign}_{suffix}",
                      f"section_choice_{prefix}_{lsign}_{suffix}"])
    cond = []
    if deny_fact:
        cond = [deny_fact, "<", 1]
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{choice_str1}|", f"section_choice_{prefix}_{lsign}_{suffix}", cond,
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for color_i, color in enumerate(m_colors):
        if color[0] in forbidden_colors:
            continue
        script_set_color_name = f"script_{prefix}_{lsign}_{suffix}_{color[0].lower()}"
        add_script_section(script_set_color_name, "NR_SetMagicParamInt_S", {
            "signName": f"CNAME_{sign[0]}",
            "varName": f"color_{action.name}",
            "varValue": color_i
        })
        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{color[-1]}", script_set_color_name, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{sign[1]}}}: {{{choice_str0}}}: "  # SIGN name: Throw color
        })
        connect_sections([script_set_color_name, preview_throwcolor_script_section])

def add_push_color_option(sign: list):
    prefix = "heavy"
    suffix = "push_color"
    choice_str0 = STR.push
    choice_str1 = STR.color
    action = ENR_MA.ENR_CounterPush
    deny_fact = str()
    cast_anim = m_sorc_anims["AttackPush"][0]
    willey_anim_name = str()  # "hit3"
    forbidden_colors = {"Black", "Grey", "Special1", "Special2", "Special3"}
    add_generic_color_option(sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, cast_anim, willey_anim_name, forbidden_colors)

def add_ft_teleport_type_option(sign: list):
    types = [ "default", "keira", "wild_hunt" ]
    not_colorized_types = {}  # { "ofieri" }
    suffix = "ft_type"
    prefix = "teleport"
    choice_str0 = STR.ft_teleport
    choice_str1 = STR.type
    action = ENR_MA.ENR_FastTravelTeleport
    deny_fact = str()  # f"nr_denied_type_{action.name}"
    color_deny_fact = str()  # f"nr_denied_color_{action.name}"
    cast_anim = m_sorc_anims["AttackSpecialElectricity"][0]
    willey_anim_name = "hit1"
    add_generic_type_option(types, not_colorized_types, sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, color_deny_fact, cast_anim, willey_anim_name)

def add_ft_teleport_color_option(sign: list):
    suffix = "ft_color"
    prefix = "teleport"
    choice_str0 = STR.ft_teleport
    choice_str1 = STR.color
    action = ENR_MA.ENR_FastTravelTeleport
    deny_fact = str() #f"nr_denied_color_{action.name}"
    cast_anim = m_sorc_anims["AttackSpecialElectricity"][0]
    willey_anim_name = "hit1"
    forbidden_colors = {"Black", "Grey", "Special1", "Special2", "Special3"}
    add_generic_color_option(sign, suffix, prefix, choice_str0, choice_str1, action, deny_fact, cast_anim, willey_anim_name, forbidden_colors)

def add_special_type_option(sign: list):
    special_types_str = [ STR.tornado, STR.control, STR.meteor, STR.sphere, STR.golem ]
    special_types_val = [ ENR_MA.ENR_SpecialTornado, ENR_MA.ENR_SpecialControl, ENR_MA.ENR_SpecialMeteor, ENR_MA.ENR_SpecialSphere, ENR_MA.ENR_SpecialGolem ]

    not_colorized_types = {}  # { "ofieri" }
    suffix = "type"
    prefix = "special"
    choice_str0 = STR.special_spells
    choice_str1 = STR.special_spells_binding
    action = ENR_MA.ENR_SpecialAbstract
    deny_fact = str()  # f"nr_denied_color_{action.name}"
    forbidden_colors = {"Black", "Grey", "Special1", "Special2", "Special3"}

    lsign = sign[0].lower()
    add_choice_section(f"section_choice_{prefix}_{lsign}_{suffix}")
    add_choice_option(f"section_choice_{prefix}_{lsign}", f"{choice_str1}|", f"section_choice_{prefix}_{lsign}_{suffix}", [deny_fact, "<", 1] if deny_fact else [],
        {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{sign[1]}}}: {{{choice_str0}}}: "  # SIGN name
        })
    add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{STR.BACK}|",
                      f"section_choice_{prefix}_{lsign}")

    for type_i, type_v in enumerate(special_types_val):
        script_set_section = f"script_{prefix}_{lsign}_{suffix}_{special_types_str[type_i].name}"
        add_script_section(script_set_section, "NR_SetMagicParamInt_S", {
            "signName": CNAME(sign[0]),
            "varName": f"type_{action.name}",
            "varValue": type_v.value
        })
        script_set_section2 = f"script_{prefix}_{lsign}_{suffix}_{special_types_str[type_i].name}_2"
        add_script_section(script_set_section2, "AddFact_S", {
            "factName": f"nr_type_special_{sign[1]}",
            "value": type_v.value,
            "validFor": -1,
            "telemetryEvent": False
        })
        connect_sections([script_set_section, script_set_section2])
        connect_sections([script_set_section2, f"section_choice_{prefix}_{lsign}_{suffix}"])

        add_choice_option(f"section_choice_{prefix}_{lsign}_{suffix}", f"{special_types_str[type_i].value}|", script_set_section, [], {
            ".class": "NR_FormattedLocChoiceAction",
            "str": f"{{{choice_str0}}}: {{{sign[1]}}}: "
        })


def load_yml():
    global m_yml_scene
    with open(f"scene.03.player_change_sorceress_BASE.yml", mode="r") as yf:
        start_t = time.time()
        m_yml_scene = yaml.load(yf, Loader=yaml.RoundTripLoader, preserve_quotes=True)
        end_t = time.time()
        print(f"[*] Scene YML loaded in {end_t - start_t} s")

def save_yml():
    global m_yml_scene
    yamd = ruamel.yaml.YAML()
    yamd.indent(mapping=2, sequence=4, offset=2)
    yamd.width = 4096
    with open(f"scene.03.player_change_sorceress.yml", mode="w") as yw:
        start_t = time.time()
        yamd.dump(m_yml_scene, yw)
        end_t = time.time()
        print(f"[*] Scene YML saved in: {end_t - start_t} s")

def copy_yml():
    shutil.copy2(f"scene.03.player_change_sorceress.yml", f"../definition.scenes/scene.03.player_change_sorceress.yml")
    print(f"[*] Scene YML copied")

def main():
    global m_yml_scene, m_signs, m_colors
    start_t = time.time()

    # HAND FX
    add_choice_section("section_choice_hand")
    add_choice_option("section_choice_hand", STR.BACK + "|", "script_info_main")
    add_script_section("script_info_hand", "NR_ShowMagicInfo_S", {"sectionName": CNAME("hand")})
    connect_sections(["script_info_hand", "section_choice_hand"])

    for sign in m_signs:
        lsign = sign[0].lower()
        script_section = f"script_set_hand_sign_{lsign}"
        # set sign type for MM
        add_script_section(script_section, "NR_SetMagicSignName_S", {"signName": f"CNAME_{sign[0]}"})
        # sign selection
        add_choice_option("section_choice_hand", sign[-1], script_section, [], {
              ".class": "NR_FormattedLocChoiceAction",
              "str": f"{{{STR.hand_effect}}}: "  # Hand effect
        })
        # go to light <sign> section
        connect_sections([script_section, f"section_choice_hand_{lsign}"])

        add_choice_section(f"section_choice_hand_{lsign}")
        add_choice_option(f"section_choice_hand_{lsign}", STR.BACK + "|", "section_choice_hand")

        add_hand_type_option(sign)
        add_hand_color_option(sign)

    # LIGHT ATTACKS
    add_choice_section("section_choice_light")
    add_choice_option("section_choice_light", STR.BACK + "|", "script_info_main")
    add_script_section("script_info_light", "NR_ShowMagicInfo_S", {"sectionName": CNAME("light")})
    connect_sections(["script_info_light", "section_choice_light"])

    # LIGHT: Ratio (section_light_ratio_entry predefined)
    add_choice_option("section_choice_light", STR.light_ratio,
    "section_light_ratio_entry", [], {
      ".class": "NR_FormattedLocChoiceAction",
      "str": f"{{{STR.light_attacks}}}: "
    })

    # LIGHT: SIGNS base
    for sign in m_signs:
        lsign = sign[0].lower()
        script_section = f"script_set_light_sign_{lsign}"
        # set sign type for MM
        add_script_section(script_section, "NR_SetMagicSignName_S", {"signName": f"CNAME_{sign[0]}"})
        # sign selection
        add_choice_option("section_choice_light", sign[-1], script_section, [], {
              ".class": "NR_FormattedLocChoiceAction",
              "str": f"{{{STR.light_attacks}}}: "
        })
        # go to light <sign> section
        connect_sections([script_section, f"section_choice_light_{lsign}"])

        # add light <sign> section
        add_choice_section(f"section_choice_light_{lsign}")
        add_choice_option(f"section_choice_light_{lsign}", STR.BACK + "|", "section_choice_light")

        add_slash_type_option(sign)
        add_slash_color_option(sign)

        # LIGHT: <SIGN> : Throw type
        add_throw_type_option(sign)

        # LIGHT: <SIGN> : Throw color
        add_throw_color_option(sign)

    # HEAVY ATTACKS
    add_choice_section("section_choice_heavy")
    add_choice_option("section_choice_heavy", STR.BACK + "|", "script_info_main")
    add_script_section("script_info_heavy", "NR_ShowMagicInfo_S", {"sectionName": CNAME("heavy")})
    connect_sections(["script_info_heavy", "section_choice_heavy"])

    # HEAVY: Ratio (section_heavy_ratio_entry predefined)
    add_choice_option("section_choice_heavy", STR.heavy_ratio,
        "section_heavy_ratio_entry", [], {
          ".class": "NR_FormattedLocChoiceAction",
          "str": f"{{{STR.heavy_attacks}}}: "
    })

    # HEAVY: SIGNS
    for sign in m_signs:
        lsign = sign[0].lower()
        script_section = f"script_set_heavy_sign_{lsign}"
        # set sign type for MM
        add_script_section(script_section, "NR_SetMagicSignName_S", {"signName": f"CNAME_{sign[0]}"})
        # sign selection
        add_choice_option("section_choice_heavy", sign[-1], script_section, [], {
              ".class": "NR_FormattedLocChoiceAction",
              "str": f"{{{STR.heavy_attacks}}}: "
        })
        # go to heavy <sign> section
        connect_sections([script_section, f"section_choice_heavy_{lsign}"])

        # add heavy <sign> section
        add_choice_section(f"section_choice_heavy_{lsign}")
        add_choice_option(f"section_choice_heavy_{lsign}", STR.BACK + "|", "section_choice_heavy")

        add_rocks_type_option(sign)
        add_rocks_color_option(sign)
        add_rocks_cone_color_option(sign)

        #add_bomb_type_option(sign)
        add_bomb_color_option(sign)

        add_push_color_option(sign)

    # TELEPORT
    add_choice_section("section_choice_teleport")
    add_choice_option("section_choice_teleport", STR.BACK + "|", "script_info_main")
    add_script_section("script_info_teleport", "NR_ShowMagicInfo_S", {"sectionName": CNAME("teleport")})
    connect_sections(["script_info_teleport", "section_choice_teleport"])

    # TELEPORT: SIGNS
    for sign in m_signs:
        lsign = sign[0].lower()
        script_section = f"script_set_sign_teleport_{lsign}"
        # set sign type for MM
        add_script_section(script_section, "NR_SetMagicSignName_S", {"signName": f"CNAME_{sign[0]}"})
        # sign selection
        add_choice_option("section_choice_teleport", sign[-1], script_section, [], {
              ".class": "NR_FormattedLocChoiceAction",
              "str": f"{{{STR.heavy_attacks}}}: "
        })
        # go to teleport <sign> section
        connect_sections([script_section, f"section_choice_teleport_{lsign}"])

        # add teleport <sign> section
        add_choice_section(f"section_choice_teleport_{lsign}")
        add_choice_option(f"section_choice_teleport_{lsign}", STR.BACK + "|", "section_choice_teleport")

        add_teleport_type_option(sign)
        add_teleport_color_option(sign)

        add_ft_teleport_type_option(sign)
        add_ft_teleport_color_option(sign)

    # SPECIAL ATTACKS
    add_choice_section("section_choice_special")
    add_choice_option("section_choice_special", STR.BACK + "|", "script_info_main")
    add_script_section("script_info_special", "NR_ShowMagicInfo_S", {"sectionName": CNAME("special")})
    connect_sections(["script_info_special", "section_choice_special"])

    # SPECIAL: SIGNS
    for sign in m_signs:
        lsign = sign[0].lower()
        script_section = f"script_set_sign_special_{lsign}"
        # set sign type for MM
        add_script_section(script_section, "NR_SetMagicSignName_S", {"signName": f"CNAME_{sign[0]}"})
        # sign selection
        add_choice_option("section_choice_special", sign[-1], script_section, [], {
              ".class": "NR_FormattedLocChoiceAction",
              "str": f"{{{STR.special_spells}}}: "
        })
        # go to special <sign> section
        connect_sections([script_section, f"section_choice_special_{lsign}"])

        # add special <sign> section
        add_choice_section(f"section_choice_special_{lsign}")
        add_choice_option(f"section_choice_special_{lsign}", STR.BACK + "|", "section_choice_special")

        add_special_type_option(sign)
        #add_special_tornado_type_option(sign)
        #add_special_meteor_type_option(sign)
        #add_special_meteor_color_option(sign)
        #add_special_golem_type_option(sign)
        # add_special_control_type_option(sign)
        #add_special_sphere_color_option(sign)

    end_t = time.time()
    print(f"[*] Scene YML handled in: {end_t - start_t} s")

load_yml()
main()
save_yml()
copy_yml()
print("DONE!")