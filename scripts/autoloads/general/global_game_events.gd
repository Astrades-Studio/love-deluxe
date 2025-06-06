extends Node

@warning_ignore_start("unused_signal")
#region Driving
signal destination_reached
signal fuel_depleted
#endregion

#region Game State
signal game_started
signal game_paused
signal game_resumed
signal game_over
# endregion

#region Run
signal score_changed(score: int)
signal cash_changed(cash: int)
signal bullet_changed(bullet: int)
# endregion


#region Narrative
#signal dialogues_requested(dialogue_blocks: Array[DialogueDisplayer.DialogueBlock])
#signal dialogue_display_started(dialogue: DialogueDisplayer.DialogueBlock)
#signal dialogue_display_finished(dialogue: DialogueDisplayer.DialogueBlock)
#signal dialogue_blocks_started_to_display(dialogue_blocks: Array[DialogueDisplayer.DialogueBlock])
#signal dialogue_blocks_finished_to_display()
#endregion
