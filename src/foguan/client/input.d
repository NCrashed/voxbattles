//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides abstraction layer for user keyboard and mouse input. You can register a number
*	of listeners to input events. When keyboard or mouse event appears (Voxlap generates them), all
*	specified listeners will be executed.
*
*	TODO: 
*	1. Detect mouse wheel. (Something strange with wheel detection)
*/
module client.input;

import std.conv;

public
{
	enum KeyCode: ubyte
	{
		ESC 		= 1,
		F1 			= 59,
		F2 			= 60,
		F3 			= 61,
		F4 			= 62,
		F5 			= 63,
		F6 			= 64,
		F7 			= 65,
		F8 			= 66,
		F9 			= 67,
		F10 		= 68,
		F11 		= 87,
		F12 		= 88,
		TILDA 		= 41,
		DIGIT_1 	= 2,
		DIGIT_2 	= 3,
		DIGIT_3 	= 4,
		DIGIT_4 	= 5,
		DIGIT_5 	= 6,
		DIGIT_6 	= 7,
		DIGIT_7 	= 8,
		DIGIT_8 	= 9,
		DIGIT_9 	= 10,
		DIGIT_0 	= 11,
		MINUS 		= 12,
		PLUS 		= 13,
		BACKSPACE 	= 14,
		ENTER 		= 28,
		CAPSLOCK 	= 58,
		TAB 		= 15,
		LEFT_SHIFT 	= 42,
		LEFT_CONTROL = 29,
		LEFT_ALT 	= 56,
		RIGHT_SHIFT = 54,
		RIGHT_ALT 	= 184,
		RIGHT_CONTROL = 157,
		WIN_KEY 	= 219,
		CONTEX_MENU = 221,
		CHAR_Q 		= 16,
		CHAR_W 		= 17,
		CHAR_E 		= 18,
		CHAR_R 		= 19,
		CHAR_T 		= 20,
		CHAR_Y 		= 21,
		CHAR_U 		= 22,
		CHAR_I 		= 23,
		CHAR_O 		= 24,
		CHAR_P 		= 25,
		OPEN_SQUARE_BRACKET = 26,
		CLOSE_SQUARE_BRACKET = 27,
		CHAR_A 		= 30,
		CHAR_S 		= 31,
		CHAR_D 		= 32,
		CHAR_F 		= 33,
		CHAR_G 		= 34,
		CHAR_H 		= 35,
		CHAR_J 		= 36,
		CHAR_K 		= 37,
		CHAR_L 		= 38,
		SEMICOLON 	= 39,
		COMMA 		= 40,
		CHAR_Z 		= 44,
		CHAR_X 		= 45,
		CHAR_C 		= 46,
		CHAR_V 		= 47,
		CHAR_B 		= 48,
		CHAR_N 		= 49,
		CHAR_M 		= 50,
		LESS 		= 51,
		GREATER 	= 52,
		SLASH 		= 53,
		BACK_SLASH 	= 43,
		SPACE 		= 57,
		PRINT_SCREEN = 183,
		SCROLL_LOCK = 70,
		PAUSE 		= 197,
		HOME 		= 199,
		END 		= 207,
		INSERT 		= 210,
		DELETE 		= 211,
		PAGE_UP 	= 201,
		PAGE_DOWN 	= 209,
		ARROW_LEFT 	= 203,
		ARROW_DOWN 	= 208,
		ARROW_RIGHT = 205,
		ARROW_UP 	= 200,
		NUM_LOCK 	= 69,
		KP_SLASH 	= 181,
		KP_STAR 	= 55,
		KP_MINUS	= 74,
		KP_PLUS 	= 78,
		KP_ENTER 	= 156,
		KP_DOT 		= 83,
		KP_0 		= 82,
		KP_1 		= 79,
		KP_2 		= 80,
		KP_3 		= 81,
		KP_4 		= 75,
		KP_5 		= 76,
		KP_6 		= 77,
		KP_7 		= 71,
		KP_8 		= 72,
		KP_9 		= 73,
	}

	enum KeyboardEventType
	{
		KEY_PRESS,
		KEY_RELEASE
	}

	enum MouseEventType
	{
		LEFT_BUTTON_PRESS,
		LEFT_BUTTON_RELEASE,
		RIGHT_BUTTON_PRESS,
		RIGHT_BUTTON_RELEASE,
		MIDLE_BUTTON_PRESS,
		MIDLE_BUTTON_RELEASE,		
		//WHEEL_UP,
		//WHEEL_DOWN
	}

	alias bool delegate(ubyte code, KeyboardEventType event) KeyboardEventListener;
	alias bool delegate(float mx, float my, float mz) MouseMoveEventListener;
	alias bool delegate(float mx, float my, float mz, MouseEventType event) MouseEventListener;

	/**
	*	Thrown by $(B addKeyboardListener) when $(B forceReplace) is false and
	*	$(B id) conflict detected.
	*/
	class KeyboardListenerConflict : Exception
	{
		this(string id)
		{
			super(text("Detected keyboard listeners conflict with id: ", id));
			this.id = id;
		}

		string id;
	}

	class MouseMoveListenerConflict : Exception
	{
		this(string id)
		{
			super(text("Detected mouse move listeners conflict with id: ", id));
			this.id = id;
		}

		string id;
	}

	class MouseListenerConflict : Exception
	{
		this(string id)
		{
			super(text("Detected mouse listeners conflict with id: ", id));
			this.id = id;
		}

		string id;
	}		
}
public
{
	/**
	*	Checks keyboard events from voxlap window layer. Buffer $(B buff)
	*	must have length equal to 256.
	*
	*	Warning: You should not use this function in game logic code. It is executed
	*	from voxlap.
	*/
	void updateKeyboardBuffer(ubyte* buff) @trusted
	{
		for(ubyte i = 0; i < 255; i++)
		{
			if(mKeyboardStatus[i] != buff[i])
			{
				if(buff[i] == 1)
				{
					foreach(dlg; keyboardListeners)
						if(!dlg(i, KeyboardEventType.KEY_PRESS))
							break;
				} 
				else
				{
					foreach(dlg; keyboardListeners)
						if(!dlg(i, KeyboardEventType.KEY_RELEASE))
							break;
				}
				mKeyboardStatus[i] = buff[i];
			}
		}
	}

	/**
	*	Checks mouse events from voxlap window layer.
	*
	*	Warning: You should not use this function in game logic code. It is executed
	*	from voxlap.
	*/
	void updateMouseBuffer(float mx, float my, float mz, int state)
	{
		if(mx != mMouseX || my != mMouseY || mz != mMouseZ)
		{
			foreach(dlg; mouseMoveListeners)
				if(!dlg(mx, my, mz))
					break;

			mMouseX = mx;
			mMouseY = my;
			mMouseZ = mz;
		}

		if(state != mMouseStatus)
		{
			if(state&1 && !(mMouseStatus&1))
			{
				foreach(dlg; mouseListeners)
					if(!dlg(mx, my, mz, MouseEventType.LEFT_BUTTON_PRESS))
						break;				
			} else if(!(state&1) && mMouseStatus&1)
			{
				foreach(dlg; mouseListeners)
					if(!dlg(mx, my, mz, MouseEventType.LEFT_BUTTON_RELEASE))
						break;						
			}

			if(state&2 && !(mMouseStatus&2))
			{
				foreach(dlg; mouseListeners)
					if(!dlg(mx, my, mz, MouseEventType.RIGHT_BUTTON_PRESS))
						break;				
			} else if(!(state&2) && mMouseStatus&2)
			{
				foreach(dlg; mouseListeners)
					if(!dlg(mx, my, mz, MouseEventType.RIGHT_BUTTON_RELEASE))
						break;						
			}

			if(state&4 && !(mMouseStatus&4))
			{
				foreach(dlg; mouseListeners)
					if(!dlg(mx, my, mz, MouseEventType.MIDLE_BUTTON_PRESS))
						break;
			} else if(!(state&4) && mMouseStatus&4)
			{
				foreach(dlg; mouseListeners)
					if(!dlg(mx, my, mz, MouseEventType.MIDLE_BUTTON_RELEASE))
						break;				
			}
			mMouseStatus = state;
		}
	}

	/**
	*	Adds keyboard press/release $(B listener). If $(B listener) returns false, event will not pass
	*	to other listeners. If flag $(B forceReplace) is false and there is another listener with 
	*	specified $(B id), function will throw $(B KeyboardListenerConflict) exception.
	*
	*	Example:
	*	---------
	*	addKeyboardListener("testId", 
	*		(code, event) 
	*		{
	*			if(code == KeyCode.ESC)
	*			{
	*				// action, ex. quit program
	*				return false;
	*			}
	*			return true;
	*		});
	*	---------
	*/
	void addKeyboardListener(string id, KeyboardEventListener listener, bool forceReplace = false)
	{
		if(!forceReplace && id in keyboardListeners)
			throw new KeyboardListenerConflict(id);

		keyboardListeners[id] = listener;
	}
	unittest
	{
		addKeyboardListener("testId", 
			(code, event) 
			{
				if(code == KeyCode.ESC)
				{
					// action, ex. quit program
					return false;
				}
				return true;
			});

		assert("testId" in keyboardListeners);
		keyboardListeners.remove("testId");
	}

	/**
	*	Removes keyboard listner registered by $(B addKeyboardListener) with $(B id). If id
	*	is not valid, does nothing.
	*
	*	Example:
	*	------------
	*	addKeyboardListener("testId", (code, event) { return true; });
	*	removeKeyboardListener("testId");
	*	------------
	*/
	void removeKeyboardListener(string id)
	{
		if(id in keyboardListeners)
			keyboardListeners.remove(id);
	}
	unittest
	{
		addKeyboardListener("testId", (code, event) { return true; });
		removeKeyboardListener("testId");
		assert("testId" !in keyboardListeners);
	}

	/**
	*	Adds mouse move $(B listener). If $(B listener) returns false, event will not pass
	*	to other listeners. If flag $(B forceReplace) is false and there is another listener with 
	*	specified $(B id), function will throw $(B MouseMoveListenerConflict) exception.
	*
	*	Example:
	*	---------
	*	addMouseMoveListener("testId", 
	*		(mx, my, mz) 
	*		{
	*			// some actions
	*			return true;
	*		});
	*	---------
	*/
	void addMouseMoveListener(string id, MouseMoveEventListener listener, bool forceReplace = false)
	{
		if(!forceReplace && id in mouseMoveListeners)
			throw new MouseMoveListenerConflict(id);

		mouseMoveListeners[id] = listener;
	}
	unittest
	{
		addMouseMoveListener("testId", 
			(mx, my, mz) 
			{
				// some actions
				return true;
			});

		assert("testId" in mouseMoveListeners);
		mouseMoveListeners.remove("testId");
	}

	/**
	*	Removes mouse move listner registered by $(B addMouseMoveListener) with $(B id). If id
	*	is not valid, does nothing.
	*
	*	Example:
	*	------------
	*	addMouseMoveListener("testId", (mx, my, mz) { return true; });
	*	removeMouseMoveListener("testId");
	*	------------
	*/
	void removeMouseMoveListener(string id)
	{
		if(id in mouseMoveListeners)
			mouseMoveListeners.remove(id);
	}
	unittest
	{
		addMouseMoveListener("testId", (mx, my, mz) { return true; });
		removeMouseMoveListener("testId");
		assert("testId" !in mouseMoveListeners);
	}

	/**
	*	Adds mouse $(B listener). If $(B listener) returns false, event will not pass
	*	to other listeners. If flag $(B forceReplace) is false and there is another listener with 
	*	specified $(B id), function will throw $(B MouseListenerConflict) exception.
	*
	*	Example:
	*	---------
	*	addMouseListener("testId", 
	*		(mx, my, mz, event) 
	*		{
	*			if(event == MouseEventType.LEFT_BUTTON_PRESS)
	*			{
	*				// some code
	*				return false;
	*			}
	*			return true;
	*		});
	*	---------
	*/
	void addMouseListener(string id, MouseEventListener listener, bool forceReplace = false)
	{
		if(!forceReplace && id in mouseListeners)
			throw new MouseListenerConflict(id);

		mouseListeners[id] = listener;
	}
	unittest
	{
		addMouseListener("testId", 
			(mx, my, mz, event) 
			{
				if(event == MouseEventType.LEFT_BUTTON_PRESS)
				{
					// some code
					return false;
				}
				return true;
			});

		assert("testId" in mouseListeners);
		mouseListeners.remove("testId");
	}

	/**
	*	Removes mouse listner registered by $(B addMouseListener) with $(B id). If id
	*	is not valid, does nothing.
	*
	*	Example:
	*	------------
	*	addMouseListener("testId", (mx, my, mz, event) { return true; });
	*	removeMouseListener("testId");
	*	------------
	*/
	void removeMouseListener(string id)
	{
		if(id in mouseListeners)
			mouseListeners.remove(id);
	}
	unittest
	{
		addMouseListener("testId", (mx, my, mz, event) { return true; });
		removeMouseListener("testId");
		assert("testId" !in mouseListeners);
	}		
}
private
{
	__gshared
	{
		ubyte[256] mKeyboardStatus;
		int mMouseStatus;
		float mMouseX, mMouseY, mMouseZ;

		KeyboardEventListener[string] keyboardListeners;
		MouseMoveEventListener[string] mouseMoveListeners;
		MouseEventListener[string] mouseListeners;
	}
}