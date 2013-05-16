//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides wrapper for kv6, vx5sprite native voxlap
*	models.
*/
module client.sprite;

import std.string;
import std.math;
import util.log;
import util.vector;
import util.quaternion;
import util.common;
import client.api;

public
{
	/**
	*	Wrapper for vx5sprite
	*/
	class Sprite
	{
		public
		{
			/**
			*	Loads sprite from resource $(B name) ant
			*	sets it position to $(B pos).
			*/
			this(string name, vec3 pos)
			{
				sprite.voxnum = voxlapGetKv6(toStringz(name));
				if(sprite.voxnum is null)
				{
					writeLog("Failed to load kv6 '"~name~"'!", LOG_ERROR_LEVEL.WARNING);
					return;
				}

				sprite.p.x = pos.x; sprite.p.y = pos.y; sprite.p.z = pos.z;
				sprite.s.x = 1.0; sprite.s.y = 0.0; sprite.s.z = 0.0;
				sprite.h.x = 0.0; sprite.h.y = 1.0; sprite.h.z = 0.0;
				sprite.f.x = 0.0; sprite.f.y = 0.0; sprite.f.z = 1.0;
				sprite.kfatim = 0; sprite.okfatim = 0; sprite.flags = 0;

				// gen mip maps
				auto tempkv6 = sprite.voxnum;
				while(tempkv6 !is null)
					tempkv6=voxlapGenMipKv6(tempkv6);

				if(mAllSprites is null)
				{
					mAllSprites = new Sprite[1];
					mAllSprites[0] = this;
				} else
					mAllSprites ~= this;
			}

			/**
			*	Returns original voxlap structure.
			*/
			vx5sprite* original() @property
			{
				return &sprite;
			}

			bool visible()  @property
			{
				return mVisible;
			}

			void visible(bool val) @property
			{
				mVisible = val;
			}

			vec3 scale() @property
			{
				return vec3(
					cast(float)sqrt(sprite.s.x*sprite.s.x + sprite.s.y*sprite.s.y + sprite.s.z*sprite.s.z),
					cast(float)sqrt(sprite.h.x*sprite.h.x + sprite.h.y*sprite.h.y + sprite.h.z*sprite.h.z),
					cast(float)sqrt(sprite.f.x*sprite.f.x + sprite.f.y*sprite.f.y + sprite.f.z*sprite.f.z)
				);
			}

			void scale(vec3 val) @property
			{
				sprite.s.x *= val.x; sprite.s.y *= val.x; sprite.s.z *= val.x;
				sprite.h.x *= val.y; sprite.h.y *= val.y; sprite.h.z *= val.y;
				sprite.f.x *= val.z; sprite.f.y *= val.z; sprite.f.z *= val.z;
			}

			vec3 position() @property
			{
				return vec3( sprite.p.x, sprite.p.y, sprite.p.z );
			}

			void position(vec3 val) @property
			{
				sprite.p.x = val.x;
				sprite.p.y = val.y;
				sprite.p.z = val.z;
			}

			void rotate(vec3 axis, Radian angle)
			{
				if(angle == 0) return;

				vec3 dir = convertVoxlapVec(sprite.s);
				vec3 left = convertVoxlapVec(sprite.h);
				vec3 up = convertVoxlapVec(sprite.f);

				axis.normalize();
				auto quat = Quaternion.create(axis, angle);
				dir = quat.rotate(dir);
				left = quat.rotate(left);
				up = quat.rotate(up);

				setupVoxlapVec(sprite.s, dir);
				setupVoxlapVec(sprite.h, left);
				setupVoxlapVec(sprite.f, up);	
			}
		}
		private
		{
			vx5sprite sprite;
			bool mVisible = true;

			vec3 convertVoxlapVec(ref point3d p)
			{
				vec3 ret;

				ret.x = p.x; ret.y = p.y; ret.z = p.z;

				return ret;
			}

			void setupVoxlapVec(ref point3d p, vec3 vec)
			{
				p.x = vec.x; p.y = vec.y; p.z = vec.z;
			}
		}
	}

	void freeAllSprites()
	{
		import std.conv;
		writeLog(text(mAllSprites.length));
		closeLog(GENERAL_LOG);
		foreach(sprite; mAllSprites)
		{
			voxlapFreeKv6(sprite.original.voxnum);
		}
	}

	void drawAllSprites()
	{
		foreach(sprite; mAllSprites)
			if(sprite.mVisible)
				voxlapDrawSprite(sprite.original);
	}
}
private
{
	Sprite[] mAllSprites = null;
}