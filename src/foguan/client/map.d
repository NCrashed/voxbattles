//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides functions to work with game map.
*/
module client.map;

import std.random;
import util.vector;
import util.serialization.serializer;
import client.api;
import client.game;
import client.sprite;

public
{
	enum MAP_AIR_ID = 0;
	enum MAP_BRICK_ID = 1;
	enum MAP_CONCRETE_ID = 2;
	enum MAP_HOLE_ID = 3;

	/**
	*	Cleans up whole map. Called before generating new map.
	*/
	void cleanupMap()
	{
		static lpoint3d p0 = lpoint3d(0,0,0);
		static lpoint3d p1 = lpoint3d(VSID, VSID, MAXZDIM);
		voxlapSetRect(&p0, &p1, -1);
	}

	/**
	*	Generates flat map with earth level at $(B zlevel).
	*/
	void createFlat(int zlevel)
	{
		cleanupMap();

		static lpoint3d p0 = lpoint3d(0, 0, MAXZDIM);
		static lpoint3d p1;
		p1 = lpoint3d(VSID, VSID, MAXZDIM - zlevel);
		voxlapSetColorFunc(&cellColorFunc, 1000);
		voxlapSetRect(&p0, &p1, 1);

		mMapZLevel = zlevel;
	}

	/**
	*	Generates brick wall at $(B where). $(B where)
	*	represents cell number in flat celled map.
	*/
	void placeBrick(vec2ui where)
	{
		static scalevec = vec3(0.5, 0.4, 0.5);
		if(brickWallUp is null)
		{
			brickWallUp = new Sprite("kv6\\brickwall_up.kv6", vec3(0, 0, 0));
			brickWallUp.scale(scalevec);
			brickWallUp.visible = false;
		}
		if(brickWallNorth is null)
		{
			brickWallNorth = new Sprite("kv6\\brickwall_north.kv6", vec3(0, 0, 0));
			brickWallNorth.scale(scalevec);
			brickWallNorth.visible = false;			
		}
		if(brickWallSouth is null)
		{
			brickWallSouth = new Sprite("kv6\\brickwall_south.kv6", vec3(0, 0, 0));
			brickWallSouth.scale(scalevec);
			brickWallSouth.visible = false;			
		}
		if(brickWallWest is null)
		{
			brickWallWest = new Sprite("kv6\\brickwall_west.kv6", vec3(0, 0, 0));
			brickWallWest.scale(scalevec);
			brickWallWest.visible = false;			
		}
		if(brickWallEast is null)
		{
			brickWallEast = new Sprite("kv6\\brickwall_east.kv6", vec3(0, 0, 0));
			brickWallEast.scale(scalevec);
			brickWallEast.visible = false;			
		}

		// main cube
		enum BASE_CUBE_MARGIN = 5;
		lpoint3d p0 = lpoint3d(where.x*CELL_SIZE+BASE_CUBE_MARGIN, where.y*CELL_SIZE+BASE_CUBE_MARGIN, MAXZDIM-mMapZLevel);
		lpoint3d p1 = lpoint3d(where.x*CELL_SIZE+CELL_SIZE-BASE_CUBE_MARGIN, where.y*CELL_SIZE+CELL_SIZE-BASE_CUBE_MARGIN, MAXZDIM-mMapZLevel-CELL_SIZE);
		voxlapSetColorFunc(jitcolfunc, getRGB(150, 150, 150));
		voxlapSetRect(&p0, &p1, 1);

		/*brickWallUp.position = vec3(where.x*CELL_SIZE+CELL_SIZE/2, where.y*CELL_SIZE+CELL_SIZE/2, MAXZDIM-mMapZLevel-CELL_SIZE/2);
		voxlapSetColorFunc(kv6colfunc, 1);
		voxlapSetKv6(brickWallUp.original, 1);*/

		brickWallNorth.position = vec3(where.x*CELL_SIZE+CELL_SIZE/2, where.y*CELL_SIZE+CELL_SIZE/2, MAXZDIM-mMapZLevel-CELL_SIZE/2);
		voxlapSetColorFunc(kv6colfunc, 1);
		voxlapSetKv6(brickWallNorth.original, 1);

		brickWallSouth.position = vec3(where.x*CELL_SIZE+CELL_SIZE/2, where.y*CELL_SIZE+CELL_SIZE/2, MAXZDIM-mMapZLevel-CELL_SIZE/2);
		voxlapSetColorFunc(kv6colfunc, 1);
		voxlapSetKv6(brickWallSouth.original, 1);

		brickWallWest.position = vec3(where.x*CELL_SIZE+CELL_SIZE/2-3, where.y*CELL_SIZE+CELL_SIZE/2, MAXZDIM-mMapZLevel-CELL_SIZE/2);
		voxlapSetColorFunc(kv6colfunc, 1);
		voxlapSetKv6(brickWallWest.original, 1);

		brickWallEast.position = vec3(where.x*CELL_SIZE+CELL_SIZE/2+3, where.y*CELL_SIZE+CELL_SIZE/2, MAXZDIM-mMapZLevel-CELL_SIZE/2);
		voxlapSetColorFunc(kv6colfunc, 1);
		voxlapSetKv6(brickWallEast.original, 1);
	}

	/**
	*	Creates example brick map and saves it to $(B filename).
	*/
	void genExampleBrickMap(string filename)
	{
		SavedMap map = SavedMap(19, 19);
		foreach(ref row; map.rows)
			foreach(ref block; row.blocks)
				if(uniform!"[]"(0.0, 1.0) < 0.3)
					block = MAP_BRICK_ID;
				else
					block = MAP_AIR_ID;

		try
		{
			serialize!GendocArchive(map, filename, "Map");	
		} catch(Exception e)
		{
			throw new Exception("Failed to save map "~filename~". Reason: "~e.msg);
		}
		
	}

	/**
	*	Loads map from $(B filename), example map you can create
	*	with $(B genExampleBrickMap).
	*/
	void loadMap(string filename)
	{
		SavedMap map;
		try
		{
			map = deserialize!(GendocArchive, SavedMap)(filename, "Map");
		} catch(Exception e)
		{
			throw new Exception("Failed to load map "~filename~". Reason: "~e.msg);
		}

		foreach(j, ref row; map.rows)
			foreach(i, block; row.blocks)
				if(block == MAP_BRICK_ID)
					placeBrick(vec2ui(i,j));
	}
}
private
{
	Sprite brickWallUp, brickWallNorth, brickWallSouth, brickWallWest, brickWallEast;
	int mMapZLevel = 0;

	struct SavedMap
	{
		struct Row
		{
			uint[] blocks;
		}
		Row[] rows;

		this(size_t xsize, size_t ysize)
		{
			rows = new Row[ysize];
			foreach(ref row; rows)
				row.blocks = new uint[xsize];
		}
	}
}
private
{
	static byte[CELL_SIZE][CELL_SIZE] randomDiffs = getRandomDiffs();
	 
	uint get_random(int min, int max, ref uint m_w, ref uint m_z)
	{
	    m_z = 36969 * (m_z & 65535) + (m_z >> 16);
	    m_w = 18000 * (m_w & 65535) + (m_w >> 16);
	    return cast(int)(((m_z << 16) + m_w)/cast(float)uint.max * max) + min;  /* 32-bit result */
	}

	static byte[CELL_SIZE][CELL_SIZE] getRandomDiffs()
	{
		uint m_w = 45435346;
		uint m_z = 26532457;		
		byte[CELL_SIZE][CELL_SIZE] buff;
		foreach(ref arr; buff)
			foreach(ref val; arr)
				val = cast(byte)get_random(-7,18, m_w, m_z);
		return buff;		
	}

	int getRGB(ubyte r, ubyte g, ubyte b)
	{
		return (r << 16) + (g << 8) + b + 0x80000000;
	}

	extern(C) int cellColorFunc(lpoint3d* p)
	{
		int sx = p.x % CELL_SIZE;
		int sy = p.y % CELL_SIZE;

		if(sx >= BORDER_SIZE && 
		   sy >= BORDER_SIZE) //&& 
		   //sx < CELL_SIZE-BORDER_SIZE && 
		   //sy < CELL_SIZE-BORDER_SIZE)
		{
			return getRGB(
					cast(ubyte)0u, 
					cast(ubyte)(84u+randomDiffs[sx][sy]), 
					cast(ubyte)(7u+randomDiffs[sx][sy]));
		}
		return getRGB(45, 45, 45);
	}
}