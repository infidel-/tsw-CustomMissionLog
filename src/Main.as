import TextField.StyleSheet;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.Quests;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import com.Utils.Point;
 
class Main
{
	// made all fields static because of weird scope bugs
	public static var cont: MovieClip;
	public static var textField: TextField;
	public static var textFormatButton: TextFormat;
	public static var isDrag: Boolean;
	public static var xDrag: Number;
	public static var yDrag: Number;
	public static var isResize: Boolean;
	public static var xResize: Number;
	public static var oldWidth: Number;
	public static var curButtonX: Number;
	public static var btnScaleDown: MovieClip;
	public static var btnScaleUp: MovieClip;
	public static var btnMinimize: MovieClip;
	public static var btnResize: MovieClip;
	public static var btnOptions: MovieClip;

	public static var fmtDefault: TextFormat;
	public static var fmtTitle: TextFormat;
	public static var fmtGoal: TextFormat;
	public static var fmtTypeAction: TextFormat;
	public static var fmtTypeInvestigation: TextFormat;
	public static var fmtTypeSabotage: TextFormat;
	public static var fmtTypeStory: TextFormat;
	public static var fmtTypeDungeon: TextFormat;
	public static var fmtTypeRaid: TextFormat;
	public static var fmtTypeSide: TextFormat;
	
	public static var valX: DistributedValue;
	public static var valY: DistributedValue;
	public static var valScale: DistributedValue;
	public static var valWidth: DistributedValue;
	public static var valMin: DistributedValue;
	
	public static var valDesc: DistributedValue;
	public static var valTransparent: DistributedValue;
	public static var valSingleMission: DistributedValue;
	public static var options: CustomMissionLogOptions;

	
	public function Main(swfRoot:MovieClip)
    {
		isDrag = false;
		isResize = false;
		curButtonX = 5;

		// load config values
/*
		var v:DistributedValue = DistributedValue.Create("ActiveQuestID");
		v.SignalChanged.Connect(function () { inst.redraw();  UtilsBase.PrintChatText('changed!'); }, this);*/
		valX = DistributedValue.Create("CustomMissionLog.x");
		valY = DistributedValue.Create("CustomMissionLog.y");
		valScale = DistributedValue.Create("CustomMissionLog.scale");
		valWidth = DistributedValue.Create("CustomMissionLog.width");
		valMin = DistributedValue.Create("CustomMissionLog.min");
		valDesc = DistributedValue.Create("CustomMissionLog.desc");
		valTransparent = DistributedValue.Create("CustomMissionLog.transparent");
		valSingleMission = DistributedValue.Create("CustomMissionLog.singleMission");

		cont = swfRoot.createEmptyMovieClip("cmlContainer", 
			swfRoot.getNextHighestDepth());
		var tt = cont.createTextField("cmlText", 
			cont.getNextHighestDepth(), 0, 0, valWidth.GetValue(), 200);
		var t: TextField = tt;
		cont._x = valX.GetValue();
		cont._y = valY.GetValue();
		cont._xscale = valScale.GetValue();
		cont._yscale = valScale.GetValue();
		t._alpha = 80;
		t.autoSize = "left";
		t.html = true;
		t.embedFonts = true;
		t.multiline = true;
		t.wordWrap = true;
		t.backgroundColor = 0x000000;
		t.background = (valTransparent.GetValue() == 0);
		textField = t;

		// create all buttons
		textFormatButton = new TextFormat(
			"lib.Aller.ttf", 16, 0xBBFFFF, true, false, false);
		btnScaleDown = createButton('btnScaleDown', '-');
		btnScaleUp = createButton('btnScaleUp', '+');
		btnOptions = createButton('btnOptions', 'OPTS');
		btnMinimize = createButton('btnMinimize', 'MIN');
		btnResize = createButton('btnResize', 'RESIZE');

		// Redraw on all quest signals that are not quest goals.
		// does not work btw vOv
		Quests.SignalQuestAvailable.Connect(redraw, this)
		Quests.SignalQuestEvent.Connect(redraw, this)
		Quests.SignalTaskAdded.Connect(redraw, this)
		Quests.SignalMissionRemoved.Connect(redraw, this)
		Quests.SignalPlayerTiersChanged.Connect(redraw, this)
		Quests.SignalQuestChanged.Connect(redraw, this)
		Quests.SignalTierCompleted.Connect(redraw, this)
		Quests.SignalTierFailed.Connect(redraw, this)
		Quests.SignalMissionCompleted.Connect(redraw, this)
		Quests.SignalCompletedQuestsChanged.Connect(redraw, this)
		Quests.SignalGoalProgress.Connect(redraw, this );
		Quests.SignalGoalPhaseUpdated.Connect(redraw, this );
		Quests.SignalQuestCooldownChanged.Connect( redraw, this );
		
		// mouse events
		cont.onRelease = onRelease;
		cont.onPress = onPress;
		var mouseListener = new Object;
		mouseListener.onMouseMove = onMouseMove;
		mouseListener.onMouseUp = onReleaseGlobal;
		Mouse.addListener(mouseListener);
		
		// text format
		fmtDefault = new TextFormat("lib.Aller.ttf", 18, 0xCCCCCC, true, false, false);
		fmtTitle = new TextFormat("lib.Aller.ttf", 20, 0xFFFFFF, true, false, false);
		fmtGoal = new TextFormat("lib.Aller.ttf", 18, 0x63f99a, true, false, false);
		fmtTypeAction = new TextFormat("lib.Aller.ttf", 18, 0xf04949, true, false, false);
		fmtTypeInvestigation = new TextFormat("lib.Aller.ttf", 18, 0x54ae16, true, false, false);
		fmtTypeSabotage = new TextFormat("lib.Aller.ttf", 18, 0xeca603, true, false, false);
		fmtTypeStory = new TextFormat("lib.Aller.ttf", 18, 0x53bda5, true, false, false);
		fmtTypeDungeon = new TextFormat("lib.Aller.ttf", 18, 0xcc3bff, true, false, false);
		fmtTypeRaid = new TextFormat("lib.Aller.ttf", 18, 0xcc3bff, true, false, false);
		fmtTypeSide = new TextFormat("lib.Aller.ttf", 18, 0xBBBBBB, true, false, false);
		t.setNewTextFormat(fmtTitle);
		t.setNewTextFormat(fmtDefault);
		
		options = new CustomMissionLogOptions(swfRoot, this);

		// hax: redraw window every 1 seconds
		setInterval(redraw, 1000);
    }


