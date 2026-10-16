# Character definitions

Character JSON definitions go in this folder. `gf-off-frequency.json` defines the
mod's speaker-free GF using the Sparrow atlas at
`images/characters/gf/GF_ass_sets.png`. It has a unique character ID, so other
weeks continue using the base-game `gf`. Set a custom song's `girlfriend` character
field to `gf-off-frequency` to use this version. Keep its case-sensitive animation
prefixes aligned with the XML atlas.

`gf-sprinklez-v2.json` uses the playable GF atlas at
`images/characters/gf/gf_sprinklezV2.png` and its matching XML.

`bf-cira-park.json` reuses the engine's stock BF atlas for Dreaming's support
character, with a left-facing orientation. It does not override the base BF.

`synthea.json` and `oscillation.json` use the engine's `multisparrow` renderer,
which is the standard FNF character-data format for one Sparrow atlas per
animation. Their animation prefixes match their individual atlas XML files.
