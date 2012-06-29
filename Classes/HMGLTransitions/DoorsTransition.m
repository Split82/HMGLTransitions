// Copyright (c) 2010 Hyperbolic Magnetism
// 
// Modifications for closing doors transition 
// Copyright (c) 2011 Karim-Pierre Maalej 
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

#import "DoorsTransition.h"

@implementation DoorsTransition {
	GLfloat animationTime;
}

@synthesize transitionType;

- (id)init {
	if (self = [super init]) {
		transitionType = DoorsTransitionTypeOpen;
	}
	return self;
}

- (void)initTransition {
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-0.1, 0.1, -0.1, 0.1, 0.1, 100.0); 
	
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
	glDisable(GL_LIGHTING);
	glColor4f(1.0, 1.0, 1.0, 1.0);		
	
    animationTime = (transitionType == DoorsTransitionTypeOpen)?0:-2*M_PI/3;
}

- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture {
		
    GLuint outerTexture, innerTexture; GLfloat sah, depth; 
    switch (transitionType) {
        case DoorsTransitionTypeOpen:
            sah = sin(animationTime * 0.5); 
            innerTexture = endTexture; 
            outerTexture = beginTexture; 
            depth = -1.2 + sah * 0.2;
            break;
            
        case DoorsTransitionTypeClose:
        default:
            sah = -sin(animationTime * 0.5);
            innerTexture = beginTexture; 
            outerTexture = endTexture; 
            depth = -1.0 + 0.5 * ( (animationTime < - M_PI_2) ? 0.0 : 1/(animationTime-0.25)-1/(-M_PI_2-0.25) ); 
            break;
    }
    
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	GLfloat w = 1.0;
	GLfloat h = 1.0;
	
	GLfloat vertices[] = {
        -w, -h,
		w, -h,
        -w,  h,
		w,  h,
    };
    
	GLfloat verticesHalf[] = {
        -w * 0.5, -h,
		w * 0.5, -h,
        -w * 0.5,  h,
		w * 0.5,  h,
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
	
    GLfloat intensity = sah * sah;
    
	// end view
	glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, &basicTexCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glPushMatrix();
	glBindTexture(GL_TEXTURE_2D, innerTexture);
    glTranslatef(0, 0, depth);	
    if (transitionType == DoorsTransitionTypeOpen)
        glColor4f(intensity, intensity, intensity, 1.0);
    else 
        glColor4f(1.0, 1.0, 1.0, 1.0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
	glPopMatrix();	
	
    if (transitionType == DoorsTransitionTypeOpen)
        glColor4f(1.0 - intensity, 1.0 - intensity, 1.0 - intensity, 1.0);
	
	// left	
	glPushMatrix();
	glBindTexture(GL_TEXTURE_2D, outerTexture);		
    glVertexPointer(2, GL_FLOAT, 0, verticesHalf);
    glEnableClientState(GL_VERTEX_ARRAY);	
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords1);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glTranslatef(-w, 0, -1);
    if (transitionType == DoorsTransitionTypeClose)
        glColor4f(1.0-intensity, 1.0-intensity, 1.0-intensity, 1.0);
	glRotatef(-sah * sah * sah * 90, 0, 1, 0);		
	glTranslatef(w * 0.5, 0, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	// right
	glPushMatrix();	
    glVertexPointer(2, GL_FLOAT, 0, verticesHalf);
    glEnableClientState(GL_VERTEX_ARRAY);		
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords2);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);	 
	glTranslatef(w, 0, -1);
    if (transitionType == DoorsTransitionTypeClose)
        glColor4f(1.0-intensity, 1.0-intensity, 1.0-intensity, 1.0);
	glRotatef(sah * sah * sah * 90, 0, 1, 0);		
	glTranslatef(-w * 0.5, 0, 0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();	
}

- (BOOL)calc:(NSTimeInterval)frameTime {
	
	animationTime += M_PI * frameTime * ((transitionType == DoorsTransitionTypeOpen)?1.3:0.8);
    GLfloat endAnimationTime = (transitionType == DoorsTransitionTypeOpen)?M_PI:0; 
	
	if (animationTime > endAnimationTime) {
		animationTime = endAnimationTime;
		return YES;
	}
    
    return NO;
}

@end
