/*
 *  pointmath.c
 *  Chapter3 Framework
 *
 *  Created by Joe Hogue on 6/27/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "pointmath.h"

CGPoint add (CGPoint a, CGPoint b) {
	return CGPointMake(a.x+b.x, a.y+b.y);
}

CGPoint sub (CGPoint a, CGPoint b) {
	return CGPointMake(a.x-b.x, a.y-b.y);
}

CGPoint scale(CGPoint a, float mag) {
	return CGPointMake(a.x*mag, a.y*mag);
}

CGPoint clamp(CGPoint a, float magsquared){
	float mag = a.x*a.x+a.y*a.y;
	if(mag > magsquared){
		mag = sqrt(magsquared);
		a.x = a.x / mag;
		a.y = a.y / mag;
	}
	return a;
}

CGFloat distsquared(CGPoint a, CGPoint b){
	CGFloat dx = a.x - b.x;
	CGFloat dy = a.y - b.y;
	return dx*dx + dy*dy;
}

//returns a unit vector pointing from a to b.
CGPoint toward(CGPoint a, CGPoint b){
	CGFloat dx = b.x - a.x;
	CGFloat dy = b.y - a.y;
	CGFloat len = sqrt(dx*dx + dy*dy);
	if(len == 0.0f){
		dx = ((random() % 100)+1) / 100.0f;
		dy = ((random() % 100)+1) / 100.0f;
		len = sqrt(dx*dx + dy*dy);
	}
	return CGPointMake(dx/len, dy/len);
}

CGPoint unit(CGPoint a) {
	return toward(CGPointZero, a);
}

PolarCoord PolarCoordFromPoint(CGPoint a){
	float mag = sqrt(a.x*a.x+a.y*a.y);
	float theta = atan2(a.y, a.x);
	return PolarCoordMake(theta, mag);
}

CGPoint PointFromPolarCoord(PolarCoord p){
	return CGPointMake(p.magnitude*cos(p.theta), p.magnitude*sin(p.theta));
}

float thetaToward(float a, float b, float step){
	//return a+-step, such that a is now closer to b.
	//step must be positive.
	
	if(a<0) a+= 2*PI;
	if(b<0) b+= 2*PI;
	
	if(a<0 || b<0){
		NSLog(@"shouldn't happen.");
	}
	
	//if(a==b) return a;
	if(abs(b-a) < step) return b;
	
	if(a<b){
		return a+step;
	} else {
		return a-step;
	}
}

//because re-writing it is quicker than finding it in the docs...
float min(float a, float b){
	return a<b?a:b;
}

float sign(float a){
	return a<0?-1:1;
}

//clockwise from straight up, in opengl coords.
int cheapsin[] = { 1, 0, -1, 0 };
int cheapcos[] = { 0, -1, 0, 1 };
