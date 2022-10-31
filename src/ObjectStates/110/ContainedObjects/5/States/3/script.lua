function onload(saved_data)
    cardsInBag = {}
    memoizedCards = {}
    searchUrl="https://arkhamdb.com/find?q="
end

function onObjectEnterContainer(container, object)
    if container == self then
        --use previously-found cards to prevent redundant ArkhamDB requests
        if memoizedCards[object.getName()] then
            table.insert(cardsInBag, {name = object.getName() .. memoizedCards[object.getName()], id = object.getGUID()})
            recreateButtons()
        else
            local formatCardName = string.gsub(string.lower(object.getName()), ' ', '+')

            WebRequest.get(searchUrl .. formatCardName, function(req)
                searchCallback(req, object)
            end)
        end
    end
end

function onObjectLeaveContainer(container, object)
    if container == self then
        removeCardByGUID(cardsInBag, object.getGUID())
        recreateButtons()
    end
end

function searchCallback(req, object)
    local traits = ''

    local traitsHtml = string.match(req.text, '<p class="card%-traits">[^%<]*')
    if traitsHtml != nil then
        traits = '\n' .. string.sub(traitsHtml, 24)
    end

    --memoize result
    memoizedCards[object.getName()] = traits

    table.insert(cardsInBag, {name = object.getName() .. traits, id = object.getGUID()})
    recreateButtons()
end

function recreateButtons()
    self.clearButtons()
    verticalPosition = 1.5

    for _, card in ipairs(cardsInBag) do
        if _G['removeCard' .. card.id] == nil then
            _G['removeCard' .. card.id] = function()
                removeCard(card.id)
            end
        end

        self.createButton({
            label = card.name,
            click_function = "removeCard" .. card.id,
            function_owner = self,
            position = {0,0,verticalPosition},
            height = 225,
            width = 1200,
            font_size = 75,
            color = {1,1,1},
            font_color = {0,0,0}
        })

        verticalPosition = verticalPosition - 0.5
    end

    countLabel = #cardsInBag == 0 and '' or #cardsInBag

    self.createButton({
        label = countLabel,
        click_function = 'nothing',
        function_owner = self,
        position = {0,0,-1.25},
        width = 0,
        height = 0,
        font_size = 225,
        font_color = {1,1,1}
    })
end

function nothing()
end

function removeCard(cardGUID)
    self.takeObject({
        guid = cardGUID,
        rotation = self.getRotation(),
        position = self.getPosition() + Vector(0,0.5,0),
        callback_function = function(obj)
            obj.resting = true
        end
    })
end

function removeCardByGUID(bag, guid)
    local idx = nil

    for i, v in ipairs (bag) do
        if (v.id == guid) then
          idx = i
        end
    end

    if idx ~= nil then
        table.remove(cardsInBag, idx)
    end
end