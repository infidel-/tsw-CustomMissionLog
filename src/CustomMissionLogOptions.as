import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;

class CustomMissionLogOptions
{
	public static var cont: MovieClip;
	public static var textField: TextField;
	public static var textFormatButton: TextFormat;

	public static var options: Array;
	public static var main: Main;
	public static var btnClose: MovieClip;
//	public static var archive: Archive;

	
	public function CustomMissionLogOptions(swfRoot: MovieClip, mvar: Main)
	{
		main = mvar;
		options = new Array();

		cont = swfRoot.createEmptyMovieClip("cmlOptionsContainer",
			swfRoot.getNextHighestDepth());
		var tt = cont.createTextField("cmlOptionsText", 
			cont.getNextHighestDepth(), 0, 0, 310, 200);
		var t: TextField = tt;
		cont.backgroundColor = 0x000000;
		cont.background = true;
		cont._visible = false;

/*
	   archive = DistributedValue.GetDValue("CustomMissionLog_Cfg");
	   if (archive == undefined)
	   {
		   UtilsBase.PrintChatText('undef');
		 archive = new Archive;
	   }
	   UtilsBase.PrintChatText('X:' + archive);
*/

		t._alpha = 80;
		t.autoSize = "left";
		t.html = true;
		t.embedFonts = true;
		t.multiline = true;
		t.wordWrap = true;
		t.backgroundColor = 0x000000;
		t.background = true;
		textField = t;

		// text format
		var format:TextFormat = new TextFormat(
			"lib.Aller.ttf", 18, 0xCCCCCC, true, false,
			false);
		t.setNewTextFormat(format);
		textField.text = '                         OPTIONS\n\n\n\n\n\n';
		
		// button text format
		textFormatButton = new TextFormat(
			"lib.Aller.ttf", 16, 0xBBFFFF, true, false, false);

		// init items
		var optionTemplates = new Array(
			{ id: 'desc', name: 'Tier text (0/1/2)', max: 2 },
			{ id: 'transparent', name: 'Window transparency', max: 1 },
			{ id: 'singleMission', name: 'Current mission only', max: 1 },
			{ id: 'lockWindow', name: 'Lock window', max: 1 }
		);
		for (var i: Number = 0; i < optionTemplates.length; i++)
		{
			var tpl = optionTemplates[i];
			var dval:DistributedValue = DistributedValue.Create("CustomMissionLog." + tpl.id);
			var val = dval.GetValue();
			if (val == undefined)
				val = 0;
		
			// item text field
			var ttf = cont.createTextField(tpl.id + "Text", 
				cont.getNextHighestDepth(), 0, 0, 80, 20);
			var tf: TextField = ttf;
			tf._x = 20;
			tf._y = (i + 1) * 21;
			tf._alpha = 80;
			tf.autoSize = "left";
			tf.html = true;
			tf.embedFonts = true;
			tf.setNewTextFormat(format);
			tf._width = tf.textWidth;
			tf.text = tpl.name;

			// create all buttons
			var text = '' + val;
			var btn = createButton(tpl.id + 'Btn', text,
				5, (i + 1) * 21);

			// init object
			var o = {
				id: tpl.id,
				name: tpl.name,
				btn: btn,
				btnText: btn[tpl.id + 'BtnText'],
				textField: tf,
				value: val,
				dval: dval,
				max: tpl.max
			};
			options.push(o);
		}
		
		btnClose = createButton('btnClose',	'CLOSE', 100, (options.length + 1) * 21);

		// mouse events
		cont.onRelease = onRelease;
	}


	// check for button presses
	function onRelease()
	{
		// check if any buttons are pressed
		for (var i: Number = 0; i < options.length; i++)
		{
			var o = options[i];
			if (o.btn.hitTest(_root._xmouse, _root._ymouse, true))
			{
				o.value += 1;
				if (o.value > o.max)
					o.value = 0;
				o.btnText.text = o.value;
				o.dval.SetValue(o.value);
/*
				archive.AddEntry(o.id, o.value);
				UtilsBase.PrintChatText('' + archive.FindEntry(o.id, 30));
				DistributedValue.SetDValue("CustomMissionLog_Cfg", archive);
				UtilsBase.PrintChatText('FULL:' + DistributedValue.GetDValue("CustomMissionLog_Cfg"));
*/
				main.redraw();

				// apply transparency
				if (o.id == 'transparent')
				{
					Main.cont['cmlText'].background = (o.value == 0);
				}
			}
		}

		// close button
		if (btnClose.hitTest(_root._xmouse, _root._ymouse, true))
		{
			cont._visible = false;
		}
	}

	
	public function show(c: MovieClip):Void 
	{
		cont._x = c._x + 10;
		cont._y = c._y + 30;
		cont._visible = true;
	}


	// create simple button with text on it
	function createButton(name: String, s: String, x: Number, y: Number): MovieClip
	{
		var btn = cont.createEmptyMovieClip(name, 
			cont.getNextHighestDepth());
		var tt = btn.createTextField(name + "Text",
			cont.getNextHighestDepth(),
			x, y, 20, 20);
		var t: TextField = tt;
		t.autoSize = "left";
		t.backgroundColor = 0x111111;
		t.background = true;
		t.setNewTextFormat(textFormatButton);
		t.text = s;

		return btn;
	}
}