	// converts mission type to format
	static function getTypeFormat(missionType: Number): TextFormat
	{
		switch (missionType)
		{
			case _global.Enums.MainQuestType.e_Action:
				return fmtTypeAction;
			case _global.Enums.MainQuestType.e_Sabotage:
				return fmtTypeSabotage;
			case _global.Enums.MainQuestType.e_Investigation:
				return fmtTypeInvestigation
			case _global.Enums.MainQuestType.e_StoryRepeat:
				return fmtTypeStory;
			case  _global.Enums.MainQuestType.e_Story:
				return fmtTypeStory;
            case _global.Enums.MainQuestType.e_Raid:
				return fmtTypeRaid;
		}
		return fmtTypeSide;
	}


	// create simple button with text on it
	function createButton(name: String, s: String): MovieClip
	{
		var btn = cont.createEmptyMovieClip(name, 
			cont.getNextHighestDepth());
		var tt = btn.createTextField(name + "Text",
			cont.getNextHighestDepth(),
			curButtonX, 0, 20, 20);
		var t: TextField = tt;
		t.autoSize = "left";
		t.backgroundColor = 0x111111;
		t.background = true;
		t.setNewTextFormat(textFormatButton);
		t.text = s;
		curButtonX += t.textWidth + 5;
		
		return btn;
	}


	static function onPressButton(): Boolean
	{
		// scale up, +
		if (btnScaleUp.hitTest(_root._xmouse, _root._ymouse, true))
		{
			var scale = valScale.GetValue();
			scale += 10;
			valScale.SetValue(scale);
			cont._xscale = scale;
			cont._yscale = scale;
			inst.redraw();
			return true;
		}

		// scale down, -
		if (btnScaleDown.hitTest(_root._xmouse, _root._ymouse, true))
		{
			var scale = valScale.GetValue();
			scale -= 10;
			valScale.SetValue(scale);
			cont._xscale = scale;
			cont._yscale = scale;
			inst.redraw();
			return true;
		}

		// minimize
		if (btnMinimize.hitTest(_root._xmouse, _root._ymouse, true))
		{
			valMin.SetValue(!valMin.GetValue());
			inst.redraw();
			return true;
		}

		// options window
		if (btnOptions.hitTest(_root._xmouse, _root._ymouse, true))
		{
			options.show(cont);
			return true;
		}

		return false;
	}


	// pressing window and buttons
	function onPress()
	{
		// start resizing
		if (btnResize.hitTest(_root._xmouse, _root._ymouse, true))
		{
			isResize = true;
			xResize = cont._xmouse;
			oldWidth = textField._width;
			textField.background = true;
			textField.backgroundColor = 0x552222;
			return;
		}

		// check for button presses
		if (onPressButton())
			return;

		// start dragging
		isDrag = true;
		xDrag = cont._xmouse;
		yDrag = cont._ymouse;
	}


	// drag/resize window
	function onMouseMove(id: Number, x: Number, y: Number)
	{
		// drag
		if (isDrag)
		{
			cont._x += cont._xmouse - xDrag;
			cont._y += cont._ymouse - yDrag;
		}

		// resize
		else if (isResize)
		{
			textField._width = oldWidth + textField._xmouse - xResize;
		}
	}

	// button presses
	function onRelease()
	{
		// check for button presses
		//onPressButton();
	}
	
