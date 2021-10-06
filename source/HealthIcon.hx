package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('face', [10, 11], 0, false, isPlayer);
		animation.add('dad', [12, 13], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.add('sarvente', [30, 31], 0, false, isPlayer);
		animation.add('sarvente-dark', [30, 31], 0, false, isPlayer);
		animation.add('sarvente-lucifer', [34, 35], 0, false, isPlayer);
		animation.add('ruv', [32, 33], 0, false, isPlayer);
		animation.add('selever', [36, 37], 0, false, isPlayer);
		if(animation.getByName(char)!=null)
			animation.play(char);
		else
			animation.play("face");
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
