enum ENR_ScenePreviewFlags {
	ENR_SPDontSaveOnAccept = 1,        		// for submenu nodes
	ENR_SPForceUnloadAll = 2, 				// for NPC sets
	ENR_SPForceUnloadAllExceptHeadHair = 4, // for NPC Armor sets
	ENR_SPNPCSet = 8  						// marks real NPC sets
}

struct NR_ScenePreviewData {
	editable var m_slots 	: array<int>;
	editable var m_pathIDs 	: array<int>;
	// --- editable var m_nameIDs	: array<int>;
	// --- editable var m_appNames	: array<name>;
	editable var m_headName	: name;
	// --- editable var m_coloringIndexes	: array<int>;
	editable var m_flags 	: int;
}

struct NR_SceneNode {
	editable var m_onPreviewChoice : array<NR_ScenePreviewData>;
}

struct NR_SceneCustomDLCInfo {
	editable var m_dlcID : name;
	editable var m_dlcNameKey : String;
	editable var m_dlcNameStr : String;
	editable var m_dlcAuthor : String;
	editable var m_dlcLink : String;
	editable var m_dlcCheckTemplatePath : String;
}

class NR_SceneSelector extends CEntity {
	editable var 	m_nodesMale		: array<NR_SceneNode>;
	editable var 	m_nodesFemale	: array<NR_SceneNode>;
	editable var 	m_stringtable 	: array<String>;
	editable var 	m_customDLCInfo : array<NR_SceneCustomDLCInfo>;
	protected var 	m_dataIndex		: int;
	protected var 	m_choiceOffset	: int;
	default 		m_dataIndex		= -1;
	default 		m_choiceOffset	= 0;

	protected function StringByID(string_id : int) : String {
		if (string_id < 0 || string_id >= m_stringtable.Size())
			return "";
		return m_stringtable[string_id];
	}

	public function GetTemplatesToUpdate(choiceIndex : int, isFemale : bool, out paths : array<String>, out itemList : array<String>, out headName : name) {
		var i : int;	
		var slot : ENR_AppearanceSlots;
		var dbg  : String;
		NR_Debug("NR_SceneSelector::GetTemplatesToUpdate [m_dataIndex = " + m_dataIndex + ", choiceIndex = " + choiceIndex + ", isFemale = " + isFemale + "]");


		itemList.Clear();
		choiceIndex -= m_choiceOffset;
		if (m_dataIndex < 0 || choiceIndex < 0)
			return;

		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return;

			for (i = 0; i < m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots.Size(); i += 1) {
				slot = m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots[i];
				//dbg += "Add[" + i + "] slot = " + slot + ", path = " + m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_pathIDs[i] + "<br>"; 
				
				if (slot == ENR_RSlotMisc || FactsQuerySum("nr_scene_stacking_as_items") > 0)
					itemList.PushBack(StringByID(m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_pathIDs[i]));
				else
					paths[slot] = StringByID(m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_pathIDs[i]);
			}
			headName = m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_headName;
			//NR_Notify(dbg);
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return;

			for (i = 0; i < m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots.Size(); i += 1) {
				slot = m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots[i];
				if (slot == ENR_RSlotMisc || FactsQuerySum("nr_scene_stacking_as_items") > 0)
					itemList.PushBack(StringByID(m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_pathIDs[i]));
				else
					paths[slot] = StringByID(m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_pathIDs[i]);
			}
			headName = m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_headName;
        }
    }

    public function SaveOnAccept(choiceIndex : int, isFemale : bool) : bool {
    	choiceIndex -= m_choiceOffset;
		if (m_dataIndex < 0 || choiceIndex < 0)
			return false;
		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return !(m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & ENR_SPDontSaveOnAccept);
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return !(m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & ENR_SPDontSaveOnAccept);
        }
	}

	public function ShouldForceUnloadAllExceptHair(choiceIndex : int, isFemale : bool) : bool {
    	choiceIndex -= m_choiceOffset;
		if (m_dataIndex < 0 || choiceIndex < 0)
			return false;
		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return (m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & (ENR_SPForceUnloadAll | ENR_SPForceUnloadAllExceptHeadHair));
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return (m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & (ENR_SPForceUnloadAll | ENR_SPForceUnloadAllExceptHeadHair));
        }
	}

	public function ShouldForceUnloadAll(choiceIndex : int, isFemale : bool) : bool {
    	choiceIndex -= m_choiceOffset;
		if (m_dataIndex < 0 || choiceIndex < 0)
			return false;
		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return (m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & ENR_SPForceUnloadAll);
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return (m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & ENR_SPForceUnloadAll);
        }
	}

    /*public function GetHeadNameToUpdate(choiceIndex : int, isFemale : bool) : name {
    	if (m_dataIndex < 0 || choiceIndex < 0)
			return '';

		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return '';

	        return m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_headName;
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return '';

			return m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_headName;
        }
    }*/

    public function GetPreviewDataIndex() : int {
    	return m_dataIndex;
    }

    public function ResetPreviewDataIndex() {
    	NR_Debug("NR_SceneSelector::ResetPreviewDataIndex()");
    	m_dataIndex = -1;
    }

    public function SetPreviewDataIndex(newIndex : int, newChoiceOffset : int) {
    	//NR_Debug("NR_SceneSelector::SetPreviewDataIndex()");
    	m_dataIndex = newIndex;
    	m_choiceOffset = newChoiceOffset;
    }

    public function ShowCustomDLCInfo() {
    	
    }
}