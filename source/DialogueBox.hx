package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var skipText:FlxText;
	var curCharacter:String = '';

	var curAnim:String = '';
	var prevChar:String = '';

	var effectQue:Array<String> = [""];
	var effectParamQue:Array<String> = [""];

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???/
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var daFontSize:Int = 32;
	
	var cutsceneImage:FlxSprite;
	//var sound:FlxSound;

	public var finishThing:Void->Void;

	var portraitBF:Portrait;
	var portraitGF:Portrait;
	var portraitRUV:Portrait;
	var portraitRAS:Portrait;
	var portraitSEL:Portrait;
	var portraitSARV:Portrait;
	var portraitNOCHAR:Portrait;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;	
	
	var canAdvance = false;	

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
				canAdvance = true;
		});

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
	
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		cutsceneImage = new FlxSprite(0, 0);
		cutsceneImage.visible = false;
		add(cutsceneImage);

		FlxTween.tween(bgFade, {alpha: 0.7}, 1, {ease: FlxEase.circOut});
		
		box = new FlxSprite(-20, 45);			
		box.frames = Paths.getSparrowAtlas('dialogue/speech_bubble_talking', 'shared');
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);	
		box.width = 200;
		box.height = 200;
		box.x = -100;
		box.y = 375;

		this.dialogueList = dialogueList;
		
		portraitBF = new Portrait(600, 40, "bF");
		add(portraitBF);

		portraitGF = new Portrait(200, 40, "gf");
		add(portraitGF);

		portraitRUV = new Portrait(200, 40, "ruv");
		add(portraitRUV);

		portraitRAS = new Portrait(200, 40, "ras");
		add(portraitRAS);
		
		portraitSEL = new Portrait(200, 40, "sel");
		add(portraitSEL);
		
		portraitSARV = new Portrait(200, 40, "sarv");
		add(portraitSARV);
		
		portraitNOCHAR = new Portrait(0, 9999, "noChar");
		add(portraitNOCHAR);
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('dialogue/hand_textbox', 'shared'));
		add(handSelect);

		if (!talkingRight)
		{
			//box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.setFormat(Paths.font("15111.ttf"), daFontSize, 0xFF3F2021, LEFT);
		dropText.color = 0xFF4BC4;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.setFormat(Paths.font("15111.ttf"), daFontSize, 0xFF3F2021, LEFT);
		add(swagDialogue);

        #if desktop		
		skipText = new FlxText(5, 695, 640, "Press SPACE to skip the dialogue.\n", 40);
		#else
		skipText = new FlxText(5, 695, 640, "Press BACK to skip the dialogue.\n", 40);
		#end
		skipText.scrollFactor.set(0, 0);
		skipText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.borderSize = 2;
		skipText.borderQuality = 1;
		add(skipText);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		#if mobile
		var justTouched:Bool = false;

		for (touch in FlxG.touches.list)
		{
			justTouched = false;
			
			if (touch.justReleased){
				justTouched = true;
			}
		}
		#end
		
		if(FlxG.keys.justPressed.SPACE#if android || FlxG.android.justReleased.BACK #end && !isEnding)
		{
			isEnding = true;
			endDialogue();
		}

		if (FlxG.keys.justPressed.ANY #if mobile || justTouched #end && dialogueStarted == true && canAdvance && !isEnding)
		{
			canAdvance = false;

			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				canAdvance = true;
			});
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
					endDialogue();
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function endDialogue()
	{
		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
			FlxG.sound.music.fadeOut(2.2, 0);

		hideAll();
		FlxTween.tween(box, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(bgFade, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(cutsceneImage, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(swagDialogue, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(dropText, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(skipText, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxG.sound.music.fadeOut(1.2, 0);

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			finishThing();
			kill();
			FlxG.sound.music.stop();
		});
	}

	function startDialogue():Void
	{
		var setDialogue = false;
		var skipDialogue = false;
		cleanDialog();
		hideAll();

		box.visible = true;
		box.flipX = true;
		swagDialogue.visible = true;
		dropText.visible = true;

        switch (curCharacter)
		{
			case "bf":
				portraitBF.playFrame(curAnim);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('boxsound/bf_sound', 'shared'), 1.0)];
			case "gf":
				portraitGF.playFrame(curAnim);
                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('boxsound/gf_sound', 'shared'), 1.0)];
			case "ruv":
				portraitRUV.playFrame(curAnim);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('boxsound/ruv_sound', 'shared'), 1.0)];
			case "ras":
				portraitRAS.playFrame(curAnim);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 1.0)];
			case "sel":
				portraitSEL.playFrame(curAnim);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 1.0)];
			case "sarv":
				portraitSARV.playFrame(curAnim);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('boxsound/sarv_sound', 'shared'), 1.0)];	
			case "noChar":
				portraitNOCHAR.playFrame("default");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 1.0)];
			
			case "effect":
				switch(curAnim)
				{
					case "hidden":
						swagDialogue.visible = false;
						dropText.visible = false;
						box.visible = false;
						setDialogue = true;
						swagDialogue.resetText("");
					default:
						effectQue.push(curAnim);
						effectParamQue.push(dialogueList[0]);
						skipDialogue = true;
				}
			case "bg":
				skipDialogue = true;
				switch(curAnim)
				{
					case "hide":
						cutsceneImage.visible = false;
					default:
						cutsceneImage.visible = true;
						cutsceneImage.loadGraphic(BitmapData.fromFile("assets/dialogue/images/bg/" + curAnim + ".png"));
				}
				
			default:
				trace("default dialogue event");
				portraitBF.playFrame();
		}
		
		prevChar = curCharacter;

		if(!skipDialogue)
		{
			if(!setDialogue)
			{
				swagDialogue.resetText(dialogueList[0]);
			}

			swagDialogue.start(0.04, true);
			runEffectsQue();
		}
		else
		{
			dialogueList.remove(dialogueList[0]);
			startDialogue();			
		}
	}

	function cleanDialog():Void
	{
		while(dialogueList[0] == ""){
			dialogueList.remove(dialogueList[0]);
		}

		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curAnim = splitName[2];
	
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length  + 3).trim();
	}
	
	function runEffectsQue(){
	
		for(i in 0...effectQue.length){

			switch(effectQue[i]){

				case "fadeOut":
					effectFadeOut(Std.parseFloat(effectParamQue[i]));
				case "fadeIn":
					effectFadeIn(Std.parseFloat(effectParamQue[i]));
				case "exitStageLeft":
					effectExitStageLeft(Std.parseFloat(effectParamQue[i]));
				case "exitStageRight":
					effectExitStageRight(Std.parseFloat(effectParamQue[i]));
				case "enterStageLeft":
					effectEnterStageLeft(Std.parseFloat(effectParamQue[i]));
				case "enterStageRight":
					effectEnterStageRight(Std.parseFloat(effectParamQue[i]));
				case "rightSide":
					effectFlipRight();
				case "flip":
					effectFlipDirection();
				case "toLeft":
					effectToLeft();
				case "toRight":
					effectToRight();
				//case "shake":
					//effectShake(Std.parseFloat(effectParamQue[i]));
				default:

			}

		}

		effectQue = [""];
		effectParamQue = [""];

	}

	function portraitArray()
	{
	    var portraitArray = [portraitBF,portraitGF,portraitRUV,portraitRAS,portraitSEL,portraitSARV,portraitNOCHAR];
	    return portraitArray;
	}
	

	function hideAll():Void{
		
		for(i in 0...portraitArray().length){
		portraitArray()[i].hide();
		}
	}

	function effectFadeOut(?time:Float = 1):Void{
		for(i in 0...portraitArray().length){
		portraitArray()[i].effectFadeOut(time);
		}
	}

	function effectFadeIn(?time:Float = 1):Void{
		for(i in 0...portraitArray().length){
		portraitArray()[i].effectFadeIn(time);
		}
	}

	function effectExitStageLeft(?time:Float = 1):Void{
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectExitStageLeft(time);
			}
	}

	function effectExitStageRight(?time:Float = 1):Void{
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectExitStageRight(time);
			}
	}

	function effectFlipRight(){
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectFlipRight();
			}
			box.flipX = false;
		
	}
	
	function effectFlipDirection(){
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectFlipDirection();
			}
		
	}

	function effectEnterStageLeft(?time:Float = 1){
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectEnterStageLeft(time);
			}
		
	}

	function effectEnterStageRight(?time:Float = 1){
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectEnterStageRight(time);
			}
	
	}

	function effectToRight(?time:Float = 1){
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectToRight(time);
			}
		
		box.flipX = false;
	}

	function effectToLeft(?time:Float = 1){
		for(i in 0...portraitArray().length){
			portraitArray()[i].effectToLeft(time);
			}
		
	}
}
