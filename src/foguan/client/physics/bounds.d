//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides different templates to create collision shapes.
*/
module client.physics.bounds;

import std.typecons;
import util.vector;
import client.api;

interface CollisionBounds
{
	alias Tuple!(vec3i, "mapPos", vec3, "posCorrection") IntersectMapResult;
	/**
	*	Finds intersection with map. If one of the component less then zero,
	*	bounds doesn't intersect solid part of the map.
	*/
	IntersectMapResult intersectWithMap(vec3 position);
}

class SphereBounds : CollisionBounds
{
	this(double radius)
	{
		mRadius = radius;
	}

	IntersectMapResult intersectWithMap(vec3 position)
	{
		if(findmaxcr(position.x, position.y, position.z, mRadius) < mRadius)
		{
			point3d p0 = point3d(position.x, position.y, position.z); 
			point3d p1;
			lpoint3d hit;

			// up
			p1.x = p0.x; p1.y = p0.y; p1.z = p0.z-mRadius;
			if(!cansee(&p0, &p1, &hit))
			{
				return IntersectMapResult(
					vec3i(hit.x, hit.y, hit.z), 
					vec3(hit.x-p1.x, hit.y-p1.y, hit.z-p1.z));
			}

			// down
			p1.x = p0.x; p1.y = p0.y; p1.z = p0.z+mRadius;
			if(!cansee(&p0, &p1, &hit))
			{
				return IntersectMapResult(
					vec3i(hit.x, hit.y, hit.z), 
					vec3(hit.x-p1.x, hit.y-p1.y, hit.z-p1.z));
			}	

			// left
			p1.x = p0.x+mRadius; p1.y = p0.y; p1.z = p0.z;
			if(!cansee(&p0, &p1, &hit))
			{
				return IntersectMapResult(
					vec3i(hit.x, hit.y, hit.z), 
					vec3(hit.x-p1.x, hit.y-p1.y, hit.z-p1.z));
			}	

			// right
			p1.x = p0.x-mRadius; p1.y = p0.y; p1.z = p0.z;
			if(!cansee(&p0, &p1, &hit))
			{
				return IntersectMapResult(
					vec3i(hit.x, hit.y, hit.z), 
					vec3(hit.x-p1.x, hit.y-p1.y, hit.z-p1.z));
			}	

			// forward
			p1.x = p0.x; p1.y = p0.y+mRadius; p1.z = p0.z;
			if(!cansee(&p0, &p1, &hit))
			{
				return IntersectMapResult(
					vec3i(hit.x, hit.y, hit.z), 
					vec3(hit.x-p1.x, hit.y-p1.y, hit.z-p1.z));
			}	

			// back
			p1.x = p0.x; p1.y = p0.y-mRadius; p1.z = p0.z;
			if(!cansee(&p0, &p1, &hit))
			{
				return IntersectMapResult(
					vec3i(hit.x, hit.y, hit.z), 
					vec3(hit.x-p1.x, hit.y-p1.y, hit.z-p1.z));
			}	
		}
		return IntersectMapResult(vec3i(-1,-1,-1), vec3(0,0,0));
	}

	double radius() @property
	{
		return mRadius;
	}

	void radius(double val) @property
	{
		mRadius = val;
	}

	private
	{
		double mRadius;
	}
}