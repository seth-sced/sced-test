## Experiment in exploding a TTS Mod

Tools

### dumpmod: A tool to explode a TTS mod json file for source control

The entire mod json is expanded into a directory structure, with a directory for each object which contains a .json file describing that object, and lua script, lua state, xml ui files as appropriate. Objects that contain other objects, like bags or decks, have a ContainedObjects sub-directory with data for those objects. Objects that have multiple states have a States sub-directory with directories for each other state.

dumpmod handles 'luabundle' bundled modules such as are supported by vscode's tts extension.

dumpmod will not delete or replace an existing output directory.

Usage:

    lua dumpmod.lua <modfile.json> <output dir>

### buildmod: a tool to recombine a tts mod source hierarchy into a monolithic .json file for TTS

Usage:

    lua buildmod.lua <input dir> <root path for luabundle> <output.json>

### jankybundle: a janky implementation of luabundling in lua.

Not for direct use

### keyorder: provide reasonable stability of key ordering when dumping out json

Not for direct use

