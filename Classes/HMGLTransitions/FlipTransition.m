// Copyright (c) 2010 Hyperbolic Magnetism
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FlipTransition.h"


@implementation FlipTransition

@synthesize transitionType;

- (id)init {
	if (self = [super init]) {
		transitionType = FlipTransitionLeft;
	}
	return self;
}

- (void)initTransition {
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-0.025, 0.025, -0.025, 0.025, 0.1, 20.0); 
	
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
	glDisable(GL_LIGHTING);
	glColor4f(1.0, 1.0, 1.0, 1.0);		
	
	if (transitionType == FlipTransitionLeft) {	
		animationTime = 0;
	}
	else {
		animationTime = M_PI;
	}
}

- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture {
	
	if (transitionType == FlipTransitionRight) {	
		// switch textures
		GLuint t = beginTexture;
		beginTexture = endTexture;
		endTexture = t;
	}
		
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	GLfloat w = 2.5;
	GLfloat h = 2.5;
	
	GLfloat vertices[] = {
        0, -h,
		w, -h,
        0,  h,
		w,  h,
    };
    
    GLfloat texcoords1[] = {
		basicTexCoords.x0, basicTexCoords.y0,
		(basicTexCoords.x1 + basicTexCoords.x0) * 0.5, (basicTexCoords.y1 + basicTexCoords.y0) * 0.5,
		basicTexCoords.x2, basicTexCoords.y2,
		(basicTexCoords.x3 + basicTexCoords.x2) * 0.5, (basicTexCoords.y2 + basicTexCoords.y3) * 0.5,	
    };
	
    GLfloat texcoords2[] = {
		(basicTexCoords.x1 + basicTexCoords.x0) * 0.5, (basicTexCoords.y1 + basicTexCoords.y0) * 0.5,
		basicTexCoords.x1, basicTexCoords.y1,
		(basicTexCoords.x3 + basicTexCoords.x2) * 0.5, (basicTexCoords.y2 + basicTexCoords.y3) * 0.5,
		basicTexCoords.x3, basicTexCoords.y3,	
    };	
	
    glEnable(GL_TEXTURE_2D);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
		
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);    
    
	glPushMatrix();
	// left begin
	glBindTexture(GL_TEXTURE_2D, beginTexture);	
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords1);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
    glTranslatef(-w, 0, - 10);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	glPushMatrix();	
	// right end
	glBindTexture(GL_TEXTURE_2D, endTexture);	
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords2);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);	 
    glTranslatef(0, 0, - 10);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	glPushMatrix();	
	// right begin
	glBindTexture(GL_TEXTURE_2D, beginTexture);		
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords2);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
    glTranslatef(0, 0, -10);	
	glRotatef(-180 * sin(animationTime*0.5) * sin(animationTime*0.5), 0, 1, 0);	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);		
	glPopMatrix();	 
	
	glPushMatrix();		
	// left end
	glBindTexture(GL_TEXTURE_2D, endTexture);		 
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords1);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);	 
    glTranslatef(0, 0, -10);	
	glRotatef(-180 * sin(animationTime*0.5) * sin(animationTime*0.5) + 180, 0, 1, 0);
	glTranslatef(-w, 0, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
}



- (BOOL)calc:(NSTimeInterval)frameTime {
	
	if (transitionType == FlipTransitionLeft) {
		animationTime += M_PI * frameTime * 1.2;
		
		if (animationTime > M_PI) {
			animationTime = M_PI;
			return YES;
		}
		
		return NO;
	}
	else {
		animationTime -= M_PI * frameTime * 1.2;
		
		if (animationTime < 0) {
			animationTime = 0;
			return YES;
		}
		
		return NO;
	}
}

@end
