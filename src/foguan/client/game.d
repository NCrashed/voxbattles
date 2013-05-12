//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides core game logic handling.
*/
module client.game;

import util.vector;
import client.input;
import client.camera;

enum CAMERA_SPEED = 75.0f;
enum CAMERA_ANG_SPEED = 0.015f;

public
{
	void registerGeneralInput()
	{
		addKeyboardListener("cameraControl",
			(code, event)
			{
				if(code == KeyCode.CHAR_W || code == KeyCode.ARROW_UP)
				{
					mCameraMove.x = mCameraMove.x + (event == KeyboardEventType.KEY_PRESS ? -1 : 1);
					return false;
				}
				if(code == KeyCode.CHAR_S || code == KeyCode.ARROW_DOWN)
				{
					mCameraMove.x = mCameraMove.x + (event == KeyboardEventType.KEY_PRESS ? 1 : -1);
					return false;
				}
				if(code == KeyCode.CHAR_A || code == KeyCode.ARROW_LEFT)
				{
					mCameraMove.y = mCameraMove.y + (event == KeyboardEventType.KEY_PRESS ? -1 : 1);
					return false;
				}	
				if(code == KeyCode.CHAR_D || code == KeyCode.ARROW_RIGHT)
				{
					mCameraMove.y = mCameraMove.y + (event == KeyboardEventType.KEY_PRESS ? 1 : -1);
					return false;
				}					
				return true;
			});

		addMouseMoveListener("cameraControl",
			(mx, my, mz)
			{
				if(mx != 0)
				{
					with(gameCamera)
						rotate(ZUNIT, CAMERA_ANG_SPEED*mx);
				}
				if(my != 0)
				{
					with(gameCamera)
						rotate(left, CAMERA_ANG_SPEED*my);
				}

				return true;
			});
	}

	void unregisterGeneralInput()
	{
		removeKeyboardListener("cameraControl");
		removeMouseMoveListener("cameraControl");
	}	

	/**
	*	Static constructors behaive wreid in dlls, thats
	*	why i've forced explicit camera creation.
	*/
	void createCamera()
	{
		mCamera = new Camera();
	}

	/**
	*	Returns main game camera.
	*/
	Camera gameCamera() @property
	{
		return mCamera;
	}

	void updateGameCamera(double dt)
	{
		with(gameCamera)
		{
			if(mCameraMove.x != 0)
				moveRel(mCameraMove.x*CAMERA_SPEED*dt*direction);
			if(mCameraMove.y != 0)
				moveRel(mCameraMove.y*CAMERA_SPEED*dt*left);

			update(dt);
		}
	} 
}
private
{
	__gshared
	{
		Camera mCamera;
		vec2i mCameraMove;		
	}
}