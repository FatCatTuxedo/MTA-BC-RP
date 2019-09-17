function removeWeaponOnSwitch(prevSlot, newSlot)
    if (getElementData(localPlayer, "account:id") == 1 or getElementData(localPlayer, "faction") == 1 or getElementData(localPlayer, "faction") == 59 or getElementData(localPlayer, "faction") == 50 or getElementData(localPlayer, "faction") == 3)  and getElementData(localPlayer, "enableGunAttach") then
        triggerServerEvent("createWepObject", localPlayer, localPlayer, getPedWeapon(localPlayer, newSlot), 0, getSlotFromWeapon(getPedWeapon(localPlayer, newSlot)))
        triggerServerEvent("createWepObject", localPlayer, localPlayer, getPedWeapon(localPlayer, prevSlot), 1, getSlotFromWeapon(getPedWeapon(localPlayer, prevSlot)))
    end
end
addEventHandler("onClientPlayerWeaponSwitch", getRootElement(), removeWeaponOnSwitch)