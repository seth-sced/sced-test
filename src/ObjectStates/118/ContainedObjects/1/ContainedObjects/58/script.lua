name = 'Meowlathotep'

function onLoad()
    Global.call('createSetupButtons', {object=self, key=name})
end

function easyClick()
    Global.call('fillContainer', {object=self, key=name, mode='easy'})
end

function normalClick()
    Global.call('fillContainer', {object=self, key=name, mode='normal'})
end

function hardClick()
    Global.call('fillContainer', {object=self, key=name, mode='hard'})
end

function expertClick()
    Global.call('fillContainer', {object=self, key=name, mode='expert'})
end
