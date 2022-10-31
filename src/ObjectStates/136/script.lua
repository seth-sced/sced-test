---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Whimsical.
--- DateTime: 2021-08-22 6:36 a.m.
---

---@class CommandTableEntry
---@field public object TTSObject
---@field public runOn ArkhamImport_Command_RunDirectives
local CommandTableEntry = {}

---@type table<string, CommandTableEntry>
local commands = {}

---@type table<string, boolean>
local found_commands = {}

---@type table<string, any>
local command_state

local function load_commands()
    local command_objects = getObjectsWithTag("import_command")

    for _, object in ipairs(command_objects) do
        commands[object:getVar("command_name")] = {
            object = object,
            runOn = object:getTable("runOn")
        }
    end
end

---@param configuration ArkhamImportConfiguration
---@param message string
---@return ArkhamImport_CommandManager_InitializationResults
local function build_error(configuration, message)
    return {
        configuration = configuration,
        is_successful = false,
        error_message = message
    }
end

---@param source table<any, any>
---@param updates table<any, any>
local function merge_tables(source, updates)
    for key, _ in pairs(source) do
        local update = updates[key]
        if update~=nil then
            source[key] = update
        end
    end
end

---@param instruction TTSObject
---@param initialization_state any
---@param arguments string[]
---@return ArkhamImport_CommandManager_InitializationResults|nil
local function run_instruction(instruction, initialization_state, arguments)
    ---@type ArkhamImport_Command_DescriptionInstructionResults
    local result = instruction:call("do_instruction", {
        configuration = initialization_state.configuration,
        command_state = initialization_state.command_state,
        arguments = arguments
    })

    if (not result) or type(result)~="table" then
        return build_error(initialization_state.configuration, table.concat({"Command \"", instruction:getName(), "\" did not return a table from do_instruction call. Type \"", type(result), "\" was returned."}))
    end

    if not result.is_successful then
        return build_error(result.configuration, result.error_message)
    end

    merge_tables(initialization_state, result)
end

---@param description string
---@param initialization_state table<string, any>
---@return ArkhamImport_CommandManager_InitializationResults|nil
local function initialize_instructions(description, initialization_state)
    for _, instruction in ipairs(parse(description)) do
        local command = commands[instruction.command]

        if command==nil then
            return build_error(initialization_state.configuration, table.concat({ "Could not find command \"", command, "\"."}))
        end

        found_commands[instruction.command] = true

        if command.runOn.instructions then
            local error = run_instruction(command.object, initialization_state, instruction.arguments)
            if error then return error end
        end
    end
end

---@param parameters ArkhamImport_CommandManager_InitializationArguments
---@return table<string, any>
local function create_initialize_state(parameters)
    return {
        configuration = parameters.configuration,
        command_state = {}
    }
end

---@param parameters ArkhamImport_CommandManager_InitializationArguments
---@return ArkhamImport_CommandManager_InitializationResults
function initialize(parameters)
    found_commands = {}
    load_commands()

    local initialization_state = create_initialize_state(parameters)

    local error = initialize_instructions(parameters.description, initialization_state)
    if error then return error end

    command_state = initialization_state.command_state

    return {
        configuration = initialization_state.configuration,
        is_successful = true
    }
end

---@param parameters ArkhamImport_CommandManager_HandlerArguments
---@return table<string, any>
local function create_handler_state(parameters)
    return {
        card = parameters.card,
        handled = false,
        zone = parameters.zone,
        command_state = command_state
    },
    {
        configuration = parameters.configuration,
        source_guid = parameters.source_guid
    }
end

---@param card ArkhamImportCard
---@param zone = string[]
---@param handled boolean
---@param error_message string
---@return ArkhamImport_CommandManager_HandlerResults
local function create_handler_error(card, zone, handled, error_message)
    return {
        handled = handled,
        card = card,
        zone = zone,
        is_successful = false,
        error_message = error_message
    }
end

---@param handler TTSObject
---@param handler_state table<string, any>
---@param handler_constants table<string, any>
---@return ArkhamImport_CommandManager_HandlerResults|nil
local function call_handler(handler, handler_state, handler_constants)
    ---@type ArkhamImport_CommandManager_HandlerResults
    local results = handler:call("handle_card", {
        configuration = handler_constants.configuration,
        source_guid = handler_constants.source_guid,
        card = handler_state.card,
        zone = handler_state.zone,
        command_state = handler_state.command_state,
    })

    if not results.is_successful then return create_handler_error(results.card, results.zone, results.handled, results.error_message) end

    merge_tables(handler_state, results)
    command_state = handler_state.command_state
end

---@param handler_state table<string, any>
---@param handler_constants table<string, any>
---@return ArkhamImport_CommandManager_HandlerResults|nil
local function run_handlers(handler_state, handler_constants)
    for command_name, _ in pairs(found_commands) do
        local command = commands[command_name]
        if command.runOn.handlers then
            local error = call_handler(command.object, handler_state, handler_constants)
            if error then return error end

            if (handler_state.handled) then return end
        end
    end
end

---@param parameters ArkhamImport_CommandManager_HandlerArguments
---@return ArkhamImport_CommandManager_HandlerResults
function handle(parameters)
    local handler_state, handler_constants = create_handler_state(parameters)

    local error = run_handlers(handler_state, handler_constants)
    if error then return error end

    return {
        handled = handler_state.handled,
        card = handler_state.card,
        zone = handler_state.zone,
        is_successful = true
    }
end

---@param description string
---@return ArkhamImportCommandParserResult[]
function parse(description)
    local input = description

    if #input<=4 then return {} end

    ---@type string
    local current, l1, l2, l3 = "", "", "", ""

    local concat = table.concat

    local function advance()
        current, l1, l2, l3 = l1, l2, l3, input:sub(1,1)
        input = input:sub(2)
    end

    local function advance_all()
        current, l1, l2, l3 = input:sub(1,1), input:sub(2,2), input:sub(3,3), input:sub(4,4)
        input = input:sub(5)
    end

    advance_all()

    ---@type ArkhamImportCommandParserResult[]
    local results = {}

    ---@type string
    local command

    ---@type string[]
    local arguments = {}

    ---@type string
    local separator

    ---@type string[]
    local result = {}

    while #current>0 do
        if current=="<" and l1=="?" and l2 == "?" then
            command = nil
            arguments = {}
            separator = l3
            result = {}

            advance_all()
        elseif current == "?" and l1 == "?" and l2 == ">" then
            if not command then
                table.insert(results, {
                    command = concat(result),
                    arguments = {}
                })
            else
                table.insert(arguments, concat(result))
                table.insert(results, {
                    command = command,
                    arguments = arguments
                })
            end

            separator = nil
            current, l1, l2, l3 = l3, input:sub(1,1), input:sub(2,2), input:sub(3,3)
            input = input:sub(4)
        elseif current == separator then
            if not command then
                command = concat(result)
            else
                table.insert(arguments, concat(result))
            end
            result = {}
            advance()
        else
            if separator~=nil then
                table.insert(result, current)
            end
            advance()
        end
    end

    return results
end