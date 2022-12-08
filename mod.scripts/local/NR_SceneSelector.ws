struct NR_ScenePreviewData {
	editable var m_slots 	: array<int>;
	editable var m_paths 	: array<String>;
	editable var m_nameIDs	: array<int>;
	editable var m_appNames	: array<String>;
	editable var m_headName	: name;
	editable var m_coloringIndexes	: array<int>;
	editable var m_saveOnAccept		: bool;
}

struct NR_SceneNode {
	editable var m_onPreviewChoice : array<NR_ScenePreviewData>;
}

class NR_SceneSelector extends CEntity {
	editable var 	m_nodesMale		: array<NR_SceneNode>;
	editable var 	m_nodesFemale	: array<NR_SceneNode>;
	protected var 	m_dataIndex	: int;
	default 		m_dataIndex	= -1;

	public function GetTemplatesToUpdate(choiceIndex : int, isFemale : bool, out paths : array<String>, out itemList : array<String>, out headName : name) {
		var i : int;	
		var slot : ENR_AppearanceSlots;
		var dbg  : String;
		NRD("NR_SceneSelector::GetTemplatesToUpdate [m_dataIndex = " + m_dataIndex + ", choiceIndex = " + choiceIndex + ", isFemale = " + isFemale + "]");


		itemList.Clear();
		if (m_dataIndex < 0 || choiceIndex < 0)
			return;

		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return;

			for (i = 0; i < m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots.Size(); i += 1) {
				slot = m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots[i];
				//dbg += "Add[" + i + "] slot = " + slot + ", path = " + m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_paths[i] + "<br>"; 
				
				if (slot == ENR_RSlotMisc || FactsQuerySum("nr_scene_stacking_as_items") > 0)
					itemList.PushBack(m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_paths[i]);
				else
					paths[slot] = m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_paths[i];
			}
			headName = m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_headName;
			//NR_Notify(dbg);
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return;

			for (i = 0; i < m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots.Size(); i += 1) {
				slot = m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_slots[i];
				if (slot == ENR_RSlotMisc || FactsQuerySum("nr_scene_stacking_as_items") > 0)
					itemList.PushBack(m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_paths[i]);
				else
					paths[slot] = m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_paths[i];
			}
			headName = m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_headName;
        }
    }

    public function SaveOnAccept(choiceIndex : int, isFemale : bool) : bool {
		if (m_dataIndex < 0 || choiceIndex < 0)
			return false;
		if (isFemale) {
			if (m_dataIndex >= m_nodesFemale.Size() || choiceIndex >= m_nodesFemale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return m_nodesFemale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_saveOnAccept;
        } else {
        	if (m_dataIndex >= m_nodesMale.Size() || choiceIndex >= m_nodesMale[m_dataIndex].m_onPreviewChoice.Size())
				return false;

			return m_nodesMale[m_dataIndex].m_onPreviewChoice[choiceIndex].m_saveOnAccept;
        }
	}

    public function GetHeadNameToUpdate(choiceIndex : int, isFemale : bool) : name {
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
    }
    public function GetPreviewDataIndex() : int {
    	return m_dataIndex;
    }
    public function ResetPreviewDataIndex() {
    	NRD("NR_SceneSelector::ResetPreviewDataIndex()");
    	m_dataIndex = -1;
    }
    public function SetPreviewDataIndex(newIndex : int) {
    	NRD("NR_SceneSelector::SetPreviewDataIndex()");
    	m_dataIndex = newIndex;
    }
}