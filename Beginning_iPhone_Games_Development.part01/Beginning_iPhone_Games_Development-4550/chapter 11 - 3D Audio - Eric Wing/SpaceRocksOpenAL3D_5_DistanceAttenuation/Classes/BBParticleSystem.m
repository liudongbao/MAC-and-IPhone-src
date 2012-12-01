//
//  BBParticleSystem.m
//  SkateDude
//
//  Created by ben smith on 28/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBParticleSystem.h"
#import "BBParticle.h"



@implementation BBParticleSystem

@synthesize emit,materialKey;
@synthesize emissionRange, sizeRange, growRange, xVelocityRange, yVelocityRange;
@synthesize lifeRange,decayRange,emitCounter;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setDefaultSystem];
	}
	return self;
}

-(void)setDefaultSystem
{
	// just some decent defaults so a naked emitter
	// will do something.
	self.emissionRange = BBRangeMake(1.0, 2.0);
	self.sizeRange = BBRangeMake(4.0, 8.0);
	self.growRange = BBRangeMake(-0.5, -0.1);
	self.xVelocityRange = BBRangeMake(-8.0, -5.0);
	self.yVelocityRange = BBRangeMake(-3.0, 3.0);
	self.lifeRange = BBRangeMake(0.0, 2.0);
	self.decayRange = BBRangeMake(0.05, 0.2);
	self.emit = NO;
	emitCounter = -1;
}

-(void)awake
{
	[super awake];
	// alloc some space for our particles
	if (activeParticles == nil) activeParticles = [[NSMutableArray alloc] init];
	
	// we are going to pre-alloc a whole bunch of particles so
	// we dont wast time during gameplay allocing them
	particlePool = [[NSMutableArray alloc] initWithCapacity:BB_MAX_PARTICLES];
	NSInteger count = 0;
	for (count = 0; count < BB_MAX_PARTICLES; count++) {
		BBParticle * p = [[BBParticle alloc] init];
		[particlePool addObject:p];
		[p release];
	}
	
	// finally make some space for our final particle mesh
	// our vertexes will be all 3 axes, and we need 6 axes per particle
	vertexes = (CGFloat *) malloc(3 * 6 * BB_MAX_PARTICLES * sizeof(CGFloat));
	uvCoordinates = (CGFloat *) malloc(2 * 6 * BB_MAX_PARTICLES * sizeof(CGFloat));
}

-(void)setParticle:(NSString*)atlasKey
{
	// ok, here we are going to go and get the quad that will be our particle image
	// however, we do not want to keep the mesh, we just want to get some information from it.
	BBTexturedQuad * quad = [[BBMaterialController sharedMaterialController] quadFromAtlasKey:atlasKey];

	// get the material key so we can bind it during render
	self.materialKey = quad.materialKey;
	
	// now we need to find the max/min of the UV coordinates
	// this is the location in the atlas where our image is, and we are
	// going to be applying it to every particle
	CGFloat u,v;
	NSInteger index;
	minU = minV = 1.0;
	maxU = maxV = 0.0;
	CGFloat * uvs = [quad uvCoordinates];
	for (index = 0; index < quad.vertexCount; index++) {
		u = uvs[index * 2];
		v = uvs[(index * 2) + 1];
		if (u < minU) minU = u;
		if (v < minV) minV = v;
		if (u > maxU) maxU = u;
		if (v > maxV) maxV = v;
	}
}

-(void)update
{
	// update active particles, they will move themselves
	[super update];
	
	// build arrays
	[self buildVertexArrays];
	
	// generate new particles and queue them for addition
	[self emitNewParticles];
	
	//remove old particles
	[self clearDeadQueue];
}


-(BOOL)activeParticles
{
	if ([activeParticles count] > 0) return YES;
	return NO;
}

