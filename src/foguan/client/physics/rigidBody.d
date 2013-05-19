//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module provides mixins to create rigid body for physics engine.
*/
module client.physics.rigidBody;

import std.traits;
import util.vector;
import util.quaternion;
import util.matrix;
import client.physics.bounds;

/**
*	Interface used by core to store bodies.
*/
interface RigidBody
{
	vec3 		position() 					@property;
	void 		position(vec3 val) 			@property;

	Quaternion 	rotation() 					@property;
	void		rotation(Quaternion val) 	@property;

	vec3		velocity() 					@property;
	void		velocity(vec3 val) 			@property;

	Quaternion 	angvelocity() 				@property;
	void		angvelocity(Quaternion val) @property;

	vec3		force() 					@property;
	void		force(vec3 val)				@property;

	Quaternion 	angforce()					@property;
	void		angforce(Quaternion val)	@property;

	vec3		gravity()				@property;
	void		gravity(vec3 val)		@property;

	double		mass()			 		@property;
	void		mass(double val) 		@property;

	Matrix!3	inertia()				@property;
	void		inertia(Matrix!3 val)	@property;

	double		elastic()				@property;
	void		elastic(double val)		@property;

	double		friction()				@property;
	void		friction(double val)	@property;

	double		resilient()				@property;
	void		resilient(double val)	@property;

	/**
	*	Inits collision bounds for body.
	*/
	void setBounds(CollisionBounds);

	CollisionBounds bounds() @property;

	/**
	*	Called when registering in physics sub-system.
	*	Usually some position synchronization code is put here.
	*/
	void initialize();

	/**
	*	Most of objects have their own internally position representation.
	*	This method assumes synchronization between physics position and internal position.
	*	Called after each physics update cycle.
	*/
	void synchronizePositions();
}

/**
*	Easy implementation for RigidBody.
*/
mixin template ConstructRigidBody(
	BaseType,
	double initMass, 
	double initElastic,
	double initFriction,
	double initResilient)
{
	static assert(is(BaseType : RigidBody), BaseType.stringof~" must be implements interface RigidBody to mixin ConstructRigidBody!");

	import util.vector;
	import util.quaternion;
	import util.matrix;
	import client.physics.constants;
	import client.physics.bounds;

	// to encapsulate names
	template RigidBodyMembersSpace()
	{
		vec3 		position;
		Quaternion 	rotation;

		vec3		velocity;
		Quaternion 	angvelocity;

		vec3		force;
		Quaternion 	angforce;

		vec3		gravity   = G_VECTOR;

		double		mass 	  = initMass;
		Matrix!3	inertia;

		double		elastic   = initElastic;
		double		friction  = initFriction;
		double		resilient = initResilient;

		CollisionBounds bounds;
	}
	alias RigidBodyMembersSpace!() RigidBodyMembers;
	
	void setBounds(CollisionBounds bounds)
	{
		RigidBodyMembers.bounds = bounds;
	}

	CollisionBounds bounds() @property
	{
		return RigidBodyMembers.bounds;
	}

	// Down some boilerplate code
	vec3 position() @property
	{
		return RigidBodyMembers.position;
	}

	void position(vec3 val) @property
	{
		RigidBodyMembers.position = val;
	}

	Quaternion rotation() @property
	{
		return RigidBodyMembers.rotation;
	}
	void rotation(Quaternion val) @property
	{
		RigidBodyMembers.rotation = val;
	}

	vec3 velocity() @property
	{
		return RigidBodyMembers.velocity;
	}
	void velocity(vec3 val) @property
	{
		RigidBodyMembers.velocity = val;
	}

	Quaternion angvelocity() @property
	{
		return RigidBodyMembers.angvelocity;
	}
	void angvelocity(Quaternion val) @property
	{
		RigidBodyMembers.angvelocity = val;
	}

	vec3 force() @property
	{
		return RigidBodyMembers.force;
	}
	void force(vec3 val) @property
	{
		RigidBodyMembers.force = val;
	}

	Quaternion angforce() @property
	{
		return RigidBodyMembers.angforce;
	}
	void angforce(Quaternion val) @property
	{
		RigidBodyMembers.angforce = val;
	}

	vec3 gravity() @property
	{
		return RigidBodyMembers.gravity;
	}
	void gravity(vec3 val) @property
	{
		RigidBodyMembers.gravity = val;
	}

	double mass() @property
	{
		return RigidBodyMembers.mass;
	}
	void mass(double val) @property
	{
		RigidBodyMembers.mass = val;
	}

	Matrix!3 inertia() @property
	{
		return RigidBodyMembers.inertia;
	}
	void inertia(Matrix!3 val) @property
	{
		RigidBodyMembers.inertia = val;
	}

	double elastic() @property
	{
		return RigidBodyMembers.elastic;
	}
	void elastic(double val) @property
	{
		RigidBodyMembers.elastic = val;
	}

	double friction() @property
	{
		return RigidBodyMembers.friction;
	}
	void friction(double val) @property
	{
		RigidBodyMembers.friction = val;
	}

	double resilient()	@property
	{
		return RigidBodyMembers.resilient;
	}
	void resilient(double val) @property
	{
		RigidBodyMembers.resilient = val;
	}
}