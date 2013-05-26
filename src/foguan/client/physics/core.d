//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides base update cycles for physic objects.
*/
module client.physics.core;

import std.algorithm;
import std.range;
import std.container;
import util.vector;
import util.quaternion;
import client.physics.rigidBody;
import client.api;

import util.log, std.conv;
enum CRASH_LOG = "CrashReport.log";

public
{
	void registerRigidBody(RigidBody rigid)
	{
		rigid.initialize();
		bodies.stableInsertFront(rigid);
	}

	void unregisterRigidBody(RigidBody rigid)
	{
		bodies.linearRemove(find(bodies[], rigid).take(1));
	}

	void physicUpdate(double dt)
	{
		try
		{
			foreach(rbody; bodies)
			{
				//calc forces

				// collisions with map
				if(rbody.bounds !is null)
				{
					auto hitres = rbody.bounds.intersectWithMap(rbody.position);
					while(hitres.mapPos != vec3i(-1, -1, -1))
					{
						point3d normal;
						estnorm(hitres.mapPos.x, hitres.mapPos.y, hitres.mapPos.z, &normal);
						vec3 n = vec3(normal.x, normal.y, normal.z);

						rbody.velocity = rbody.velocity - (1+rbody.elastic) * rbody.velocity.project(n);
						rbody.position = rbody.position + hitres.posCorrection.project(n);

						//friction

						hitres = rbody.bounds.intersectWithMap(rbody.position);
					}
				}

				//update position
				rbody.velocity = rbody.velocity + rbody.force * (dt/rbody.mass) + rbody.gravity * dt;
				rbody.position = rbody.position + rbody.velocity * dt;
					
				//update rotation
				//rbody.angvelocity = rbody.angvelocity + rbody.inertiaInversed * rbody.angforce * dt;
				rbody.rotation = rbody.rotation*cast(Quaternion)rbody.angvelocity;

				rbody.force 	= ZVEC;
				rbody.angforce  = ZVEC;
				rbody.synchronizePositions();
			}
		} catch(Exception e)
		{
			writeLog(text(e.msg), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			writeLog(text(e.info), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
		}
	}
}
private
{
	DList!RigidBody bodies;
}