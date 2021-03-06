//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides core game logic handling.
*/
module client.game;

import std.math;
import util.quaternion;
import util.vector;

import client.physics.core;
import client.physics.bounds;
import client.input;
import client.camera;
import client.map;
import client.api;
import client.model;
import client.tank;

enum CAMERA_SPEED = 75.0f;
enum SHIFT_MODIFIER = 3.0f;
enum CAMERA_ANG_SPEED = 0.015f;

enum CELL_SIZE = 50;
enum BORDER_SIZE = 0;

public
{
	void initializeGame()
	{
		//cleanupMap();
		createFlat(50);
		//loadMap("test.map");

		auto tank = new NormalTank(vec3(630, 590, MAXZDIM-75));
		auto btr = new BTRTank(vec3(500, 500, MAXZDIM-70));
		auto heavy = new HeavyTank(vec3(400, 400, MAXZDIM-70));

		auto ball = new TestBall(vec3(650, 650, MAXZDIM-75));
		ball.velocity = vec3(0, 5, -15);
		ball.angvelocity = vec3(0,0,1.0)*0.01;
		ball.setBounds = new SphereBounds(15);
		registerRigidBody(ball);
	}

	void registerGeneralInput()
	{
		addKeyboardListener("cameraControl",
			(code, event)
			{
				if(code == KeyCode.ESC)
				{
					cleanupResources();
					exitGame();
					return false;
				}

				static bool shift = false;
				if(code == KeyCode.LEFT_SHIFT || code == KeyCode.RIGHT_SHIFT)
				{
					if(event == KeyboardEventType.KEY_PRESS)
					{
						mCameraMove *= SHIFT_MODIFIER;
						shift = true;
					}
					else
					{
						if(mCameraMove.x > 0) mCameraMove.x = 1;
						if(mCameraMove.y > 0) mCameraMove.y = 1;
						shift = false;
					}
				}

				float mdf = 1.0f;
				if(shift) mdf *= SHIFT_MODIFIER;

				if(code == KeyCode.CHAR_W || code == KeyCode.ARROW_UP)
				{
					mCameraMove.x = (event == KeyboardEventType.KEY_PRESS ? -mdf : 0);
					return false;
				}
				if(code == KeyCode.CHAR_S || code == KeyCode.ARROW_DOWN)
				{
					mCameraMove.x = (event == KeyboardEventType.KEY_PRESS ? mdf : 0);
					return false;
				}
				if(code == KeyCode.CHAR_A || code == KeyCode.ARROW_LEFT)
				{
					mCameraMove.y = (event == KeyboardEventType.KEY_PRESS ? -mdf : 0);
					return false;
				}	
				if(code == KeyCode.CHAR_D || code == KeyCode.ARROW_RIGHT)
				{
					mCameraMove.y = (event == KeyboardEventType.KEY_PRESS ? mdf : 0);
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

	void cleanupResources()
	{
		unregisterGeneralInput();
		// TODO: Fix crashing while freeing resources
		//freeAllSprites();
	}

}
private
{
	__gshared
	{
		Camera mCamera;
		vec2 mCameraMove;		
	}
}