//          Copyright Gushcha Anton 2013.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)
// Written in D programming language
/**
*	Module describes a tank models.
*/
module client.tank;

import std.math;
import util.quaternion;
import util.vector;
import client.model;

alias Model!(
			MainPartTuple("Body", "kv6/t55_body.kv6", vec3(1, 1, 1)),
			SubPartTuple("Tower", "kv6/t55_tower.kv6", vec3(1, 1, 1), vec3(0,10,-14), Quaternion.create(ZUNIT, -PI/2.0)),
			SubPartTuple("WheelLeft1","kv6/t55_wheel.kv6", vec3(0.7,0.7,0.7), vec3(-18,23,1), Quaternion.create(ZUNIT, -PI/2.0)),
			SubPartTuple("WheelLeft2","kv6/t55_wheel.kv6", vec3(0.7,0.7,0.7), vec3(-18,10,1), Quaternion.create(ZUNIT, -PI/2.0)),
			SubPartTuple("WheelLeft3","kv6/t55_wheel.kv6", vec3(0.7,0.7,0.7), vec3(-18,-3,1), Quaternion.create(ZUNIT, -PI/2.0)),
			SubPartTuple("WheelRight1","kv6/t55_wheel.kv6", vec3(0.7,0.7,0.7), vec3(18,23,1), Quaternion.create(ZUNIT, PI/2.0)),
			SubPartTuple("WheelRight2","kv6/t55_wheel.kv6", vec3(0.7,0.7,0.7), vec3(18,10,1), Quaternion.create(ZUNIT, PI/2.0)),
			SubPartTuple("WheelRight3","kv6/t55_wheel.kv6", vec3(0.7,0.7,0.7), vec3(18,-3,1), Quaternion.create(ZUNIT, PI/2.0))
		) NormalTank;
		
alias Model!(
			MainPartTuple("Body", "kv6/btr2.kv6", vec3(0.7, 0.7, 0.7)),
			SubPartTuple("Tower", "kv6/btr2Tower.kv6", vec3(1, 1, 1), vec3(4,10,-18), Quaternion.create(ZUNIT, PI)),
			SubPartTuple("WheelLeft1","kv6/btr2Wheel.kv6",  vec3(1, 1, 1), vec3(-12,40,12), ZERO_QUATERNION),
			SubPartTuple("WheelLeft2","kv6/btr2Wheel.kv6",  vec3(1, 1, 1), vec3(-12,20,12), ZERO_QUATERNION),
			SubPartTuple("WheelLeft3","kv6/btr2Wheel.kv6",  vec3(1, 1, 1), vec3(-12,0,12), ZERO_QUATERNION),
			SubPartTuple("WheelRight1","kv6/btr2Wheel.kv6", vec3(1, 1, 1), vec3(20,40,12), ZERO_QUATERNION),
			SubPartTuple("WheelRight2","kv6/btr2Wheel.kv6", vec3(1, 1, 1), vec3(20,20,12), ZERO_QUATERNION),
			SubPartTuple("WheelRight3","kv6/btr2Wheel.kv6", vec3(1, 1, 1), vec3(20,0,12), ZERO_QUATERNION)
		) BTRTank;

alias Model!(
			MainPartTuple("Body", "kv6/Heavy.kv6", vec3(0.5, 0.5, 0.5)),
			SubPartTuple("Tower", "kv6/HeavyTower.kv6", vec3(0.4, 0.4, 0.4), vec3(0,10,-26), 	  ZERO_QUATERNION),
			SubPartTuple("WheelLeft1","kv6/HeavyWheel.kv6", vec3(1.25, 1.8, 1.8), vec3(-20,6,5), ZERO_QUATERNION),
			SubPartTuple("WheelLeft2","kv6/HeavyWheel.kv6", vec3(1.25, 1.8, 1.8), vec3(-20,30,5), ZERO_QUATERNION),
			SubPartTuple("WheelRight1","kv6/HeavyWheel.kv6", vec3(1.25, 1.8, 1.8), vec3(20,6,5), ZERO_QUATERNION),
			SubPartTuple("WheelRight2","kv6/HeavyWheel.kv6", vec3(1.25, 1.8, 1.8), vec3(20,30,5), ZERO_QUATERNION),
		) HeavyTank;

// test
alias Model!(
		MainPartTuple("Body", "kv6/testball.kv6", vec3(1.0, 1.0, 1.0))
	) TestBall;