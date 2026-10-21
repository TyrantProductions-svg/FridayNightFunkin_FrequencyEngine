package funkin.play.character;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import funkin.Paths;
import funkin.data.character.CharacterData.CharacterDataParser;
import funkin.play.PlayState;
import funkin.play.stage.Stage;
import funkin.Conductor;
import funkin.play.character.OscillationCharacter.OscillationForm;

class OscillationCharacterManager
{
	public static var normalChar:BaseCharacter = null;
	public static var lockedInChar:BaseCharacter = null;
	public static var goneNutsChar:BaseCharacter = null;

	public static var currentForm:OscillationForm = Normal;
	public static var isActive:Bool = false;

	static var flickerFrameCounter:Int = 0;
	static var showGoneNuts:Bool = false;
	static var hasReachedGoneNutsPermanently:Bool = false;

	static var lastSwapSongPosition:Float = 0;
	static final SWAP_INTERVAL_MS:Float = 2.0 / 60.0 * 1000.0;

	// Transformation sequence state (bars 74–78)
	static var transformPhase:Int = 0; // 0=None, 1=WhiteNoisePre, 2=GoingNuts, 3=WhiteNoisePost, 4=Complete
	static var transformSprite:FlxSprite = null;
	static var goingNutsFinished:Bool = false;

	inline static var PHASE_NONE:Int = 0;
	inline static var PHASE_WHITE_NOISE_PRE:Int = 1;
	inline static var PHASE_GOING_NUTS:Int = 2;
	inline static var PHASE_WHITE_NOISE_POST:Int = 3;
	inline static var PHASE_COMPLETE:Int = 4;

	public static function preloadAll(stage:Stage):Void
	{
		var existingDad = stage.getDad();
		if (existingDad == null)
		{
			trace('[OscillationCharacterManager] Failed to preload: no existing dad character on stage.');
			return;
		}

		// The Stage's initial dad is the Locked In character for this song.
		lockedInChar = existingDad;

		if (normalChar == null)
		{
			normalChar = CharacterDataParser.fetchCharacter('oscillation');
			if (normalChar == null)
			{
				trace('[OscillationCharacterManager] Warning: failed to load Normal character (oscillation).');
			}
		}
		if (goneNutsChar == null)
		{
			goneNutsChar = CharacterDataParser.fetchCharacter('oscillation-gone-nuts');
			if (goneNutsChar == null)
			{
				trace('[OscillationCharacterManager] Warning: failed to load Gone Nuts character (oscillation-gone-nuts).');
			}
		}

		// Only activate if the two required characters for this song loaded successfully.
		if (lockedInChar == null || goneNutsChar == null)
		{
			trace('[OscillationCharacterManager] Failed to preload: required character(s) are missing. Manager will not activate.');
			return;
		}

		isActive = true;
		currentForm = LockedIn;
		hasReachedGoneNutsPermanently = false;
		flickerFrameCounter = 0;
		showGoneNuts = false;
	}

	public static function getActiveChar():BaseCharacter
	{
		return switch (currentForm)
		{
			case Normal: normalChar;
			case LockedIn: lockedInChar;
			case GoneNuts: goneNutsChar;
		}
	}

	public static function getCharForForm(form:OscillationForm):BaseCharacter
	{
		return switch (form)
		{
			case Normal: normalChar;
			case LockedIn: lockedInChar;
			case GoneNuts: goneNutsChar;
		}
	}

	public static function updateForm(currentBar:Int):Void
	{
		if (!isActive) return;

		var stage = PlayState.instance.currentStage;
		if (stage == null) return;

		var dad = stage.getDad();
		if (dad == null) return;

		if (hasReachedGoneNutsPermanently) return;

		// --- Transformation sequence (bars 74–78) ---

		if (currentBar == 74 && transformPhase == PHASE_NONE)
		{
			startWhiteNoise(stage);
			transformPhase = PHASE_WHITE_NOISE_PRE;
			return;
		}

		if (currentBar == 75 && transformPhase == PHASE_WHITE_NOISE_PRE)
		{
			startGoingNuts(stage);
			transformPhase = PHASE_GOING_NUTS;
			return;
		}

		if (currentBar == 77 && transformPhase == PHASE_GOING_NUTS)
		{
			resumeWhiteNoise(stage);
			transformPhase = PHASE_WHITE_NOISE_POST;
			return;
		}

		if (currentBar >= 78 && transformPhase == PHASE_WHITE_NOISE_POST)
		{
			cleanupTransformation(stage);
			transformPhase = PHASE_COMPLETE;
			// Fall through to the existing bar-78 swap below.
		}

		// --- Existing bar 78 transformation trigger ---

		if (currentBar >= 78)
		{
			if (currentForm != GoneNuts)
			{
				swapTo(GoneNuts, stage);
				hasReachedGoneNutsPermanently = true;
			}
			return;
		}

		// Bars 75–77: stay as Locked In (no flickering).

		// Bars 1–74: stay as Locked In (initial form for this song).
	}

