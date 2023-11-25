import os
import json
import time

import random
import ruamel.yaml
from ruamel.yaml import comments, CommentedMap, CommentedSeq, YAML
from ruamel import yaml
from pathlib import Path
from shutil import copy2
from functools import cmp_to_key
from copy import deepcopy

gesture_data = {
    "male": dict(),
    "female": dict()
}
# ADD_BY_DEFAULT = True

def flowed(seq: list):
    ret = comments.CommentedSeq(seq)
    ret.fa.set_flow_style()
    return ret


def read_yml_nicely(path):
    print(f"YML load {path}")
    with open(path, mode="r", encoding="utf-8") as yf:
            start_t = time.time()
            yaml_loader = YAML(typ="rt")
            yaml_loader.preserve_quotes = True
            yml = yaml_loader.load(yf)
            end_t = time.time()
            print(f"YML loaded in: {end_t - start_t} s")
    return yml


def write_yml_nicely(path, data):
    print(f"YML save: {path}")
    with open(path, mode="w", encoding="utf-8") as f_yml:
        start_t = time.time()
        yaml_dumper = ruamel.yaml.YAML()
        yaml_dumper.indent(mapping=2, sequence=4, offset=2)
        yaml_dumper.width = 4096
        yaml_dumper.dump(data, f_yml)
        end_t = time.time()
        print(f"YML saved in: {end_t - start_t} s: {path}")


def heuristic_duration(s : str) -> float:
    if len(s) < 20:
        factor = 0.11
    elif len(s) < 50:
        factor = 0.08
    elif len(s) < 75:
        factor = 0.075
    else:
        factor = 0.073
    return max(1.0, len(s) * factor)
        
        
def key_1st(obj) -> str:
    return list(obj.keys())[0]
    
    
def event_pos(event) -> float:
    event_key = key_1st(event)
    event_val = event[event_key]
    return event_val[0] if isinstance(event_val, list) else event_val[".@pos"][0]
    
    
def pose_raw_name(yml, sb_name) -> str:
    prod_name = yml["production"]["assets"]["actor.poses"][sb_name]["repo"]
    return yml["repository"]["actor.poses"][prod_name]["idle_anim"]
    

def pose_actor(yml, sb_name) -> str:
    return yml["production"]["assets"]["actor.poses"][sb_name]["actor"]
    

                
