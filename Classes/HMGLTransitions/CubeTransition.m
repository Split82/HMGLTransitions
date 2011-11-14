//
//  CubeTransition.m
//  HMGLTransitions
//
//  Created by Patrick Pietens on 11/14/11.
//  Copyright (c) 2011 PatrickPietens.com. All rights reserved.
//

#import "CubeTransition.h"

@implementation CubeTransition

@synthesize transitionType;

- (id)init 
{
	if (self = [super init]) 
    {
		transitionType = CubeTransitionLeft;
	}
    
	return self;
}


- (void)initTransition 
{	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-0.1, 0.1, -0.1, 0.1, 0.1, 100.0);
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
	glDisable(GL_LIGHTING);
	glColor4f(1.0, 1.0, 1.0, 1.0);		
	
    animationTime = 0;
}


- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture 
{	
    int myDirection = transitionType == CubeTransitionLeft ? -1 : 1;
    
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	GLfloat vertices[] = {
        -0.5, -0.5,
		0.5, -0.5,
        -0.5,  0.5,
		0.5, 0.5,
    };
    
    glEnable(GL_TEXTURE_2D);
	
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, &basicTexCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 	
    
	glPushMatrix();
	// begin view
	glBindTexture(GL_TEXTURE_2D, beginTexture);	
    glTranslatef(0, 0, -1.0);
	glRotatef(myDirection * -90 * sin(animationTime), 0, 1, 0); 
    glTranslatef(0, 0, 0.5);    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	glPushMatrix();
	// end view
	glBindTexture(GL_TEXTURE_2D, endTexture);	
    glTranslatef(0, 0, -1.0 );
	glRotatef(myDirection * -90 * sin(animationTime), 0, 1, 0); 
    glTranslatef(myDirection * 0.5, 0.0, 0);    
    glRotatef(myDirection * 90, 0, 1, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
}


- (BOOL)calc:(NSTimeInterval)frameTime 
{	
	animationTime += M_PI * 0.5 * frameTime * 1.5;
    return animationTime > M_PI * 0.5;	
}

@end
