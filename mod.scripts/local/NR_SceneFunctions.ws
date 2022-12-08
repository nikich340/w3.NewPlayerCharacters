storyscene function NR_SetPreviewDataIndex_S(player: CStoryScenePlayer, data_index : int) {
	NR_GetPlayerManager().SetPreviewDataIndex(data_index);
}

storyscene function NR_ClearAppearanceSlot_S(player: CStoryScenePlayer, slot_index : int) {
	NR_GetPlayerManager().ClearAppearanceSlot((ENR_AppearanceSlots)slot_index);
}

storyscene function NR_ClearItemSlot_S(player: CStoryScenePlayer, item_index : int) {
	NR_GetPlayerManager().ClearItemSlot(item_index);
}

storyscene function NR_ClearAllSlots_S(player: CStoryScenePlayer, item_index : int) {
	NR_GetPlayerManager().ResetAllAppearanceHeadHair();
}

storyscene function NR_SwitchIncludeAsItem_S(player: CStoryScenePlayer, slot_index : int) {
	if (FactsQuerySum("nr_scene_stacking_as_items") < 1) {
		FactsAdd("nr_scene_stacking_as_items", 1);
	} else {
		FactsSet("nr_scene_stacking_as_items", 0);
	}
}
