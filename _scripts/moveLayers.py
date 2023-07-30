from tkinter.filedialog import askopenfilename, askdirectory
import ruamel.yaml.scalarstring
from ruamel import yaml
from ruamel.yaml import comments
import numpy
import collections


def quoted(text: str):
    return yaml.scalarstring.DoubleQuotedScalarString(text)

def flowed(seq: list):
    ret = comments.CommentedSeq(seq)
    ret.fa.set_flow_style()
    return ret
    
def get_entity_pos(node):
    if 'transform' in node:
        node = node['transform']
        
    if 'pos' in node:
        return numpy.array(node['pos'][:3], dtype=float)
    else:
        print(f"ERROR: pos not found in node: {node}")
        
def set_entity_pos(node, pos):
    if 'transform' in node:
        node = node['transform']
        
    if 'pos' in node:
        node['pos'][:3] = flowed(pos)
    else:
        print(f"ERROR: pos not found in node: {node}")

def do():
    print(f"[*] Select input file with layer(s).")
    input_f = askopenfilename()
    print(f"[*] Select reference file with ONE layer and ONE static entity in it.")
    ref_f = askopenfilename()
    print(f"[*] Select output directory to save re-positioned layers.")
    output_f = "def.layers_moved.yml"
    output_dir = askdirectory()

    with open(input_f, mode="r", encoding="utf-8") as f:
        data = yaml.load(f, Loader=yaml.RoundTripLoader, preserve_quotes=True)

    with open(ref_f, mode="r", encoding="utf-8") as f:
        data_ref = yaml.load(f, Loader=yaml.RoundTripLoader, preserve_quotes=True)
    
    try:
        layer_name_ref = list( data_ref['layers'].keys() )[0]
        entity_name_ref = list( data_ref['layers'][layer_name_ref]['statics'].keys() )[0]
        print(f"[+] Set ref entity: {layer_name_ref}::{entity_name_ref}")
        ref_pos = get_entity_pos(data_ref['layers'][layer_name_ref]['statics'][entity_name_ref])
    except:
        print(f"ERROR! Something went wrong (extracting reference position)!")
        return
    
    try:
        if not data['layers'][layer_name_ref]['statics'][entity_name_ref]:
            print(f"ERROR! Can't find ref entity in input file: {layer_name_ref}::{entity_name_ref}")
            return
        
        entity_pos = get_entity_pos(data['layers'][layer_name_ref]['statics'][entity_name_ref])
        shift_vec = ref_pos - entity_pos
        print(f"[+] Shift vec: {shift_vec}")
    except:
        print(f"ERROR! Something went wrong (extracting original entity position)!")
        return
        
    print(f"[*] Layers to move: {data['layers'].keys()}")
    for layer_name in list( data['layers'].keys() ):
        layer = data['layers'][layer_name]
        if not isinstance(layer, collections.abc.Mapping):
            print(f"[*] Skipping non-dict layer {layer_name}")
        else:
            cnt = 0
            print(f"[*] Processing layer: {layer_name}")
            
            if 'areas' in layer:
                for name in layer['areas']:
                    print(f"\t[*] Processing area: {name}")
                    area = layer['areas'][name]
                    for i, point in enumerate(area['borderpoints']):
                        pos = numpy.array(area['borderpoints'][i][:3], dtype=float)
                        pos += shift_vec
                        area['borderpoints'][i][:3] = flowed( pos.tolist() )
                        cnt += 1
                        
            if 'wanderpoints' in layer:
                for name in layer['wanderpoints']:
                    print(f"\t[*] Processing wanderpoints: {name}")
                    points = layer['wanderpoints'][name]
                    for i, point in enumerate(points):
                        pos = numpy.array(points[i][:3], dtype=float)
                        pos += shift_vec
                        points[i][:3] = flowed( pos.tolist() )
                        cnt += 1
                        
            for type in ['mappins', 'waypoints', 'actionpoints', 'scenepoints', 'statics', 'interactiveentities']:
                if type in layer:
                    for name in layer[type]:
                        print(f"\t[*] Processing {type}: {name}")
                        if isinstance(layer[type][name], collections.abc.Mapping):
                            pos = get_entity_pos(layer[type][name])
                            pos += shift_vec
                            set_entity_pos(layer[type][name], flowed( pos.tolist() ))
                        else:
                            pos = numpy.array(layer[type][name][:3], dtype=float)
                            pos += shift_vec
                            layer[type][name][:3] = flowed( pos.tolist() )
                        cnt += 1
                
            print(f"[*] Moved layer: {layer_name} ({cnt} nodes)")
    
    with open(f"{output_dir}/{output_f}", mode="w", encoding="utf-8") as of:
        yaml_dumper = ruamel.yaml.YAML()
        yaml_dumper.indent(mapping=2, sequence=4, offset=2)
        yaml_dumper.width = 4096
        yaml_dumper.dump(data, of)

    print(f"SUCCESS!")

if __name__ == '__main__':
    do()
    input("DONE!")