	// stop dragging/resizing
	function onReleaseGlobal()
	{
		// stop resizing
		isResize = false;
		textField.background = (valTransparent.GetValue() == 0);
		textField.backgroundColor = 0;
		valWidth.SetValue(textField._width);

		// stop dragging and save window position
		isDrag = false;
		valX.SetValue(cont._x);
		valY.SetValue(cont._y);
	}

	static var ranges: Array;
	static function addString(text: String, f: TextFormat, s: String)
	{
		var idx = text.length - 1;
		ranges.push({
			start: idx,
			end: idx + s.length + 1,
			fmt: f
		});
		text += s;
	}
	
	// redraw all text
	public function redraw()
	{
		// show only single mission
		var singleMissionID = 0;
		if (valSingleMission.GetValue() == 1)
			singleMissionID = DistributedValue.GetDValue("ActiveQuestID");

		// window minified
		if (valMin.GetValue())
		{
			textField.text = '\n';
			return;
		}

//		UtilsBase.PrintChatText("REDRAW");
		var quests:Array = Quests.GetAllActiveQuests();
		var text:String = "\n"; // skip one line for buttons
		ranges = new Array();

		// form a temp mission array
		var tmp = new Array();
		for (var i = 0; i < quests.length; ++i)
			if (singleMissionID == 0 || quests[i].m_ID == singleMissionID)
				tmp.push(quests[i]);

		// main story first
		for (var i = 0; i < tmp.length; ++i)
		{
			var quest = tmp[i];
			if (quest.m_MissionType != _global.Enums.MainQuestType.e_Story &&
				quest.m_MissionType != _global.Enums.MainQuestType.e_StoryRepeat)
				continue;

			text = addMissionText(text, quest);
			delete tmp[i];
		}

		// action/sabotage/investigation next
		for (var i = 0; i < tmp.length; ++i)
		{
			var quest = tmp[i];
			if (quest.m_MissionType != _global.Enums.MainQuestType.e_Story &&
				quest.m_MissionType != _global.Enums.MainQuestType.e_Action &&
				quest.m_MissionType != _global.Enums.MainQuestType.e_Sabotage &&
				quest.m_MissionType != _global.Enums.MainQuestType.e_Investigation &&
				quest.m_MissionType != _global.Enums.MainQuestType.e_Raid)
				continue;

			text = addMissionText(text, quest);
			delete tmp[i];
		}

		// the rest
		for (var i = 0; i < tmp.length; ++i)
			if (tmp[i] != undefined)
				text = addMissionText(text, tmp[i]);
		
		// set text and mark ranges for styles
		textField.text = text;
		for (var i = 0; i < ranges.length; ++i)
		{
			var r = ranges[i];
//			UtilsBase.PrintChatText('' + r.start + ' ' + r.end);
			textField.setTextFormat(r.start, r.end, r.fmt);
		}

		// pull up if we grow too large
		if (cont._y + cont._height > Stage.height - 10)
			cont._y = Stage.height - 10 - cont._height;
		// but don't grow outside
		if (cont._y < 30)
			cont._y = 30;
	}


	// add mission text to full window text and return it
	static function addMissionText(text: String, quest: Quest): String
	{
		// basic mission info
		var missionType:String = GUI.Mission.MissionUtils.MissionTypeToString(quest.m_MissionType);
		var tier:String = quest.m_CurrentTask.m_Tier + "/" + quest.m_TierMax;
		addString(text, fmtTitle, quest.m_MissionName);
		text += quest.m_MissionName + " ";
		addString(text, getTypeFormat(quest.m_MissionType),
			"<" + missionType + ">");
		text += "<" + missionType + "> [L" +
			quest.m_CurrentTask.m_Difficulty + "] [" +
			tier + "]\n";

		// skip global mission description if desc
		// 0 - all descriptions
		// 1 - skip main story
		// 2 - skip all
		var val = valDesc.GetValue(); 
		if (val == 0 || (val == 1 && quest.m_MissionType != _global.Enums.MainQuestType.e_Story))
			text += quest.m_CurrentTask.m_Desc + "\n";

		// print mission goals list
		var goals:Array = quest.m_CurrentTask.m_Goals;
		for (var goalIdx = 0; goalIdx < goals.length; ++goalIdx)
		{
			var goal:com.GameInterface.QuestGoal = goals[ goalIdx ];
			// goal completed, skipping
			if (goal.m_RepeatCount == goal.m_SolvedTimes )
				continue;

			if ( quest.m_CurrentTask.m_CurrentPhase == goal.m_Phase )
			{
				var goalDesc:String = com.Utils.LDBFormat.Translate( goal.m_Name );
				if (goal.m_RepeatCount > 1 && goal.m_SolvedTimes < goal.m_RepeatCount)
				{
					var numDesc:String = " (" + goal.m_SolvedTimes + "/" + goal.m_RepeatCount + ")";
					goalDesc += numDesc;
				}
				addString(text, fmtGoal, goalDesc);
				text += goalDesc + "\n";
			}
		}

		text += "\n";

		return text;
	}


	public static var inst: Main;
	public static function main(swfRoot:MovieClip):Void
	{
	  inst = new Main(swfRoot);
	}
}
