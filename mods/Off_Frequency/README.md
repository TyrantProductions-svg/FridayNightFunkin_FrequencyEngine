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
- Chibisprinklez and RixFX — GF Reskin V3 (CC BY-NC-ND 4.0; the atlas and XML are
  redistributed unchanged for non-commercial use)

These credits are included at the project creator's request. Specific contributions
and individual team member names can be added as they are confirmed.

## Compatibility

This mod targets the Friday Night Funkin' 0.8.7 mod API.

## Story week scaffold

`data/levels/week-entity.json` defines the planned three-song story week in order:
`Dreaming`, `Oscillation`, and `Power Couple`. The engine already discovers
mod-provided level JSON files and lists visible levels in Story Mode, so no
separate week-registration code is needed.

The week is currently hidden because `Oscillation` and `Power Couple` do not
have song metadata, charts, or music yet, and
`images/storymenu/titles/week-entity.png` is not present. Keep `visible` set to
`false` until all three songs and the week card are ready. The opening and
between-song scenes, Oscillation's chart-timed forms, and section-based singer
changes for `Power Couple` still need to be implemented and tested separately.

## Dreaming demo song

`data/songs/dreaming/dreaming-metadata.json` registers Dreaming at 140 BPM with
the Cira Green Park stage, GF Sprinklez V2 as the player character, the
stock Boyfriend character in the stage's support-character slot, and Synthea as
the opponent. `data/songs/dreaming/dreaming-chart.json` is an empty Normal chart
scaffold intended to be filled in using the Chart Editor. The instrumental and
Synthea vocal are in `songs/dreaming/`, along with GF's
`Voices-gf-sprinklez-v2.ogg` player vocal track. Because GF is the intended
singer, the opponent vocal track is explicitly disabled. The chart still needs
to be authored, and the artist credit is unknown. The full Story Mode week
remains hidden until its other songs and week card are ready.

## Cira Green Park stage

`data/stages/cira-green-park.json` sets up the supplied Cira Green Park
background, the existing `voidRumble` DJ rig, and Oscillation's looping
`OzzySleepin` DJ animation. The DJ rig is currently scaled to 1.2035 (120.35%
of its original asset size). It uses camera zoom to frame a closer portion of the
background rather than resizing the background alone; the zoom affects all
stage elements. The background image is stored at `images/stages/cira-green-park.png`; song
metadata must set `playData.stage` to `cira-green-park` to use this stage.

To adjust gameplay locations, edit the stage's `characters` coordinates:
`bf` is the player-side character (Sprinklez GF for Dreaming), `dad` is the
opponent, and `gf` is the stage's support-character slot (Boyfriend for
Dreaming). The intended draw order is Synthea and playable GF (z-index 50),
support BF (40), DJ rig (30), sleeping Oscillation (20), then the background
(0). The `props` entries control the background, DJ rig, and Ozzy. Change their
`position`, `scale`, and `zIndex` values to move, resize, or layer them. The
Stage Editor can preview these placements. For Dreaming, the playable GF's
character-data scale is `0.56` and the player-side stage multiplier is `0.8375`,
for an effective scale of about 46.9% of atlas size. The support BF uses a
mod-specific character definition with the stock BF atlas and faces left; it
uses the regular idle pose, not a seated animation.

Animation definitions live in `data/characters/` and select animation names
and atlas frame prefixes. For example, Dreaming's sleeping DJ prop selects
`OzzySleepin` in the stage's `props` list; battle character poses are defined
in their character JSON files.

Dreaming's metadata sets `characters.player` to `gf-sprinklez-v2` and
`characters.girlfriend` to `bf-cira-park`. Sprinklez is playable; this
mod-specific support character reuses the stock BF atlas with a left-facing
orientation. The mod does not replace the base game's `bf` or `gf` character
definitions or assets. With Off Frequency disabled, its song/stage/character
overrides are not loaded and the base game continues using its original
characters.

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

`data/characters/gf-off-frequency.json` defines the speaker-free GF using the
Sparrow atlas at `images/characters/gf/GF_ass_sets.png`. The title screen uses
the same atlas for her dance, so gameplay and title visuals stay consistent.

`data/characters/gf-sprinklez-v2.json` defines the playable GF singer for the
Dreaming demo, using the unmodified `images/characters/gf/gf_sprinklezV2`
atlas and its singing, miss, dance, and death animations. Set the song's player
character to `gf-sprinklez-v2`. Dreaming currently uses stock Boyfriend in the
stage's support-character slot; the speaker-free GF character remains available
for the title screen or other stages. The credited reskin is licensed
CC BY-NC-ND 4.0, so this redistribution is non-commercial and the atlas/XML
must remain unmodified. The atlas is 8192x4096; test it on lower-spec graphics
hardware before promising support for older devices.
