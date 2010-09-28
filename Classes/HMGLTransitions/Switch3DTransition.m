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
#import "Switch3DTransition.h"

@implementation Switch3DTransition

@synthesize transitionType;

- (id)init {
	if (self = [super init]) {
		transitionType = Switch3DTransitionRight;
	}
	return self;
}

- (void)initTransition {
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-0.1, 0.1, -0.1, 0.1, 0.1, 100.0); 
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
	glDisable(GL_LIGHTING);
	glColor4f(1.0, 1.0, 1.0, 1.0);		
	
    animationTime = 0;
}

- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture {
	
	// Direction of animation
	GLfloat direction = 1;
	if (transitionType == Switch3DTransitionLeft) {
		direction = -1;
	}
	
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
	GLfloat vertices[] = {
        -1, -1,
		1, -1,
        -1,  1,
		1,  1,
    };
    
    glEnable(GL_TEXTURE_2D);

    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, &basicTexCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
	
	GLfloat sa = sin(animationTime);
	GLfloat sah = sin(animationTime * 0.5);
	GLfloat sa3 = sa * sa * sa;
			
	glPushMatrix();
	// begin view
	glBindTexture(GL_TEXTURE_2D, beginTexture);	
    glTranslatef(direction * sa3 * 1.1, 0, -sah * sah * sah - 1);
	GLfloat intensity = 1 - sah * sah;
	glColor4f(intensity, intensity, intensity, 1.0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	// end view
	glPushMatrix();
	glBindTexture(GL_TEXTURE_2D, endTexture);
    glTranslatef(-direction * sa3 * 1.1, 0, sah * sah * sah - 2);	
	intensity = sah * sah;
	glColor4f(intensity, intensity, intensity, 1.0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
	glPopMatrix();
	
}

- (BOOL)calc:(NSTimeInterval)frameTime {
	
	animationTime += M_PI * frameTime * 1.3;
    
	if (animationTime > M_PI) {
		animationTime = M_PI;
		return YES;
	}
    
    return NO;

}

@end
