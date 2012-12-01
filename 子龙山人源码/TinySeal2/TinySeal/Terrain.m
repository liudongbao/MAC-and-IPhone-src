//
//  Terrain.m
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "Terrain.h"
#import "HelloWorldLayer.h"

@implementation Terrain
@synthesize stripes = _stripes;

- (void) generateHills {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float minDX = 160;
    float minDY = 60;
    int rangeDX = 80;
    int rangeDY = 40;
    
    float x = -minDX;
    float y = winSize.height/2-minDY;
    
    float dy, ny;
    float sign = 1; // +1 - going up, -1 - going  down
    float paddingTop = 20;
    float paddingBottom = 20;
    
    for (int i=0; i<kMaxHillKeyPoints; i++) {
        _hillKeyPoints[i] = CGPointMake(x, y);
        if (i == 0) {
            x = 0;
            y = winSize.height/2;
        } else {
            x += rand()%rangeDX+minDX;
            while(true) {
                dy = rand()%rangeDY+minDY;
                ny = y + dy*sign;
                if(ny < winSize.height-paddingTop && ny > paddingBottom) {
                    break;   
                }
            }
            y = ny;
        }
        sign *= -1;
    }
}

- (void)resetHillVertices {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    static int prevFromKeyPointI = -1;
    static int prevToKeyPointI = -1;
    
    // key points interval for drawing
    while (_hillKeyPoints[_fromKeyPointI+1].x < _offsetX-winSize.width/8/self.scale) {
        _fromKeyPointI++;
    }
    while (_hillKeyPoints[_toKeyPointI].x < _offsetX+winSize.width*9/8/self.scale) {
        _toKeyPointI++;
    }
    
    if (prevFromKeyPointI != _fromKeyPointI || prevToKeyPointI != _toKeyPointI) {
        
        // vertices for visible area
        _nHillVertices = 0;
        _nBorderVertices = 0;
        CGPoint p0, p1, pt0, pt1;
        p0 = _hillKeyPoints[_fromKeyPointI];
        for (int i=_fromKeyPointI+1; i<_toKeyPointI+1; i++) {
            p1 = _hillKeyPoints[i];
            
            // triangle strip between p0 and p1
            int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
            float dx = (p1.x - p0.x) / hSegments;
            float da = M_PI / hSegments;
            float ymid = (p0.y + p1.y) / 2;
            float ampl = (p0.y - p1.y) / 2;
            pt0 = p0;
            _borderVertices[_nBorderVertices++] = pt0;
            for (int j=1; j<hSegments+1; j++) {
                pt1.x = p0.x + j*dx;
                pt1.y = ymid + ampl * cosf(da*j);
                _borderVertices[_nBorderVertices++] = pt1;
                
                _hillVertices[_nHillVertices] = CGPointMake(pt0.x, 0);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 1.0f);
                _hillVertices[_nHillVertices] = CGPointMake(pt1.x, 0);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 1.0f);
                
                _hillVertices[_nHillVertices] = CGPointMake(pt0.x, pt0.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 0);
                _hillVertices[_nHillVertices] = CGPointMake(pt1.x, pt1.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 0);
                
                pt0 = pt1;
            }
            
            p0 = p1;
        }
        
        prevFromKeyPointI = _fromKeyPointI;
        prevToKeyPointI = _toKeyPointI;        
    }
    
}

- (id)init {
    if ((self = [super init])) {
        [self generateHills];
        [self resetHillVertices];
    }
    return self;
}

- (void) draw {
    
    glBindTexture(GL_TEXTURE_2D, _stripes.texture.name);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glColor4f(1, 1, 1, 1);
    glVertexPointer(2, GL_FLOAT, 0, _hillVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _hillTexCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nHillVertices);
    
    /*for(int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i) {
        glColor4f(1.0, 0, 0, 1.0); 
        ccDrawLine(_hillKeyPoints[i-1], _hillKeyPoints[i]);     
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        
        CGPoint p0 = _hillKeyPoints[i-1];
        CGPoint p1 = _hillKeyPoints[i];
        int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
        float dx = (p1.x - p0.x) / hSegments;
        float da = M_PI / hSegments;
        float ymid = (p0.y + p1.y) / 2;
        float ampl = (p0.y - p1.y) / 2;
        
        CGPoint pt0, pt1;
        pt0 = p0;
        for (int j = 0; j < hSegments+1; ++j) {
            
            pt1.x = p0.x + j*dx;
            pt1.y = ymid + ampl * cosf(da*j);
            
            ccDrawLine(pt0, pt1);
            
            pt0 = pt1;
            
        }
    }*/
    
}

- (void) setOffsetX:(float)newOffsetX {
    _offsetX = newOffsetX;
    self.position = CGPointMake(-_offsetX*self.scale, 0);
    [self resetHillVertices];
}

- (void)dealloc {
    [_stripes release];
    _stripes = NULL;
    [super dealloc];
}

@end