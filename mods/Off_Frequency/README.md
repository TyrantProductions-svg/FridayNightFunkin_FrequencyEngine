# Off Frequency

An original Friday Night Funkin' mod in development.

## Structure

- `data/characters/` - character definition data.
- `data/levels/` - Story Mode week definitions.
- `data/songs/` - song chart and metadata files.
- `images/` - sprites, atlases, and other images.
- `music/` - music assets, if referenced by the game.
- `scripts/` - optional HScript mod scripts.
- `sounds/` - sound effects.
- `songs/` - song instrumental and vocal audio, organized by song ID.

## Credits

- Mark 101
- The team behind the Minecraft mod *The Broken Script*
- Borists — [Girlfriend With No Speakers (For Psych Engine)](https://gamebanana.com/mods/366075)
- TheTerribleDev — [Playable GF's parts](https://gamebanana.com/tools/11210)
- LoganMcOof — [UPDATED Girlfriend Soundfont 2024 With Atonals](https://gamebanana.com/tools/7343)

These credits are included at the project creator's request. Specific contributions
and individual team member names can be added as they are confirmed.

## Compatibility

This mod targets the Friday Night Funkin' 0.8.7 mod API.

## Custom title logo

The title logo atlas replaces `images/logoBumpin.png` and
`images/logoBumpin.xml`. Its position is configured in `_polymod_meta.json`
with the string metadata values `titleLogoX` and `titleLogoY`. These offsets
replace the engine's original base coordinates (`-150`, `-100`); if either
value is omitted, the engine's original title-logo coordinates are used.

## Custom title scene

To customize the title scene, add `data/title-screen.json`. Sprites are created
back-to-front: entries in `props`, then `people`, then `foregroundProps`, followed by
the original dancing GF when `defaultDancer` is `true`. Without this file, the engine
keeps the original title scene.

Each entry requires an `assetPath` (relative to `images/`, without the file extension)
and numeric `x`/`y` coordinates. Optional `right` and `bottom` values anchor the
sprite to those screen edges after scaling; `scale` defaults to `1`. Entries without
`animations` load a static PNG. Animated entries load a Sparrow PNG/XML atlas by
default; set `renderType` to `animateatlas` to load an Adobe Animate atlas, and set
`assetLibrary` when loading from a named library such as `shared`. Animation entries
use `name` and `prefix`, with optional `frameRate` (default `24`), `looped` (default
`false`), and `frameIndices`. `startingAnimation` is optional. `danceAnimations`
optionally names two declared animations that alternate on each beat.

```json
{
  "props": [
    {
      "assetPath": "off_frequency/title/dj_rig",
      "x": 180,
      "y": 360,
      "scale": 1,
      "animations": [
        { "name": "idle", "prefix": "Idle", "looped": true }
      ],
      "startingAnimation": "idle"
    }
  ],
  "people": [
    {
      "assetPath": "off_frequency/title/synthea",
      "x": 560,
      "y": 220,
      "animations": [
        { "name": "danceLeft", "prefix": "Dance Left" },
        { "name": "danceRight", "prefix": "Dance Right" }
      ],
      "startingAnimation": "danceLeft",
      "danceAnimations": ["danceLeft", "danceRight"]
    }
  ]
}
```

The engine only uses this configuration when a loaded mod actually supplies
`data/title-screen.json`; unrelated mods do not suppress the original GF.

## Characters

Synthea and Oscillation are defined in `data/characters/` and use the engine's
`multisparrow` renderer, the built-in FNF format for characters with separate
Sparrow atlas files per animation. Synthea's battle poses and DJ idle are under
`images/characters/synthea/`. Oscillation's battle poses and Ozzy animations are
under `images/characters/oscillation/`.

Each atlas must be a transparent PNG paired with a Sparrow v2 XML of the same
filename stem. XML uses the case-sensitive `<TextureAtlas>` and `<SubTexture>`
elements. Character JSON animation names are what songs/gameplay request; each
animation's `prefix` must match its atlas frame names exactly. Keep frame order
correct and PNG/XML capitalization consistent for cross-platform builds.

## Custom Girlfriend

`data/characters/gf.json` overrides the base-game Girlfriend with the speaker-free
Sparrow atlas at `images/characters/gf/GF_ass_sets.png`. The title screen uses the
same atlas for her dance, so gameplay and title visuals stay consistent.
