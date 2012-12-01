/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

//
// File modified for cocos2d integration
// http://www.cocos2d-iphone.org
//

#include "iPhoneTest.h"
//#include "GLES-Render.h"

#include "ApplyForce.h"
#include "BodyTypes.h"
#include "Breakable.h"
#include "Bridge.h"
#include "Cantilever.h"
#include "ContinuousTest.h"
#include "Chain.h"
#include "CharacterCollision.h"
#include "CollisionFiltering.h"
#include "CollisionProcessing.h"
#include "CompoundShapes.h"
#include "Confined.h"
#include "DistanceTest.h"
#include "Dominos.h"
#include "DynamicTreeTest.h"
#include "EdgeShapes.h"
#include "Gears.h"
#include "LineJoint.h"
#include "OneSidedPlatform.h"
#include "PolyCollision.h"
#include "PolyShapes.h"
#include "Prismatic.h"
#include "Pulleys.h"
#include "Pyramid.h"
#include "RayCast.h"
#include "Revolute.h"
#include "SensorTest.h"
#include "ShapeEditing.h"
#include "SliderCrank.h"
#include "SphereStack.h"
#include "TheoJansen.h"
#include "TimeOfImpact.h"
#include "VaryingFriction.h"
#include "VaryingRestitution.h"
#include "VerticalStack.h"
#include "Web.h"
// #include "ElasticBody.h"

TestEntry g_testEntries[] =
{

    // Basic Body and Shape
    {"Character Collision", "", CharacterCollision::Create},
    {"Edge Shapes", "12345d", EdgeShapes::Create},
    {"Body Types", "dsk", BodyTypes::Create},
    {"Confined", "c", Confined::Create},
    {"Varying Friction", "", VaryingFriction::Create},
    {"Varying Restitution", "", VaryingRestitution::Create},
    {"Compound Shapes", "", CompoundShapes::Create},

    // Sahpe Stack
    {"SphereStack", "", SphereStack::Create},
    {"Vertical Stack", ",", VerticalStack::Create},
    {"Pyramid", "", Pyramid::Create},
    {"Dominos", "", Dominos::Create},

    // Shape Advanced topic
    {"Shape Editing", "cd", ShapeEditing::Create},
    {"Breakable", "", Breakable::Create},
    
    // Do some Query
    {"PolyShapes", "12345ad", PolyShapes::Create},		// ZY++ Add 2011.3.6
    {"Ray-Cast", "12345dm", RayCast::Create},
    {"Distance Test", "adswqe", DistanceTest::Create},
    
    // Collision detect
    {"PolyCollision", "adswqe", PolyCollision::Create},
    {"Collision Filtering", "", CollisionFiltering::Create},
    {"Collision Processing", "", CollisionProcessing::Create},
    {"One-Sided Platform", "", OneSidedPlatform::Create},

    // Make some Joint
    {"Apply Force", "wad", ApplyForce::Create},
    {"Cantilever", "", Cantilever::Create},
    {"Bridge", "", Bridge::Create},
    {"Chain", "", Chain::Create},
    {"Gears", "", Gears::Create},
    {"Line Joint", "", LineJoint::Create},
    {"Pulleys", "", Pulleys::Create},
    {"Revolute", "ls", Revolute::Create},
    {"Slider Crank", "fm", SliderCrank::Create},
    {"Theo Jansen's Walker", "asdm", TheoJansen::Create},
    {"Web", "bj", Web::Create},
 
    // Sensor
    {"Sensor Test", "", SensorTest::Create},    
    
    // Advanced topic
    {"Continuous Test", "", ContinuousTest::Create},
    {"Dynamic Tree", "acdm", DynamicTreeTest::Create},
    {"Time of Impact", "", TimeOfImpact::Create},
    
	//{NULL, NULL}
    //    {"ElasticBody", "", ElasticBody::Create},    
};

int g_totalEntries = sizeof(g_testEntries) / sizeof(g_testEntries[0]);

