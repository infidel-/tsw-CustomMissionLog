import com.GameInterface.Game.Character;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.Quests;
import com.GameInterface.UtilsBase;
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
	public static var curButtonX: Number;
	public static var btnScaleDown: MovieClip;
	public static var btnScaleUp: MovieClip;
	
	public function Main(swfRoot:MovieClip)
    {
		isDrag = false;
		curButtonX = 5;
		
		cont = swfRoot.createEmptyMovieClip("missionLogContainer", 
			swfRoot.getNextHighestDepth());
		var tt = cont.createTextField("missionLog", 
			cont.getNextHighestDepth(), 0, 0, 500, 200);
		var t: TextField = tt;
		cont._x = 10;
		cont._y = 50;
		t._width = 500;
		t._height = 200;
		t._name = "missionLog";
		t._alpha = 80;
		t.autoSize = "left";
		t.html = true;
		t.embedFonts = true;
		t.multiline = true;
		t.wordWrap = true;
		t.backgroundColor = 0x000000;
		t.background = true;
		textField = t;

		// create all buttons
		textFormatButton = new TextFormat(
			"lib.Aller.ttf", 16, 0xBBFFFF, true, false, false);
		btnScaleDown = createButton('btnScaleDown', '-');
		btnScaleUp = createButton('btnScaleUp', '+');
		
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
		Mouse.addListener(mouseListener);
		
		// text format
		var tf:TextFormat = new TextFormat(
			"lib.Aller.ttf", 18, 0xCCCCCC, true, false,
			false);
		tf.leftMargin = 5;
		tf.rightMargin = 5;
		t.setNewTextFormat(tf);
//      var c:Character = Character.GetClientCharacter();
//      t.text = "Hello " + c.GetName() + ". Welcome!";

		// hax: redraw window every 1 seconds
		setInterval(redraw, 1000);
    }
	
	
	// create simple button with text on it
	function createButton(name: String, s: String): MovieClip
	{
		var btn = cont.createEmptyMovieClip(name, 
			cont.getNextHighestDepth());
		var tt = btn.createTextField(name + "Text",
			cont.getNextHighestDepth(),
			curButtonX, 0, 20, 20);
		curButtonX += 16;
		var t: TextField = tt;
		t.autoSize = "left";
		t.backgroundColor = 0x111111;
		t.background = true;
		t.setNewTextFormat(textFormatButton);
		t.text = s;
		
		return btn;
	}
	
	
	static function onPressButton(): Boolean
	{
		// scale up, +
		if (btnScaleUp.hitTest(_root._xmouse, _root._ymouse, true))
		{
			cont._xscale += 10;
			cont._yscale += 10;
			return true;
		}

		// scale down, -
		if (btnScaleDown.hitTest(_root._xmouse, _root._ymouse, true))
		{
			cont._xscale -= 10;
			cont._yscale -= 10;
			return true;
		}
		
		return false;
	}
	
	// pressing window and buttons
	function onPress()
	{
		// check for button presses
		if (onPressButton())
			return;
		
		// start dragging
		isDrag = true;
		xDrag = cont._xmouse;
		yDrag = cont._ymouse;
	}
	
	// drag window
	function onMouseMove(id: Number, x: Number, y: Number)
	{
		if (!isDrag)
			return;
		cont._x += cont._xmouse - xDrag;
		cont._y += cont._ymouse - yDrag;
	}
	
	// stop dragging
	function onRelease()
	{
		isDrag = false;
	}
   
	// redraw all text
	public function redraw()
	{
//		UtilsBase.PrintChatText("REDRAW");
		var quests:Array = Quests.GetAllActiveQuests();
		var text:String = "\n"; // skip one line for buttons
		for ( var i = 0; i < quests.length; ++i )
		{
			// basic mission info
			var quest:Quest = quests[i];
			
			var missionType:String = GUI.Mission.MissionUtils.MissionTypeToString( quest.m_MissionType );
			var tier:String = quest.m_CurrentTask.m_Tier + "/" + quest.m_TierMax;
			text += quest.m_MissionName + " <" + missionType + "> [" +
				tier + "]\n";
			// skip global mission description for now
			if (quest.m_MissionType != _global.Enums.MainQuestType.e_Story)
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
					text += goalDesc + "\n";
				}
			}

			text += "\n";
		}
		
		textField.text = text;
	}
	

	public static var inst: Main;
	public static function main(swfRoot:MovieClip):Void
	{
	  inst = new Main(swfRoot);
	}
}
