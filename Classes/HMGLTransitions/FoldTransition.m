//
//  FoldTransition.m
//  HMGLTransitions
//
//  Created by John Baker on 3/4/12.
//  Copyright (c) 2012 5 to 9 Studio. All rights reserved.
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

#import "FoldTransition.h"


@implementation FoldTransition

@synthesize foldDirection;
@synthesize numberOfFolds;
@synthesize foldType;

- (id)init {
	if (self = [super init]) {
		foldDirection = FoldDirectionLeft;
        numberOfFolds = 4;
        foldType = Fold;
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
	
    animationTime = 0;
}

- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture {
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat vertices[] = {
        -1, -1, 0,
        1, -1, 0,
        -1,  1, 0, 
        1,  1, 0
    };
    
    glEnable(GL_TEXTURE_2D);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
    
    // end view
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, &basicTexCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glPushMatrix();
    glColor4f(1, 1, 1, 1.0);
    glBindTexture(GL_TEXTURE_2D, foldType == Fold ? beginTexture : endTexture);
    glTranslatef(0, 0, -1.0);	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
    glPopMatrix();	

    CGFloat fraction = (animationTime / M_PI);
    fraction = MAX(MIN(1, fraction), 0);
    if(foldType == Unfold) {
        fraction = 1-fraction;
    }
    
    CGFloat faceCount = numberOfFolds * 2;
    CGFloat faceSize = 2.0/(faceCount);
    CGFloat faceSizeFraction = (faceSize)*fraction;
    CGFloat faceFractionX = -1.0+(faceSizeFraction);
    
    if(foldDirection == FoldDirectionLeft) {
        for(int i = 0; i < (faceCount); i++) {
            GLfloat texcoords[] = {
                (basicTexCoords.x0 + ((basicTexCoords.x1 - basicTexCoords.x0) / (faceCount))*i), basicTexCoords.y0,
                (basicTexCoords.x0 + ((basicTexCoords.x1 - basicTexCoords.x0) / (faceCount))*(i+1.0)), basicTexCoords.y0,
                (basicTexCoords.x2 + ((basicTexCoords.x3 - basicTexCoords.x2) / (faceCount))*i), basicTexCoords.y2,
                (basicTexCoords.x2 + ((basicTexCoords.x3 - basicTexCoords.x2) / (faceCount))*(i+1.0)), basicTexCoords.y2,
            };
            
            bool isLeft = false;
            if(i%2==0 ) {
                isLeft = true;
            }
            
            if(isLeft) {
                
                GLfloat verts[] = {
                    -1.0, -1.0, 0,
                    faceFractionX , -1.0,-1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2))),
                    -1.0,  1.0, 0,
                    faceFractionX ,  1.0,-1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2)))
                };
                
                // left	
                glPushMatrix();
                glBindTexture(GL_TEXTURE_2D, foldType == Fold ? endTexture : beginTexture);
                glVertexPointer(3, GL_FLOAT, 0, verts);
                glEnableClientState(GL_VERTEX_ARRAY);	
                glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glColor4f(fraction, fraction, fraction, 1.0);
                glTranslatef((faceSizeFraction)*i, 0, -1.0);	
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glPopMatrix();
            } 
            else 
            {
                GLfloat verts[] = {
                    faceFractionX , -1.0,-1 * ( sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2))),                    
                    -1.0+(faceSizeFraction)*2, -1.0, 0,
                    faceFractionX ,  1.0, -1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2))),                    
                    -1.0+(faceSizeFraction)*2,  1.0, 0,
                };
                
                // left	
                glPushMatrix();
                glBindTexture(GL_TEXTURE_2D, foldType == Fold ? endTexture : beginTexture);
                glVertexPointer(3, GL_FLOAT, 0, verts);
                glEnableClientState(GL_VERTEX_ARRAY);	
                glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glColor4f(1, 1, 1, 1.0);
                
                glTranslatef((faceSizeFraction)*(i-1), 0, -1.0);	
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glPopMatrix();
            }
        }
    } else if(foldDirection == FoldDirectionRight) {
        for(int i = 1; i <= (faceCount); i++) {
            GLfloat texcoords[] = {
                (basicTexCoords.x0 + ((basicTexCoords.x1 - basicTexCoords.x0) / (faceCount))*((faceCount)-i)), basicTexCoords.y0,
                (basicTexCoords.x0 + ((basicTexCoords.x1 - basicTexCoords.x0) / (faceCount))*(((faceCount)-i)+1.0)), basicTexCoords.y0,
                (basicTexCoords.x2 + ((basicTexCoords.x3 - basicTexCoords.x2) / (faceCount))*((faceCount)-i)), basicTexCoords.y2,
                (basicTexCoords.x2 + ((basicTexCoords.x3 - basicTexCoords.x2) / (faceCount))*(((faceCount)-i)+1.0)), basicTexCoords.y2,
            };
            
            bool isRight = false;
            if(i%2==1 ) {
                isRight = true;
            }
            
            if(isRight) {
                GLfloat verts[] = {
                    0 , -1.0, -1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2))),
                    (faceSizeFraction), -1.0, 0,
                    0 ,  1.0, -1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2))),
                    (faceSizeFraction),  1.0, 0,
                };
                
                glPushMatrix();
                glBindTexture(GL_TEXTURE_2D, foldType == Fold ? endTexture : beginTexture);
                glVertexPointer(3, GL_FLOAT, 0, verts);
                glEnableClientState(GL_VERTEX_ARRAY);	
                glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glColor4f(fraction, fraction, fraction, 1.0);
                glTranslatef(1.0-(faceSizeFraction)*i, 0, -1.0);	
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glPopMatrix();
                glColor4f(1, 1, 1, 1.0);
                
            } 
            else 
            {
                GLfloat verts[] = {
                    0 , -1.0, 0,
                    (faceSizeFraction), -1.0, -1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2))),
                    0 ,  1.0, 0,
                    (faceSizeFraction),  1.0, -1 * (sqrt(pow((faceSize),2)-pow(((faceFractionX)-(-1.0)),2)))
                };
                
                glPushMatrix();
                glBindTexture(GL_TEXTURE_2D, foldType == Fold ? endTexture : beginTexture);
                glVertexPointer(3, GL_FLOAT, 0, verts);
                glEnableClientState(GL_VERTEX_ARRAY);	
                glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
                glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                glColor4f(1, 1, 1, 1.0);
                glTranslatef(1.0-(faceSizeFraction)*i, 0, -1.0);	
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glPopMatrix();
            }
        }
    } else if(foldDirection == FoldDirectionTop) {
        /* NOT IMPLEMENTED YET */
   } else if(foldDirection == FoldDirectionBottom) {
       /* NOT IMPLEMENTED YET */
    }
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
