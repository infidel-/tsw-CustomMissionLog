import com.GameInterface.Game.Character;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.Quests;
import com.GameInterface.UtilsBase;
import com.Utils.LDBFormat;
import com.Utils.Point;
 

class Main
{
	public var cont: MovieClip;
	public var textField: TextField;
	public var isDrag: Boolean;
	public var xDrag: Number;
	public var yDrag: Number;
	
	public function Main(swfRoot:MovieClip)
    {
		isDrag = false;
		
		this.cont = swfRoot.createEmptyMovieClip("missionLogContainer", 1);
		var tt = cont.createTextField("missionLog", 1, 0, 0, 500, 200);
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
//		cont.onRelease = onRelease;
//		cont.onPress = onPress;
		var mouseListener = new Object;
		mouseListener.onMouseDown = onPress;
		mouseListener.onMouseUp = onRelease;
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

		// hax: redraw window every 2 seconds
		setInterval(redraw, 2000);
    }
	
	
	// start dragging
	function onPress()
	{
		// mouse outside window
		if (inst.cont._xmouse < 0 ||
			inst.cont._ymouse < 0 ||
			inst.cont._xmouse > inst.cont._width ||
			inst.cont._ymouse > inst.cont._height)
			return;

		inst.isDrag = true;
		inst.xDrag = inst.cont._xmouse;
		inst.yDrag = inst.cont._ymouse;
/*		
		UtilsBase.PrintChatText("PRESS " + inst.isDrag +
			" " + inst.xDrag + "," + inst.yDrag +
			" " + inst.cont._width + "," + inst.cont._height);
*/
	}
	
	// drag window
	function onMouseMove(id: Number, x: Number, y: Number)
	{
//		UtilsBase.PrintChatText("isDrag:" + inst.isDrag +
//			" X " + isDrag);
		if (!inst.isDrag)
			return;
		inst.cont._x += inst.cont._xmouse - inst.xDrag;
		inst.cont._y += inst.cont._ymouse - inst.yDrag;
	}
	
	// stop dragging
	function onRelease()
	{
		// mouse outside window
		if (inst.cont._xmouse < 0 ||
			inst.cont._ymouse < 0 ||
			inst.cont._xmouse > inst.cont._width ||
			inst.cont._ymouse > inst.cont._height)
			return;

		inst.isDrag = false;
//		UtilsBase.PrintChatText("RELEASE " + inst.isDrag);
	}
   
	// redraw all text
	public function redraw()
	{
//		UtilsBase.PrintChatText("REDRAW");
		var quests:Array = Quests.GetAllActiveQuests();
		var text:String = "";
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
		
		inst.textField.text = text;
	}
	

	public static var inst: Main;
	public static function main(swfRoot:MovieClip):Void
	{
	  inst = new Main(swfRoot);
	}
}
