enum ENR_ScenePreviewFlags {
	ENR_SPDontSaveOnAccept = 1,
	ENR_SPForceUnloadSlotTemplates = 2
}

struct NR_ScenePreviewData {
	editable var m_slots 	: array<int>;
	editable var m_pathIDs 	: array<int>;
	editable var m_nameIDs	: array<int>;
	editable var m_appNames	: array<name>;
	editable var m_headName	: name;
	editable var m_coloringIndexes	: array<int>;
	//editable var m_dontSaveOnAccept	: bool;
	editable var m_flags 	: int;
}

struct NR_SceneNode {
	editable var m_onPreviewChoice : array<NR_ScenePreviewData>;
}

class NR_SceneSelector extends CEntity {
	editable var 	m_nodesMale		: array<NR_SceneNode>;
	editable var 	m_nodesFemale	: array<NR_SceneNode>;
	editable var 	m_stringtable 	: array<String>;
	protected var 	m_dataIndex		: int;
	protected var 	m_choiceOffset	: int;
	default 		m_dataIndex		= -1;

	protected function StringByID(string_id : int) : String {
		if (string_id < 0 || string_id >= m_stringtable.Size())
			return "";
		return m_stringtable[string_id];
	}
	public function GetTemplatesToUpdate(choiceIndex : int, isFemale : bool, out paths : array<String>, out itemList : array<String>, out headName : name) {
		var i : int;	
		var slot : ENR_AppearanceSlots;
		var dbg  : String;
		NRD("NR_SceneSelector::GetTemplatesToUpdate [m_dataIndex = " + m_dataIndex + ", choiceIndex = " + choiceIndex + ", isFemale = " + isFemale + "]");


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
	public function ForceUnloadSlotTemplates(choiceIndex : int, isFemale : bool) : bool {
    	choiceIndex -= m_choiceOffset;
		if (m_dataIndex < 0 || choiceIndex < 0)
			return false;
		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return (m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & ENR_SPForceUnloadSlotTemplates);
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return (m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_flags & ENR_SPForceUnloadSlotTemplates);
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
    	NRD("NR_SceneSelector::ResetPreviewDataIndex()");
    	m_dataIndex = -1;
    }
    public function SetPreviewDataIndex(newIndex : int, newChoiceOffset : int) {
    	//NRD("NR_SceneSelector::SetPreviewDataIndex()");
    	m_dataIndex = newIndex;
    	m_choiceOffset = newChoiceOffset;
    }
}