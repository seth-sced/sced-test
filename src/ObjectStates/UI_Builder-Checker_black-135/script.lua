---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Whimsical.
--- DateTime: 2021-08-24 9:55 a.m.
---

-- Please call this first. It makes things so much easier.
---@param target TTSObject
---@param callback_name string
---@return number
local function make_decktype_checkbox(target, callback_name)
    -- Create Private/Published checkbox
    target:createButton {
        click_function = callback_name,
        function_owner = target,
        position = Vector(-0.33, 0.1, -0.255),
        width = 2100,
        height = 500,
        tooltip = "Click to toggle Private/Published deck ID",
        label = "Private",
        font_size = 350,
        scale = Vector(0.1, 0.1, 0.1),
        color = Color(0.9, 0.7, 0.5),
        hover_color = Color(0.4, 0.6, 0.8)
    }
    return target:getButtons()[1].index -- If we do this first, we know that our index is our new button
end

function noop() end

---@param target TTSObject
---@param debug_deck_id string|nil
local function make_text(target, debug_deck_id)
    -- Create textbox
    target:createInput {
        function_owner = self,
        position = Vector(0.33, 0.1, -0.255),
        width = 2200,
        height = 500,
        scale = Vector(0.1, 0.1, 0.1),
        font_size = 450,
        tooltip = "*****PLEASE USE AN UNPUBLISHED DECK IF JUST FOR TTS TO AVOID FLOODING ARKHAMDB PUBLISHED DECK LISTS!*****\nInput deck ID from ArkhamDB URL of the deck\nExample: For the URL 'https://arkhamdb.com/decklist/view/101/knowledge-overwhelming-solo-deck-1.0', you should input '101'",
        alignment = 3,
        value = debug_deck_id or "",
        color = Color(0.9, 0.7, 0.5),
        validation = 2,
        input_function = "noop"
    }
end

---@param target TTSObject
---@param callback_name string
local function make_button(target, callback_name)
    -- Create Button
    target:createButton {
        click_function = callback_name,
        function_owner = target,
        position = Vector(0.0, 0.05, -0.1),
        width = 300,
        height = 100,
        tooltip = "Click to build your deck!",
        scale = Vector(1, 1, 0.6),
        color = Color.Black
    }
end

---@param parameters ArkhamImportUIParameters
---@return number
function create_ui(parameters)
    local target = getObjectFromGUID(parameters.target_guid)

    local index = make_decktype_checkbox(target, parameters.checkbox_toggle_callback_name)
    make_text(target, parameters.debug_deck_id)
    make_button(target, parameters.build_deck_callback_name)

    return index
end