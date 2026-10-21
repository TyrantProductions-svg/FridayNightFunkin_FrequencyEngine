package funkin.play.character;

import flixel.FlxG;
import funkin.Conductor;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.play.notes.NoteDirection;
import funkin.play.character.MultiSparrowCharacter;
import funkin.modding.events.ScriptEvent;
import funkin.modding.events.ScriptEvent.UpdateScriptEvent;

/**
 * Scripted character for Oscillation with multi-phase form transitions.
 *
 * Phase 1 (Normal): Bars 1-42
 * Phase 2 (Locked In): Bars 43-74
 * Phase 3 (Transformation): Bars 75-77 (rapid flicker between Locked In and Gone Nuts)
 * Phase 4 (Gone Nuts): Bar 78+ (1.8x scale)
 */
@:nullSafety
class OscillationCharacter extends MultiSparrowCharacter
{
  // Phase transition bars
  static inline var LOCKED_IN_START_BAR:Int = 43;
  static inline var TRANSFORMATION_START_BAR:Int = 75;
  static inline var GONE_NUTS_START_BAR:Int = 78;

  // Scale multiplier for Gone Nuts form
  static inline var GONE_NUTS_SCALE:Float = 1.8;

  // Current active form
  var currentForm:OscillationForm = Normal;

  // Flicker state for transformation phase
  var flickerToggle:Bool = false;
  var flickerFrameCounter:Int = 0;

  // Base scale (stored to prevent compounding)
  var baseScaleX:Float = 1.0;
  var baseScaleY:Float = 1.0;
  var scaleInitialized:Bool = false;

  override function onCreate(event:ScriptEvent):Void
  {
    super.onCreate(event);

    // Store base scale
    baseScaleX = this.scale.x;
    baseScaleY = this.scale.y;
    scaleInitialized = true;

    // Set as opponent character
    this.characterType = DAD;
  }

  override function onUpdate(event:UpdateScriptEvent):Void
  {
    super.onUpdate(event);

    if (Conductor.instance == null) return;

    final currentBar:Int = Conductor.instance.currentMeasure + 1; // 1-indexed measure

    // Determine current form based on bar
    var newForm:OscillationForm = getFormForBar(currentBar);

    // Handle transformation flicker (every 2 frames)
    if (currentBar >= TRANSFORMATION_START_BAR && currentBar < GONE_NUTS_START_BAR)
    {
      flickerFrameCounter++;
      if (flickerFrameCounter >= 2)
      {
        flickerFrameCounter = 0;
        flickerToggle = !flickerToggle;
        newForm = flickerToggle ? GoneNuts : LockedIn;

        // Re-trigger idle animation for the new form
        if (!isSinging())
        {
          dance(true);
        }
      }
    }

    // Apply scale change if form changed
    if (newForm != currentForm)
    {
      currentForm = newForm;
      applyScaleForForm();
    }
  }

  override public function playSingAnimation(dir:NoteDirection, miss:Bool = false, ?suffix:String = ''):Void
  {
    final currentBar:Int = (Conductor.instance != null) ? Conductor.instance.currentMeasure + 1 : 0;
    var form:OscillationForm = getFormForBar(currentBar);

    // During transformation, use flicker toggle
    if (currentBar >= TRANSFORMATION_START_BAR && currentBar < GONE_NUTS_START_BAR)
    {
      form = flickerToggle ? GoneNuts : LockedIn;
    }

    currentForm = form;

    // Build animation name based on form
    var animName:String = switch (form)
    {
      case Normal:
        'sing${dir.nameUpper}${miss ? 'miss' : ''}${suffix != '' ? '-${suffix}' : ''}';
      case LockedIn:
        'sing${dir.nameUpper}LockIn${miss ? 'miss' : ''}${suffix != '' ? '-${suffix}' : ''}';
      case GoneNuts:
        'sing${dir.nameUpper}GoneNuts${miss ? 'miss' : ''}${suffix != '' ? '-${suffix}' : ''}';
    }

    playAnimation(animName, true);

    applyScaleForForm();
  }

  override function dance(force:Bool = false):Void
  {
    if (!force)
    {
      if (isSinging()) return;
    }

    final currentBar:Int = (Conductor.instance != null) ? Conductor.instance.currentMeasure + 1 : 0;
    var form:OscillationForm = getFormForBar(currentBar);

    // During transformation, use flicker toggle
    if (currentBar >= TRANSFORMATION_START_BAR && currentBar < GONE_NUTS_START_BAR)
    {
      form = flickerToggle ? GoneNuts : LockedIn;
    }

    currentForm = form;

    // Build idle animation name based on form
    var idleName:String = switch (form)
    {
      case Normal: 'idle';
      case LockedIn: 'idle'; // Locked In uses the same idle animation
      case GoneNuts: 'idleGoneNuts';
    }

    if (hasAnimation(idleName))
    {
      playAnimation(idleName, force);
    }
    else
    {
      super.dance(force);
    }

    applyScaleForForm();
  }

  function getFormForBar(bar:Int):OscillationForm
  {
    if (bar >= GONE_NUTS_START_BAR) return GoneNuts;
    if (bar >= TRANSFORMATION_START_BAR) return LockedIn; // Flicker handled in onUpdate
    if (bar >= LOCKED_IN_START_BAR) return LockedIn;
    return Normal;
  }

  function applyScaleForForm():Void
  {
    if (!scaleInitialized) return;

    if (currentForm == GoneNuts)
    {
      this.scale.set(baseScaleX * GONE_NUTS_SCALE, baseScaleY * GONE_NUTS_SCALE);
    }
    else
    {
      this.scale.set(baseScaleX, baseScaleY);
    }
    this.updateHitbox();
  }
}

enum OscillationForm
{
  Normal;
  LockedIn;
  GoneNuts;
}