-(void)buildVertexArrays
{
	// go through all our individual particles and add their triangles
	// to our big mesh
	vertexIndex = 0;
	for (BBParticle * particle in activeParticles) {
		[particle update]; // first, update each particle before we use it's data
	
		// check to see if we have run out of life, or are too small to see
		// and if they are, then queue them for removal
		if ((particle.life < 0) || (particle.size < 0.3)) {
			[self removeChildParticle:particle];
			continue; // skip to the next particle, no need to add this one
		}
		
		// for each particle, need 2 triangles, so 6 verts
		// first triangle of the quad.  Need to load them in clockwise
		// order since our models are in that order
		[self addVertex:(particle.position.x - particle.size) 
									y:(particle.position.y + particle.size) 
									u:minU 
									v:minV];
		[self addVertex:(particle.position.x + particle.size) 
									y:(particle.position.y - particle.size) 
									u:maxU 
									v:maxV];		
		[self addVertex:(particle.position.x - particle.size) 
									y:(particle.position.y - particle.size) 
									u:minU 
									v:maxV];
		
		// second triangle of the quad
		[self addVertex:(particle.position.x - particle.size) 
									y:(particle.position.y + particle.size) 
									u:minU 
									v:minV];
		[self addVertex:(particle.position.x + particle.size) 
									y:(particle.position.y + particle.size) 
									u:maxU 
									v:minV];
		[self addVertex:(particle.position.x + particle.size) 
									y:(particle.position.y - particle.size) 
									u:maxU 
									v:maxV];
		
	}
}

// we want to override the super's render because
// we dont have a mesh, but instead are holding onto all the array data
// as instance vars
-(void)render
{
	if (!active) return; 

	// clear the matrix
	glPushMatrix();
	glLoadIdentity();

	// bind our texture
	[[BBMaterialController sharedMaterialController] bindMaterial:materialKey];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	
	// send the arrays to the rendered
	glVertexPointer(3, GL_FLOAT, 0, vertexes);
  glTexCoordPointer(2, GL_FLOAT, 0, uvCoordinates);
	//draw
  glDrawArrays(GL_TRIANGLES, 0, vertexIndex);

	glPopMatrix();
}




-(void)emitNewParticles
{
	if (!emit) return;
	if (emitCounter > 0) emitCounter --; // if emitCounter == -1, then emit forever
	if (emitCounter == 0) emit = NO; // this will be our last time through the emit method
	
	NSInteger newParticles = (NSInteger)BBRandomFloat(emissionRange); // grab a random number to be emitted
	
	NSInteger index;
	CGFloat veloX,veloY;
	for (index = 0; index < newParticles; index++) {
		if ([particlePool count] == 0) {
			// if we are out of particles, then just get out early
			return;
		} 
		// grab a premade particle and set it up with some new random nubmers
		BBParticle * p = [particlePool lastObject];
		p.position = self.translation;
		veloX = BBRandomFloat(xVelocityRange);
		veloY = BBRandomFloat(yVelocityRange);
		p.velocity = BBPointMake(veloX, veloY, 0.0);
		
		p.life = BBRandomFloat(lifeRange);
		p.size = BBRandomFloat(sizeRange);
		p.grow = BBRandomFloat(growRange);
		p.decay = BBRandomFloat(decayRange);
		
		// add this particle
		[activeParticles addObject:p];
		// remove this particle from the unused array
		[particlePool removeLastObject];
	}
}


-(void)removeChildParticle:(BBParticle*)particle
{
	if (objectsToRemove == nil) objectsToRemove = [[NSMutableArray alloc] init];
	[objectsToRemove addObject:particle];
}


-(void)clearDeadQueue
{
	// remove any objects that need removal
	if ([objectsToRemove count] > 0) {
		[activeParticles removeObjectsInArray:objectsToRemove];
		[particlePool addObjectsFromArray:objectsToRemove];
		[objectsToRemove removeAllObjects];
	}
}

// add a single vertex to our arrays
-(void)addVertex:(CGFloat)x y:(CGFloat)y u:(CGFloat)u v:(CGFloat)v
{
	// our position in the vertex array
	NSInteger pos = vertexIndex * 3.0;
	vertexes[pos] = x;
	vertexes[pos + 1] = y;
	vertexes[pos + 2] = self.translation.z;
	
	// the UV array has a different position
	pos = vertexIndex * 2.0;
	uvCoordinates[pos] = u;
	uvCoordinates[pos + 1] = v;
	// increment our vertex count
	vertexIndex++;
}

- (void) dealloc
{
	[particlePool release];
	[activeParticles release];

	free(vertexes);
	free(uvCoordinates);
	
	[super dealloc];
}

@end
