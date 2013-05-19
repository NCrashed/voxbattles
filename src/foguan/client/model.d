//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module describes a $(B Model) - set of kv6 sprites put together.
*/
module client.model;

import std.typecons;
import util.vector;
import util.quaternion;
import client.sprite;
import client.physics.rigidBody;

/**
*	Tuple describes main part of a $(B Model) which will
*	be base for positioning other parts of the model.
*
*	Parameters:
*	$(B name) - name of the main part,
*	$(B resource) - path to the kv6 sprite.
*
*	See also: $(B SubPartTuple)
*
*	Example:
*	---------
*	MainPartTuple("Body", "kv6/body.kv6", vec3(1, 1, 1));
*	---------
*/
alias Tuple!(string, "name", string, "resource", vec3, "scale") MainPartTuple;

/**
*	Tuple describes sub part of a $(B Model). Extra $(B offset) vector
*	passed as last parameter describes part offset relatively main part.
*
*	Parameters:
*	$(B name) - name of the main part,
*	$(B resource) - path to the kv6 sprite.
*	$(B offset) - offset relatively main model part.
*
*	See also: $(B MainPartTuple)
*
*	Example:
*	--------
*	SubPartTuple("Head", "kv6/head.kv6", vec3(1, 1, 1), vec3(0, 0, 15), ZERO_QUATERNION);
*	--------
*/
alias Tuple!(string, "name", string, "resource", vec3, "scale", vec3, "offset", Quaternion, "rotation") SubPartTuple;

/**
*	Model consist of number of kv6 sprites, each part
*	can be operated seperately.
*
*	Example:
*	--------
*	alias Model!(
*		MainPartTuple("Body", "kv6/body.kv6", vec3(1, 1, 1)),
*		SubPartTuple("Head", "kv6/head.kv6", vec3(1, 1, 1), vec3(0, 0,  15), ZERO_QUATERNION),
*		SubPartTuple("Legs", "kv6/legs.kv6", vec3(1, 1, 1), vec3(0, 0, -15), ZERO_QUATERNION),
*		SubPartTuple("Hands", "kv6/hands.kv6", vec3(1, 1, 1), vec3(0, 0, 3), ZERO_QUATERNION)
*		) MyNPCModel;
*	--------
*/
class Model(Parts...)
	if(
		is(typeof(Parts[0]) == MainPartTuple)  
		&& (Parts.length == 1 || isSubPartsList!(Parts[1..$]))
	) : RigidBody
{
	static assert(isSubPartsUniq(Parts[0].name, Parts[1..$]), "Parts names must be uniq!");
	mixin ConstructRigidBody!(Model!Parts, 10, 0.5, 0.8, 0.01);

	public
	{
		enum MainPart = Parts[0];
		enum SubParts = tuple(Parts[1..$]);

		this(vec3 pos)
		{
			auto mainSprite = new Sprite(MainPart.resource, pos);
			mainSprite.scale(MainPart.scale);
			partsInfo[MainPart.name] = PartInfo(MainPart.resource, MainPart.scale, ZVEC, ZERO_QUATERNION, mainSprite);

			foreach(i, tp; SubParts)
			{	
				auto sprite = new Sprite(tp[1], pos + tp[3]); // explicity naming doesn't work! Bug?
				sprite.scale(tp.scale);
				sprite.rotate(tp.rotation);
				partsInfo[tp.name] = PartInfo(tp[1], tp[2], tp[3], tp[4], sprite);			
			}
		}

		void initialize()
		{
			position = partsInfo[MainPart.name].sprite.position;
			rotation = partsInfo[MainPart.name].sprite.rotation;
		}

		void synchronizePositions()
		{
			auto dvec = position - partsInfo[MainPart.name].sprite.position;
			foreach(info; partsInfo)
			{
				info.sprite.position = info.sprite.position + dvec;
			}
		}
	}
	protected
	{
		struct PartInfo
		{
			string resource;
			vec3 scale;
			vec3 offset;
			Quaternion rotation;
			Sprite sprite;
		}

		PartInfo[string] partsInfo;
	}
}

/**
*	Checks if $(B list) is list of $(B SubPartTuple)s.
*/
private template isSubPartsList(list...)
{
	static if(list.length == 0)
	{
		enum isSubPartsList = true;
	} else
	{
		enum isSubPartsList = is(typeof(list[0]) == SubPartTuple) && isSubPartsList!(list[1..$]);
	}
}
unittest
{
	static assert(isSubPartsList!(SubPartTuple("a", "b", ZUNIT, ZUNIT, ZERO_QUATERNION), SubPartTuple("b", "a", ZUNIT, YUNIT, ZERO_QUATERNION)));
}

/**
*	Checks name conflicts in $(B SubPartTuple) list.
*	Returns $(B false), if finds equal names.
*/
private bool isSubPartsUniq(TupleList...)(string mainName, TupleList list)
{
	foreach(i, tp1; list)
	{
		if(tp1.name == mainName)
		{
			return false;
		} else
		{
			foreach(j, tp2; list)
			{
				if(i != j && tp1.name == tp2.name)
					return false;
			}			
		}
	}

	return true;
}

unittest
{
	alias Model!(
		MainPartTuple("Body", "kv6/body.kv6", vec3(1, 1, 1)),
		SubPartTuple("Head", "kv6/head.kv6", vec3(1, 1, 1), vec3(0, 0,  15), ZERO_QUATERNION),
		SubPartTuple("Legs", "kv6/legs.kv6", vec3(1, 1, 1), vec3(0, 0, -15), ZERO_QUATERNION),
		SubPartTuple("Hands", "kv6/hands.kv6", vec3(1, 1, 1), vec3(0, 0, 3), ZERO_QUATERNION)
		) MyNPCModel;
}