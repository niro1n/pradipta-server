RegisterCommand('record', function()
    StartRecording(1)
    TriggerEvent('PradiptaCore:Notify', Lang:t('editor.started'), 'success')
end, false)

RegisterCommand('clip', function()
    StartRecording(0)
end, false)

RegisterCommand('saveclip', function()
    StopRecordingAndSaveClip()
    TriggerEvent('PradiptaCore:Notify', Lang:t('editor.save'), 'success')
end, false)

RegisterCommand('delclip', function()
    StopRecordingAndDiscardClip()
    TriggerEvent('PradiptaCore:Notify', Lang:t('editor.delete'), 'error')
end, false)

RegisterCommand('editor', function()
    NetworkSessionLeaveSinglePlayer()
    ActivateRockstarEditor()
    TriggerEvent('PradiptaCore:Notify', Lang:t('editor.editor'), 'error')
end, false)