	public static function swapTo(form:OscillationForm, stage:Stage):Void
	{
		var oldChar = getActiveChar();
		var newChar = getCharForForm(form);

		if (oldChar == null || newChar == null || oldChar == newChar)
		{
			currentForm = form;
			return;
		}

		var savedHoldTimer:Float = oldChar.holdTimer;
		var savedCameraFocusX:Float = oldChar.cameraFocusPoint.x;
		var savedCameraFocusY:Float = oldChar.cameraFocusPoint.y;

		stage.swapDadCharacter(newChar);

		var playState = PlayState.instance;
		if (playState != null)
		{
			playState.cameraFollowPoint.setPosition(newChar.cameraFocusPoint.x, newChar.cameraFocusPoint.y);
		}

		if (savedHoldTimer > 0)
		{
			var targetAnim = mapAnimationName(oldChar.getCurrentAnimation(), form);
			if (newChar.hasAnimation(targetAnim))
			{
				newChar.playAnimation(targetAnim, true);
				newChar.holdTimer = savedHoldTimer;
			}
		}
		else
		{
			var idleAnim = mapAnimationName('idle', form);
			if (newChar.hasAnimation(idleAnim))
			{
				newChar.playAnimation(idleAnim, true);
			}
		}

		currentForm = form;
	}

	static function mapAnimationName(oldAnim:String, targetForm:OscillationForm):String
	{
		if (oldAnim == '' || oldAnim == null) return 'idle';

		if (oldAnim.startsWith('singLEFT'))
		{
			return switch (targetForm)
			{
				case Normal: 'singLEFT';
				case LockedIn: 'singLEFT';
				case GoneNuts: 'singLEFT';
			}
		}
		if (oldAnim.startsWith('singDOWN'))
		{
			return switch (targetForm)
			{
				case Normal: 'singDOWN';
				case LockedIn: 'singDOWN';
				case GoneNuts: 'singDOWN';
			}
		}
		if (oldAnim.startsWith('singUP'))
		{
			return switch (targetForm)
			{
				case Normal: 'singUP';
				case LockedIn: 'singUP';
				case GoneNuts: 'singUP';
			}
		}
		if (oldAnim.startsWith('singRIGHT'))
		{
			return switch (targetForm)
			{
				case Normal: 'singRIGHT';
				case LockedIn: 'singRIGHT';
				case GoneNuts: 'singRIGHT';
			}
		}

		if (targetForm == GoneNuts && (oldAnim == 'idle' || oldAnim.startsWith('idle')))
		{
			return 'idleGoneNuts';
		}

		return 'idle';
	}

	static function startWhiteNoise(stage:Stage):Void
	{
		if (transformSprite != null)
		{
			stage.remove(transformSprite);
			transformSprite.destroy();
		}

		transformSprite = new FlxSprite();
		transformSprite.frames = Paths.getSparrowAtlas("whiteNoise");

		// Asset frames are 240×180. Scale to 2× to restore from 50% reduction: 480×360.
		// Then scale up further to cover the 1280×720 viewport.
		// 1280 / 480 ≈ 2.667 (width), 720 / 360 = 2.0 (height).
		// Use the larger ratio to ensure full coverage.
		transformSprite.animation.addByPrefix("whiteNoise", "whiteNoise", 24, true);
		transformSprite.animation.play("whiteNoise");

		// Apply 2× restoration scale first, then viewport coverage scale.
		// Combined: 2.0 × 2.667 = 5.333 on both axes (square scale to preserve aspect).
		var screenScale:Float = 5.333;
		transformSprite.scale.set(screenScale, screenScale);
		transformSprite.updateHitbox();

		// Center on screen after scaling.
		transformSprite.screenCenter();

		stage.add(transformSprite);
	}

	static function startGoingNuts(stage:Stage):Void
	{
		if (transformSprite != null)
		{
			stage.remove(transformSprite);
			transformSprite.destroy();
		}

		transformSprite = new FlxSprite();
		transformSprite.frames = Paths.getSparrowAtlas("characters/oscillation/battle/ozzyGoingNuts");

		// Asset frames are 256×144. Scale to 2× to restore from 50% reduction: 512×288.
		// 48 frames at ~14.5 FPS ≈ 3.31s to span bars 75–77.
		transformSprite.animation.addByPrefix("goingNuts", "ozzyGoingNuts", 14, false);
		transformSprite.animation.play("goingNuts");
		goingNutsFinished = false;

		// Apply 2× restoration scale.
		var restoreScale:Float = 2.0;
		transformSprite.scale.set(restoreScale, restoreScale);
		transformSprite.updateHitbox();

		// Center on the game window, independent of camera or character position.
		transformSprite.screenCenter();

		stage.add(transformSprite);
	}

	static function resumeWhiteNoise(stage:Stage):Void
	{
		startWhiteNoise(stage);
	}

	static function cleanupTransformation(stage:Stage):Void
	{
		if (transformSprite != null)
		{
			stage.remove(transformSprite);
			transformSprite.destroy();
			transformSprite = null;
		}
		goingNutsFinished = false;
	}

	public static function reset():Void
	{
		// Clean up any lingering transformation sprites.
		var stage = PlayState.instance?.currentStage;
		if (stage != null && transformSprite != null)
		{
			stage.remove(transformSprite);
			transformSprite.destroy();
		}
		transformSprite = null;
		transformPhase = PHASE_NONE;
		goingNutsFinished = false;

		normalChar = null;
		lockedInChar = null;
		goneNutsChar = null;
		currentForm = Normal;
		isActive = false;
		hasReachedGoneNutsPermanently = false;
		flickerFrameCounter = 0;
		showGoneNuts = false;
		lastSwapSongPosition = 0;
	}
}
