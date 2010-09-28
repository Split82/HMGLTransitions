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

#import "RotateTransition.h"


@implementation RotateTransition

- (void)initTransition {
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-0.025, 0.025, -0.025, 0.025, 0.1, 20.0); 
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
	glDisable(GL_LIGHTING);
	glColor4f(1.0, 1.0, 1.0, 1.0);		
	
    animationTime = 0;
}

- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture {
	
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	GLfloat vertices[] = {
        -2.5, -2.5,
		2.5, -2.5,
        -2.5,  2.5,
		2.5,  2.5,
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
    glTranslatef(0, 0, - 10);
	glRotatef(sin(animationTime) * 180, 1, 0, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	// end view
	glPushMatrix();
	glBindTexture(GL_TEXTURE_2D, endTexture);
    glTranslatef(0, 0, - 10);
	glRotatef(sin(animationTime) * 180 + 180, 1, 0, 0);	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
	glPopMatrix();
	
}

- (BOOL)calc:(NSTimeInterval)frameTime {
	
	animationTime += M_PI * 0.5 * frameTime * 1.3;
    
    return animationTime > M_PI * 0.5;
	
}

@end