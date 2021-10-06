package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Portrait extends FlxSprite
{

    private var refx:Float;
    private var refy:Float;

    private var resize = 0.35;

    public var characters:Array<String> = ["bf", "gf", "sarv", "ruv", "sel", "ras", "noChar"];

    var posTween:FlxTween;
    var alphaTween:FlxTween;
	
    public function new(_x:Float, _y:Float, _character:String){

        super(_x, _y);

        defineCharacter(_character);
        setGraphicSize(Std.int(width * resize));
        updateHitbox();
        scrollFactor.set();
        antialiasing = true;

        refx = x;
        refy = y + height;

        playFrame();
        posTween = FlxTween.tween(this, {x: x}, 0.1);
        alphaTween = FlxTween.tween(this, {alpha: alpha}, 0.1);
        hide();

    }

    function defineCharacter(_character)
	{
        _character = characters.contains(_character) ? _character : "bf";
        frames = Paths.getSparrowAtlas("dialogue/characters/" + _character, "shared");

        switch(_character)
		{
            case "noChar":
                addAnim("default", "noChar instance 1");
            case "bf":
                addAnim("default", "bf Default");
                addAnim("beep", "bf Beep");
                addAnim("uhh", "bf Uhh");
                animation.play("default");
				resize = 1;
            case "gf":
                addAnim("default", "gf Cheer");
                addAnim("talk", "gf Talk");
                animation.play("default");
				resize = 1;
            case "ruv":
                addAnim("default", "ruv Default");
                addAnim("disgusted", "ruv Disgusted");
                addAnim("talk", "ruv Talk");
                animation.play("default");
				resize = 1;
            case "ras":
                addAnim("default", "ras Default");
                addAnim("sigh", "ras Sigh");
                animation.play("default");
				resize = 1;
            case "sel":
                addAnim("default", "sel Grin");
                addAnim("smile", "sel Smile");
                addAnim("talk", "sel Talk");
                addAnim("uh", "sel Uh");
                addAnim("xd", "sel Xd");				
                animation.play("default");
				resize = 1;
            case "sarv":
                addAnim("smile", "sarv Smile");
                addAnim("pout", "sarv Pout");
                addAnim("talk", "sarv Talk");
                addAnim("mad", "sarv Mad");
                addAnim("dark-pout", "sarv DarkPout");
                addAnim("dark-unamus", "sarv DarkUnamus");
                addAnim("luci", "sarv Luci");
                animation.play("smile");
				resize = 1;
        }
    }
    
    function addAnim(anim:String, prefix:String)
	{
        animation.addByPrefix(anim,prefix, 0, false);
    }      

    public function playFrame(?_frame:String = "default"){

        visible = true;

        animation.play(_frame);
        flipX = false;
        updateHitbox();

        x = refx;
        y = refy - height;

    }

    public function hide(){

        alphaTween.cancel();
        posTween.cancel();
        alpha = 1;
        visible = false;

    }

    public function effectFadeOut(?time:Float = 1){

        alphaTween.cancel();
        alpha = 1;
        alphaTween = FlxTween.tween(this, {alpha: 0}, time);

    }

    public function effectFadeIn(?time:Float = 1){

        alphaTween.cancel();
        alpha = 0;
        alphaTween = FlxTween.tween(this, {alpha: 1}, time);

    }

    public function effectExitStageLeft(?time:Float = 1){

        posTween.cancel();
        posTween = FlxTween.tween(this, {x: 0 - width}, time, {ease: FlxEase.circIn});

    }

    public function effectExitStageRight(?time:Float = 1){

        posTween.cancel();
        posTween = FlxTween.tween(this, {x: FlxG.width}, time, {ease: FlxEase.circIn});

    }

    public function effectFlipRight(){

        x = FlxG.width - refx - width;
        y = refy - height;

    }

    public function effectFlipDirection(){
        
        flipX = true;

    }

    public function effectEnterStageLeft(?time:Float = 1){
        
        posTween.cancel();
        var finalX = x;
        x = 0 - width;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.circOut});

    }

    public function effectEnterStageRight(?time:Float = 1){
        
        posTween.cancel();
        var finalX = x;
        x = FlxG.width;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.circOut});
    }

    public function effectToRight(?time:Float = 1){
        
        posTween.cancel();
        var finalX = FlxG.width - refx - width;
        x = refx;
        y = refy - height;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.quintOut});
    }

    public function effectToLeft(?time:Float = 1){
        
        posTween.cancel();
        var finalX = refx;
        x = FlxG.width - refx - width;
        y = refy - height;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.quintOut});
    }

   
}
