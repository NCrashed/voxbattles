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
import client.physics.rigidBody;
import client.api;

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
		foreach(rbody; bodies)
		{
			//calc forces

			// collisions with map
			vec3 mapCollCorrection = vec3(0,0,0);
			bool mapCorrection = false;
			if(rbody.bounds !is null)
			{
				auto hitres = rbody.bounds.intersectWithMap(rbody.position);
				if(hitres.mapPos != vec3i(-1, -1, -1))
				{
					point3d normal;
					estnorm(hitres.mapPos.x, hitres.mapPos.y, hitres.mapPos.z, &normal);
					vec3 n = vec3(normal.x, normal.y, normal.z);

					rbody.velocity = rbody.velocity - (1+rbody.elastic) * rbody.velocity.project(n);

					mapCollCorrection = hitres.posCorrection.normalized;
					mapCorrection = true;
					rbody.position = rbody.position + hitres.posCorrection;
				}
			}

			//update position
			rbody.velocity = rbody.velocity + rbody.force * (dt/rbody.mass) + rbody.gravity * dt;
			auto temp = rbody.velocity * dt;
			rbody.position = rbody.position + temp;

			//if(mapCorrection)
			//	rbody.position = rbody.position + temp.project(mapCollCorrection);
				

			rbody.force = vec3(0, 0, 0);
			rbody.synchronizePositions();
		}
	}
}
private
{
	DList!RigidBody bodies;
}