def process_yml(input_path, output_path):
    global gesture_data
    print(f"Process yml: {input_path}")
    yml = read_yml_nicely(input_path)
    actors = yml["dialogscript"]["actors"]
    actors_genders = dict()
    default_actors = set()
    added_gestures = 0
    default_actor_poses = {
        x: "high_standing_determined_idle" for x in actors
    }
    
    if "actor.pose" in yml["storyboard"]["defaults"]:
        for actor in yml["storyboard"]["defaults"]["actor.pose"]:
            pose_name = yml["storyboard"]["defaults"]["actor.pose"][actor]
            default_actor_poses[actor] = pose_raw_name(yml, pose_name)
    
    if "auto.additive" in yml["storyboard"]["defaults"]:
        for actor in yml["storyboard"]["defaults"]["auto.additive"]:
            default_actors.add(actor)
            actors_genders[actor] = yml["storyboard"]["defaults"]["auto.additive"][actor]
        del yml["storyboard"]["defaults"]["auto.additive"]
    
    for section_name in yml["dialogscript"]:
        if section_name in ["player", "actors"]:
            continue
            
        print(f"• Section: {section_name}")
        speaker = str()
        shot_name = str()
        shot_duration = -1
        allowed_actors = deepcopy(default_actors)
        blocked_actors = set()
        actor_poses = deepcopy(default_actor_poses)
        
        for element in yml["dialogscript"][section_name]:
            if not isinstance(element, dict):
                continue
               
            key = list(element.keys())[0]
            value = element[key]
            # print(f"   > key = {key}")
            
            if key in ["CUE", "HINT"]:
                shot_name = value
                shot_duration = -1
                speaker = str()
                continue
            elif key in ["NEXT", "BLACKSCREEN", "EXIT", "OUTPUT", "SCRIPT", "RANDOM"]:
                shot_name = str()
                shot_duration = -1
                speaker = str()
                continue
            else:
                if key == "PAUSE":
                    shot_duration = float(value)
                    speaker = str()
                    continue
                elif key == "CHOICE":
                    shot_duration = 10.0
                    for choice_element in value:
                        if list(choice_element.keys())[0] == "TIME_LIMIT":
                            shot_duration = float(choice_element["TIME_LIMIT"])
                            break
                    speaker = str()
                    continue
                else:
                    speaker = key
                    shot_emotion = "explain"
                    
                    # print(f" V {key}")
                    if value.endswith("!"):
                        shot_emotion = "exclamation"
                    elif value.endswith("?"):
                       shot_emotion = "question"
                       
                    if "|" in value:
                        str_info = value.split("|")[0]
                        if "[" in str_info and "]" in str_info:
                            shot_duration = float(str_info.split("]")[0].split("[")[1])
                        else:
                            shot_duration = heuristic_duration(value.split("|")[1])
                    else:
                        shot_duration = heuristic_duration(value)
                    
                # print(f"   > Adjust gestures: shot name = {shot_name}, shot_duration = {shot_duration}, speaker = {speaker}")
                allowed_intervals = {
                    x: [] for x in actors
                }
                if section_name in yml["storyboard"] and shot_name in yml["storyboard"][section_name]:
                    # yml["storyboard"][section_name][shot_name].sort( key=cmp_to_key(lambda item1, item2: event_pos(item1) - event_pos(item2)))
                    allowed_start = {
                      x: 0 if x in allowed_actors or x in default_actors else -1 for x in actors
                    }
                    event_actor = str()
                    blocked_actors.clear()
                    events = list()
                    for i, shot_event in enumerate(yml["storyboard"][section_name][shot_name]):
                      event_key = key_1st(shot_event)
                      event_val = shot_event[event_key]
                      is_extended = isinstance(event_val, dict)
                      event_pos = event_val[0] if not is_extended else event_val[".@pos"][0]
                      # print(f"Event: {event_key} {event_pos}")
                      if event_key.startswith("auto."):
                          event_actor = event_val[1]
                          if event_key == "auto.additive.start":
                              allowed_actors.add(event_actor)
                              actors_genders[event_actor] = event_val[2]
                              if allowed_start[event_actor] < 0 and event_actor not in blocked_actors:
                                  allowed_start[event_actor] = event_pos
                          elif event_key == "auto.additive.stop":
                              allowed_actors.discard(event_actor)
                              if allowed_start[event_actor] >= 0 and event_pos > allowed_start[event_actor]:
                                  allowed_intervals[event_actor].append([allowed_start[event_actor], event_pos])
                              allowed_start[event_actor] = -1
                      else:
                          events.append(shot_event)

                          if event_key.endswith("actor.pose"):
                              event_pose = pose_raw_name(yml, event_val)
                              event_actor = pose_actor(yml, event_val)
                              actor_poses[event_actor] = event_pose
                              print(f"--- New pose[{event_actor}] = {event_pose}")
                          elif event_key.endswith("anim.additive") or event_key.endswith("anim"):
                              event_anim = event_val[1] if not is_extended else event_val[".@pos"][1]
                              if is_extended and "actor" in event_val:
                                  event_actor = event_val["actor"]
                              else:
                                  event_actor = yml["production"]["assets"]["animations"][event_anim]["actor"]
                              if allowed_start[event_actor] >= 0 and event_pos > allowed_start[event_actor]:
                                  allowed_intervals[event_actor].append([allowed_start[event_actor], event_pos, actor_poses[event_actor]])
                              allowed_start[event_actor] = -1
                              blocked_actors.add(event_actor)

                    if speaker:
                      if speaker in allowed_actors and speaker not in blocked_actors and allowed_start[speaker] < 0.999:
                          allowed_intervals[speaker].append([allowed_start[speaker], 0.999, actor_poses[speaker]])
                      yml["storyboard"][section_name][shot_name] = events

                if speaker and allowed_intervals[speaker]:
                    for interval in allowed_intervals[speaker]:
                        prev_I = -1
                        while True:
                            # print(f"[+] Allowed interval [{speaker}]: {interval}")
                            interval_frames = int((interval[1] - interval[0]) * shot_duration * 30)
                            matching_anims = gesture_data[actors_genders[speaker]].get(interval[2], {}).get(shot_emotion, [])
                            # print(f"{actors_genders[speaker]}, {interval[2]}, {shot_emotion}, {matching_anims[0][0] if matching_anims else -1} ?<= {interval_frames}")
                            if not matching_anims or matching_anims[0][0] > interval_frames:
                                break

                            L = 0
                            R = len(matching_anims) - 1
                            while R - L > 0:
                                M = (L + R + 1) // 2
                                if matching_anims[M][0] > interval_frames:
                                    R = M - 1
                                else:
                                    L = M
                            # print(f"!!! {interval_frames}, 0 ({matching_anims[0][0]}) R {R} ({matching_anims[R][0]}), ma: {matching_anims}")
                            I = random.randint(0, R)
                            if I == prev_I:
                                tries = 10
                                while tries > 0 and I == prev_I:
                                    I = random.randint(0, R)
                                    tries -= 1
                                if I == prev_I:
                                    break
                            prev_I = I

                            print(f"[+] Add: [{shot_name}][{interval[0]}] = {matching_anims[I][1]}")

                            yml["storyboard"][section_name][shot_name].append({
                                "actor.anim.additive": CommentedMap({
                                    "actor": speaker,
                                    ".@pos": flowed([interval[0], matching_anims[I][1]]),
                                    "blendin": 0.4,
                                    "blendout": 0.4
                                })
                            })
                            added_gestures += 1
                            anim_duration = (matching_anims[I][0] / 30)
                            yml["storyboard"][section_name][shot_name][-1]["actor.anim.additive"].yaml_set_comment_before_after_key(".@pos", before=f"duration: {anim_duration:.3f}", indent=10)
                            interval[0] += ((anim_duration + 1.0) / shot_duration)

                shot_name = str()
                shot_duration = -1
                speaker = str()
                        

    print(f"Added gestures to scene: {added_gestures}")
    write_yml_nicely(output_path, yml)

def main():
    global gesture_data
    cwd_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(cwd_dir)

    with open("gesture_data.txt", mode="r", encoding="utf-8") as f_gestures:
        for line in f_gestures.readlines():
            parts = line[:-1].split("|")
            if len(parts) < 5:
                continue
            # gender, pose, type, anim, frames
            if parts[1] not in gesture_data[ parts[0] ]:
                gesture_data[ parts[0] ][ parts[1] ] = dict()
            
            if parts[2] not in gesture_data[ parts[0] ][ parts[1] ]:
                gesture_data[ parts[0] ][ parts[1] ][ parts[2] ]= list()
            if [int(parts[4]), parts[3]] not in gesture_data[ parts[0] ][ parts[1] ][ parts[2] ]:
                gesture_data[ parts[0] ][ parts[1] ][ parts[2] ].append( [int(parts[4]), parts[3]] )
        
        for a in gesture_data:
            for b in gesture_data[a]:
                for c in gesture_data[a][b]:
                    gesture_data[a][b][c].sort()
        print(gesture_data)
        
    yml_paths = Path(".").rglob("scene.*.yml")
    for yml_path in yml_paths:
        process_yml(str(yml_path), project_dir + "/definition.scenes/" + yml_path.name)


main()