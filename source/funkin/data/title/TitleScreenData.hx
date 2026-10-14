package funkin.data.title;

import funkin.data.animation.AnimationData;

typedef TitleScreenData =
{
  var props:Array<TitleScreenSpriteData>;
  var people:Array<TitleScreenSpriteData>;
  var foregroundProps:Array<TitleScreenSpriteData>;
  var defaultDancer:Bool;
}

typedef TitleScreenSpriteData =
{
  var assetPath:String;
  var x:Float;
  var y:Float;
  var right:Null<Float>;
  var bottom:Null<Float>;
  var scale:Float;
  var renderType:String;
  var assetLibrary:String;
  var animations:Array<AnimationData>;
  var startingAnimation:String;
  var danceAnimations:Array<String>;
}

class TitleScreenDataParser
{
  public static function parse(json:String):TitleScreenData
  {
    var raw:Dynamic;
    try
    {
      raw = haxe.Json.parse(json);
    }
    catch (error:Dynamic)
    {
      throw 'Could not parse data/title-screen.json: $error';
    }

    if (raw == null || !Reflect.isObject(raw) || Std.isOfType(raw, Array))
    {
      throw 'Invalid data/title-screen.json: expected an object.';
    }

    return {
      props: parseSprites(Reflect.field(raw, 'props'), 'props'),
      people: parseSprites(Reflect.field(raw, 'people'), 'people'),
      foregroundProps: parseSprites(Reflect.field(raw, 'foregroundProps'), 'foregroundProps'),
      defaultDancer: readOptionalBool(raw, 'defaultDancer', false, 'title screen', 0)
    };
  }

  static function parseSprites(raw:Dynamic, fieldName:String):Array<TitleScreenSpriteData>
  {
    if (raw == null) return [];
    if (!Std.isOfType(raw, Array)) throw 'Invalid title screen "$fieldName": expected an array.';

    var result:Array<TitleScreenSpriteData> = [];
    var spriteList:Array<Dynamic> = cast raw;
    for (index in 0...spriteList.length)
    {
      var sprite:Dynamic = spriteList[index];
      var path:String = readString(sprite, 'assetPath', fieldName, index);
      var x:Float = readNumber(sprite, 'x', fieldName, index);
      var y:Float = readNumber(sprite, 'y', fieldName, index);
      var right:Null<Float> = readOptionalNullableNumber(sprite, 'right', fieldName, index);
      var bottom:Null<Float> = readOptionalNullableNumber(sprite, 'bottom', fieldName, index);
      var scale:Float = readOptionalNumber(sprite, 'scale', 1.0, fieldName, index);
      var renderType:String = readOptionalString(sprite, 'renderType', 'sparrow', fieldName, index);
      var assetLibrary:String = readOptionalString(sprite, 'assetLibrary', '', fieldName, index);
      var animations:Array<AnimationData> = parseAnimations(Reflect.field(sprite, 'animations'), fieldName, index);
      var startingAnimation:String = readOptionalString(sprite, 'startingAnimation', '', fieldName, index);
      var danceAnimations:Array<String> = parseDanceAnimations(Reflect.field(sprite, 'danceAnimations'), animations, fieldName, index);

      if (scale <= 0) throw 'Invalid title screen "$fieldName" entry $index: scale must be greater than zero.';
      if (renderType != 'sparrow' && renderType != 'animateatlas')
      {
        throw 'Invalid title screen "$fieldName" entry $index: renderType must be "sparrow" or "animateatlas".';
      }
      if (startingAnimation != '' && !animations.exists((animation) -> animation.name == startingAnimation))
      {
        throw 'Invalid title screen "$fieldName" entry $index: startingAnimation "$startingAnimation" is not declared in animations.';
      }

      result.push({
        assetPath: path,
        x: x,
        y: y,
        right: right,
        bottom: bottom,
        scale: scale,
        renderType: renderType,
        assetLibrary: assetLibrary,
        animations: animations,
        startingAnimation: startingAnimation,
        danceAnimations: danceAnimations
      });
    }

    return result;
  }

  static function parseAnimations(raw:Dynamic, fieldName:String, index:Int):Array<AnimationData>
  {
    if (raw == null) return [];
    if (!Std.isOfType(raw, Array)) throw 'Invalid title screen "$fieldName" entry $index: animations must be an array.';

    var result:Array<AnimationData> = [];
    var animationList:Array<Dynamic> = cast raw;
    for (animationIndex in 0...animationList.length)
    {
      var animation:Dynamic = animationList[animationIndex];
      var name = readString(animation, 'name', '$fieldName animation', animationIndex);
      var prefix = readString(animation, 'prefix', '$fieldName animation', animationIndex);
      var frameRate = readOptionalNumber(animation, 'frameRate', 24, '$fieldName animation', animationIndex);
      if (frameRate < 1 || frameRate != Math.floor(frameRate))
      {
        throw 'Invalid title screen "$fieldName" animation $animationIndex: frameRate must be a positive integer.';
      }
      result.push({
        name: name,
        prefix: prefix,
        frameRate: Std.int(frameRate),
        looped: readOptionalBool(animation, 'looped', false, '$fieldName animation', animationIndex),
        frameIndices: readOptionalIntArray(animation, 'frameIndices', '$fieldName animation', animationIndex)
      });
    }

    return result;
  }

  static function parseDanceAnimations(raw:Dynamic, animations:Array<AnimationData>, fieldName:String, index:Int):Array<String>
  {
    var result:Array<String>;
    if (raw == null)
    {
      result = ['danceLeft', 'danceRight'];
    }
    else
    {
      if (!Std.isOfType(raw, Array)) throw 'Invalid title screen "$fieldName" entry $index: danceAnimations must be an array.';
      var names:Array<Dynamic> = cast raw;
      if (names.length != 2 || !Std.isOfType(names[0], String) || !Std.isOfType(names[1], String))
      {
        throw 'Invalid title screen "$fieldName" entry $index: danceAnimations must contain two animation names.';
      }
      result = [cast names[0], cast names[1]];
    }

    if (animations.length == 0)
    {
      if (raw != null) throw 'Invalid title screen "$fieldName" entry $index: danceAnimations requires declared animations.';
      return [];
    }

    var hasFirst:Bool = false;
    var hasSecond:Bool = false;
    for (animation in animations)
    {
      if (animation.name == result[0]) hasFirst = true;
      if (animation.name == result[1]) hasSecond = true;
    }

    if (!hasFirst || !hasSecond)
    {
      if (raw != null) throw 'Invalid title screen "$fieldName" entry $index: danceAnimations must name two declared animations.';
      return [];
    }
    return result;
  }

  static function readString(object:Dynamic, field:String, group:String, index:Int):String
  {
    validateObject(object, group, index);
    var value:Dynamic = Reflect.field(object, field);
    if (!Std.isOfType(value, String) || (cast value:String).length == 0)
    {
      throw 'Invalid title screen "$group" entry $index: "$field" must be a non-empty string.';
    }
    return cast value;
  }

  static function readOptionalString(object:Dynamic, field:String, defaultValue:String, group:String, index:Int):String
  {
    validateObject(object, group, index);
    var value:Dynamic = Reflect.field(object, field);
    if (value == null) return defaultValue;
    if (!Std.isOfType(value, String)) throw 'Invalid title screen "$group" entry $index: "$field" must be a string.';
    return cast value;
  }

  static function readNumber(object:Dynamic, field:String, group:String, index:Int):Float
  {
    return readOptionalNumber(object, field, Math.NaN, group, index);
  }

  static function readOptionalNumber(object:Dynamic, field:String, defaultValue:Float, group:String, index:Int):Float
  {
    validateObject(object, group, index);
    var value:Dynamic = Reflect.field(object, field);
    if (value == null && !Math.isNaN(defaultValue)) return defaultValue;
    if (!Std.isOfType(value, Int) && !Std.isOfType(value, Float))
    {
      throw 'Invalid title screen "$group" entry $index: "$field" must be a number.';
    }

    var number:Float = value;
    if (Math.isNaN(number) || !Math.isFinite(number)) throw 'Invalid title screen "$group" entry $index: "$field" must be finite.';
    return number;
  }

  static function readOptionalNullableNumber(object:Dynamic, field:String, group:String, index:Int):Null<Float>
  {
    validateObject(object, group, index);
    var value:Dynamic = Reflect.field(object, field);
    if (value == null) return null;
    if (!Std.isOfType(value, Int) && !Std.isOfType(value, Float))
    {
      throw 'Invalid title screen "$group" entry $index: "$field" must be a number.';
    }

    var number:Float = value;
    if (Math.isNaN(number) || !Math.isFinite(number)) throw 'Invalid title screen "$group" entry $index: "$field" must be finite.';
    return number;
  }

  static function readOptionalBool(object:Dynamic, field:String, defaultValue:Bool, group:String, index:Int):Bool
  {
    validateObject(object, group, index);
    var value:Dynamic = Reflect.field(object, field);
    if (value == null) return defaultValue;
    if (!Std.isOfType(value, Bool)) throw 'Invalid title screen "$group" entry $index: "$field" must be a boolean.';
    return cast value;
  }

  static function readOptionalIntArray(object:Dynamic, field:String, group:String, index:Int):Null<Array<Int>>
  {
    validateObject(object, group, index);
    var value:Dynamic = Reflect.field(object, field);
    if (value == null) return null;
    if (!Std.isOfType(value, Array)) throw 'Invalid title screen "$group" entry $index: "$field" must be an array.';

    var rawValues:Array<Dynamic> = cast value;
    var result:Array<Int> = [];
    for (valueIndex in 0...rawValues.length)
    {
      var item:Dynamic = rawValues[valueIndex];
      if (!Std.isOfType(item, Int)) throw 'Invalid title screen "$group" entry $index: "$field" must contain integers.';
      result.push(cast item);
    }
    return result;
  }

  static function validateObject(value:Dynamic, group:String, index:Int):Void
  {
    if (value == null || !Reflect.isObject(value) || Std.isOfType(value, Array))
    {
      throw 'Invalid title screen "$group" entry $index: expected an object.';
    }
  }
}
