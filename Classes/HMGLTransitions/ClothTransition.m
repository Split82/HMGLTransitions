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

#define NUMBER_OF_VERTICES_X 30
#define NUMBER_OF_VERTICES_Y 45

#define NEIGHBOUR_STRENGTH 0.125f
#define DIAGONAL_NEIGHBOUR_STRENGTH 0.0835f
#define ZERO_STRENGTH 0.02f

#import "ClothTransition.h"

typedef struct {
	GLfloat x, y, z;
} Vector3;

Vector3 substractVectors(Vector3 v1, Vector3 v2) {
	Vector3 r;
	r.x = v1.x - v2.x;
	r.y = v1.y - v2.y;
	r.z = v1.z - v2.z;
	return r;
}

void addVectors(Vector3 *v1, Vector3 v2) {
	(*v1).x += v2.x;
	(*v1).y += v2.y;
	(*v1).z += v2.z;	
}

void multiplyVector(Vector3 *v, GLfloat a) {
	(*v).x *= a;
	(*v).y *= a;
	(*v).z *= a;
}

GLfloat vectorLength(Vector3 v) {
	return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
}

@interface ClothTransition()

- (void)punchAtPoint:(CGPoint)punchPoint withTime:(NSTimeInterval)frameTime;

@end


@implementation ClothTransition

- (void)initTransition {
	
	width = 320;
	height = 480;
		
	oglWidth = 3.31370849f;
	oglHeight = 4.970563f;
	
	// parameters
	friction = 0.97;
	velocityStrength = 10;
	
	
	// default normals
	normals = malloc(NUMBER_OF_VERTICES_X * NUMBER_OF_VERTICES_Y * 3 * sizeof(GLfloat));
	for (int x = 0; x < NUMBER_OF_VERTICES_X; x++) {
		for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
			normals[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y] = 0;
			normals[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 1] = 0;
			normals[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2] = 1;
		}			
	}
	
	// creating vertices grid
	vertices = malloc(NUMBER_OF_VERTICES_X * NUMBER_OF_VERTICES_Y * 3 * sizeof(GLfloat));
	for (int x = 0; x < NUMBER_OF_VERTICES_X; x++) {
		for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
			vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y] = oglWidth * (x / (GLfloat)(NUMBER_OF_VERTICES_X - 1)) - oglWidth * 0.5f; 
			vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 1] = oglHeight * (y / (GLfloat)(NUMBER_OF_VERTICES_Y - 1)) - oglHeight * 0.5f; 			
			vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2] = 0;
		}
	}
	
	texCoords = malloc(NUMBER_OF_VERTICES_X * NUMBER_OF_VERTICES_Y * 2 * sizeof(GLfloat));
	for (int x = 0; x < NUMBER_OF_VERTICES_X; x++) {
		for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
			texCoords[(x * 2) + (NUMBER_OF_VERTICES_X * 2) * y] = basicTexCoords.x0 + (x / (GLfloat)(NUMBER_OF_VERTICES_X - 1)) * (basicTexCoords.x3 - basicTexCoords.x0);
			texCoords[(x * 2) + (NUMBER_OF_VERTICES_X * 2) * y + 1] = basicTexCoords.y0 + (y / (GLfloat)(NUMBER_OF_VERTICES_Y - 1)) * (basicTexCoords.y3 - basicTexCoords.y0);		
		}
	}		
	
	// velocities
	velocities = malloc(NUMBER_OF_VERTICES_X * NUMBER_OF_VERTICES_Y * 3 * sizeof(float));
	for (int x = 0; x < NUMBER_OF_VERTICES_X; x++) {
		for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
			velocities[x * 3 + y * 3 * (NUMBER_OF_VERTICES_X)] = 0;
			velocities[x * 3 + y * 3 * (NUMBER_OF_VERTICES_X) + 1] = 0;
			velocities[x * 3 + y * 3 * (NUMBER_OF_VERTICES_X) + 2] = 0;
		}
	}			
	
	// creating indices
	indices = malloc((2 * NUMBER_OF_VERTICES_X - 2) * NUMBER_OF_VERTICES_Y * sizeof(GLuint)); // this is a little more than we need (we can - (NUMBER_OF_VERTICES_Y - 2) )
	int i = 0;
	for (int x = 0; x < NUMBER_OF_VERTICES_X - 1; x++) {
		for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
			// going down
			if (x % 2 == 0) {
				indices[i] = x + y * NUMBER_OF_VERTICES_X; 
				i++;
				if (y < NUMBER_OF_VERTICES_Y - 1) {
					indices[i] = x + 1 + y * NUMBER_OF_VERTICES_X;
					i++;
				}
			}
			// going up
			else {
				indices[i] = x + (NUMBER_OF_VERTICES_Y - y - 1) * NUMBER_OF_VERTICES_X;
				i++;
				if (y < NUMBER_OF_VERTICES_Y - 1)  {
					indices[i] = x + 1 + (NUMBER_OF_VERTICES_Y - y - 1) * NUMBER_OF_VERTICES_X;
					i++;
				}
			}
		}
	}
	if (NUMBER_OF_VERTICES_X % 2 != 0) {
		indices[i] = NUMBER_OF_VERTICES_X - 1;
		i++;
	}
	else {
		indices[i] = NUMBER_OF_VERTICES_X - 1 + (NUMBER_OF_VERTICES_X * (NUMBER_OF_VERTICES_Y - 1));
		i++;
	}
	
	indicesCount = i;
	
	// initial punch
	[self punchAtPoint:CGPointMake(width, 0) withTime:0.1];
	
	GLfloat LightAmbient[]= { 0.3f, 0.3f, 0.3f, 1.0f }; 	
	GLfloat LightDiffuse[]= { 1.0f, 1.0f, 1.0f, 1.0f };
	GLfloat LightSpecular[]= { 1.0f, 1.0f, 1.0f, 1.0f };
	
	glDisable(GL_CULL_FACE);
	glEnable(GL_NORMALIZE);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	
	glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);	
	glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);	
	glLightfv(GL_LIGHT1, GL_SPECULAR, LightSpecular);	
	glEnable(GL_LIGHT1);
	glEnable(GL_LIGHTING);
	
	GLfloat materialReflection[] = {1, 1, 1, 1};
	GLfloat materialColor[] = {1, 1, 1, 1};
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, materialColor);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, materialReflection);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 100.0f);	
	
	remainingCalcTime = 0;
	animationTime = 0;
}

- (void)perspective:(double) fovy aspect:(double)aspect zNear:(double)zNear zFar:(double)zFar{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	double xmin, xmax, ymin, ymax;
	
	ymax = zNear * tan(fovy * M_PI / 360.0);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;
	
	
	glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
}


- (void)drawWithBeginTexture:(GLuint)beginTexture endTexture:(GLuint)endTexture {
	
	glDisable(GL_CULL_FACE);
	glEnable(GL_NORMALIZE);
	glEnable(GL_DEPTH_TEST);	
	glEnable(GL_LIGHTING);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	// Calculate The Aspect Ratio Of The Window
	[self perspective:45.0f aspect:(GLfloat)width / (GLfloat)height zNear:0.01f zFar:100.0f];
	
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glTranslatef(0, 0, -5.99f);	
	
	GLfloat LightPosition[]= { 2.0, 3.5, 5.5f, 1.0f };	
	glLightfv(GL_LIGHT1, GL_POSITION, LightPosition);	
	
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	
	glBindTexture(GL_TEXTURE_2D, beginTexture);	
	
	glNormalPointer(GL_FLOAT, 0, normals);
	glEnableClientState(GL_NORMAL_ARRAY);
	
	glVertexPointer(3, GL_FLOAT, 0, vertices);	
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glDrawElements(GL_TRIANGLE_STRIP, indicesCount, GL_UNSIGNED_SHORT, indices);	
	
	
	
	glDisable(GL_LIGHTING);
	glEnable(GL_CULL_FACE);
	
	GLfloat vertices2[] = {
        -oglWidth * 0.5, -oglHeight * 0.5,
		oglWidth * 0.5, -oglHeight * 0.5,
        -oglWidth * 0.5,  oglHeight * 0.5,
		oglWidth * 0.5, oglHeight * 0.5,
    };
    	
    glVertexPointer(2, GL_FLOAT, 0, vertices2);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, &basicTexCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
		
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 	
	
	glPushMatrix();
	// begin view
	glBindTexture(GL_TEXTURE_2D, endTexture);	
    glTranslatef(0, 0, -6.0);
	glColor4f(1, 1, 1, 1.0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();	
}

- (void)computeNormals {
	// computing normals (Jails code)
	GLfloat *idx[5];
	GLfloat v[4][3];
	GLfloat norm1[3], norm2[3], normX[3], normY[3], normXY[3];
	for (int x = 1; x < NUMBER_OF_VERTICES_X - 1; x++) {
		for (int y = 1; y < NUMBER_OF_VERTICES_Y - 1; y++) {			
			
			idx[0] = vertices + ((x - 1) * 3) + (NUMBER_OF_VERTICES_X * 3)  * y;
			idx[1] = vertices + ((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3)  * y;
			idx[2] = vertices + (x * 3) + (NUMBER_OF_VERTICES_X * 3)  * (y - 1);
			idx[3] = vertices + (x * 3) + (NUMBER_OF_VERTICES_X * 3)  * (y + 1);
			idx[4] = vertices + (x * 3) + (NUMBER_OF_VERTICES_X * 3)  * y;
			
			for (int i = 0; i < 4; i++) {
				v[i][0] = (idx[i])[0] - (idx[4])[0];
				v[i][1] = (idx[i])[1] - (idx[4])[1];
				v[i][2] = (idx[i])[2] - (idx[4])[2];
			}
			
			// x part
			
			norm1[0] = v[0][2];
			norm1[1] = 0;
			norm1[2] = -v[0][0];			
			//[self normalizeToVector:norm1 fromVector:norm1];
			
			norm2[0] = -v[1][2];
			norm2[1] = 0;
			norm2[2] = v[1][0];
			//[self normalizeToVector:norm2 fromVector:norm2];			
			
			normX[0] = norm1[0] + norm2[0];
			normX[1] = norm1[1] + norm2[1];
			normX[2] = norm1[2] + norm2[2];
			
			//[self normalizeToVector:normX fromVector:normX];
			
			// y part
			
			norm1[0] = 0;
			norm1[1] = v[2][2];
			norm1[2] = -v[2][1];
			//[self normalizeToVector:norm1 fromVector:norm1];			
			
			norm2[0] = 0;
			norm2[1] = -v[3][2];
			norm2[2] = v[3][1];
			//[self normalizeToVector:norm2 fromVector:norm2];			
			
			normY[0] = norm1[0] + norm2[0];
			normY[1] = norm1[1] + norm2[1];
			normY[2] = norm1[2] + norm2[2];
			
			//[self normalizeToVector:normY fromVector:normY];
			
			// gradient
			
			normXY[0] = normX[0] + normY[0];
			normXY[1] = normX[1] + normY[1];
			normXY[2] = normX[2] + normY[2];
			
			//			[self normalizeToVector:normXY fromVector:normXY];
			
			normals[(x * 3) + (NUMBER_OF_VERTICES_X * 3)  * y] = normXY[0];
			normals[(x * 3) + (NUMBER_OF_VERTICES_X * 3)  * y + 1] = normXY[1];
			normals[(x * 3) + (NUMBER_OF_VERTICES_X * 3)  * y + 2 ] = normXY[2];
		}
	}
}


- (void)punchAtPoint:(CGPoint)punchPoint withTime:(NSTimeInterval)frameTime {
	GLfloat punchSize = 5;
	GLfloat punchStrength = 0.2;
	
	GLfloat centerX, centerY, trX, trY, dist;
	short posX, posY, radius;
	
	centerX = (punchPoint.x / width) * oglWidth;
	centerY = ((height - punchPoint.y) / height) * oglHeight;
	
	posX = round((punchPoint.x / width) * NUMBER_OF_VERTICES_X);
	posY = round(((height -punchPoint.y) / height) * NUMBER_OF_VERTICES_Y);
	
	radius = round((punchSize / oglWidth) * NUMBER_OF_VERTICES_X);
	
	for (int x = posX - radius; x < posX + radius; x++) {
		for (int y = posY - radius; y < posY + radius; y++) {
			if ((x < 1) || (x > NUMBER_OF_VERTICES_X - 2)) continue;
			if ((y < 1) || (y > NUMBER_OF_VERTICES_Y - 2)) continue;
			trX = (x / (float)NUMBER_OF_VERTICES_X) * oglWidth;
			trY = (y / (float)NUMBER_OF_VERTICES_Y) * oglHeight;
			dist = sqrt(pow(centerX - trX, 2) + pow(centerY - trY, 2));
			
			GLfloat strength = sin(M_PI * dist / (punchSize * 0.7)) * punchStrength * frameTime;
			//((PUNCH_SIZE * 0.5) - dist) * PUNCH_STRENGTH;
			if (strength < 0) strength = 0;
			velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X + 2] += strength; //(1 - sin(1.07f * dist / (PUNCH_SIZE*0.7))) * 0.5f;
			
		}
	}
}


- (BOOL)calc:(NSTimeInterval)frameTime {
	remainingCalcTime += frameTime;

	animationTime += frameTime;
	
	float calcTime = 0.012;
			
	BOOL finished = NO;
	
	if (remainingCalcTime > 0.005 && remainingCalcTime < calcTime) {
		calcTime = remainingCalcTime;
	}

	while (remainingCalcTime >= calcTime) {
		remainingCalcTime -= calcTime;
		finished = YES;

		/*if (random() % 20 == 1) {
			[self punchAtPoint:CGPointMake(random() % ((int)roundf(width) - 10) + 5, random() % ((int)roundf(height) - 10) + 5) withTime:0.1];
		}*/	
			
		Vector3 center, bottom, right, vel, v;
		GLfloat l;
		
		GLfloat originalLength = 0.11;
		
		for (int x = 0; x < NUMBER_OF_VERTICES_X; x++) {
			for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
				center.x = vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 0]; 
				center.y = vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 1]; 
				center.z = vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2]; 
				
				vel.x = velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X];
				vel.y = velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X + 1];
				vel.z = velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X + 2];
				
				if (x != NUMBER_OF_VERTICES_X - 1) {
					right.x = vertices[((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 0];			
					right.y = vertices[((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 1];			
					right.z = vertices[((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2];
					
					v = substractVectors(right, center);
					l = vectorLength(v);
					if (l > 0) {
						multiplyVector(&v, 1 / l);
						multiplyVector(&v, -(originalLength - l) * 0.48);
						addVectors(&vel, v);
						
						velocities[((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 0] -= v.x;
						velocities[((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 1] -= v.y;
						velocities[((x + 1) * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2] -= v.z;					
					}				
				}
		
				if (y != NUMBER_OF_VERTICES_Y - 1) {		
					bottom.x = vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * (y + 1) + 0];			
					bottom.y = vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * (y + 1) + 1];	
					bottom.z = vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * (y + 1) + 2];
					
					v = substractVectors(bottom, center);
					l = vectorLength(v);
					if (l > 0) {			
						multiplyVector(&v, 1 / l);
						multiplyVector(&v, -(originalLength - l) * 0.48);
						addVectors(&vel, v);
						
						velocities[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * (y + 1) + 0] -= v.x;
						velocities[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * (y + 1) + 1] -= v.y;
						velocities[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * (y + 1) + 2] -= v.z;					
					}				
				}
							
				vel.x -= 0.0007;
				vel.z += (random() / (float)RAND_MAX) * 0.001 - 0.0005;
				vel.x += (random() / (float)RAND_MAX) * 0.001 - 0.0005;
				vel.y += (random() / (float)RAND_MAX) * 0.001 - 0.0005;
				
				if (y > 10 && x > NUMBER_OF_VERTICES_X - 10) {
					GLfloat vx = x * x  * 0.0000008;
					GLfloat vy = y * y * 0.0000008;
					vel.x -= vx;
					vel.y -= vy;
					vel.z += (vx + vy);
				}
				
				
				// friction
				multiplyVector(&vel, 0.98);
							
				velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X] = vel.x;
				velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X + 1] = vel.y;
				velocities[x * 3 + y * 3 * NUMBER_OF_VERTICES_X + 2] = vel.z;			
			}
		}
		
		
		
		for (int x = 1; x < NUMBER_OF_VERTICES_X; x++) {
			for (int y = 0; y < NUMBER_OF_VERTICES_Y; y++) {
				vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 0] += velocities[x * 3 + y * 3 * (NUMBER_OF_VERTICES_X) + 0] * 0.8;			
				vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 1] += velocities[x * 3 + y * 3 * (NUMBER_OF_VERTICES_X) + 1] * 0.8;			
				vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2] += velocities[x * 3 + y * 3 *(NUMBER_OF_VERTICES_X) + 2] * 0.8;
				if (vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2] < 0) vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 2] = 0;
				
				if (vertices[(x * 3) + (NUMBER_OF_VERTICES_X * 3) * y + 0] > -oglWidth * 0.5) finished = NO;
			}
		}
	}
	
	[self computeNormals];
	
	/*
	if (animationTime > 1.8) {
		return YES;
	}
	*/
	 
	return finished;
}




- (void)dealloc {
	
	free(texCoords);
	free(normals);
	free(velocities);
	free(vertices);
	free(indices);
	[super dealloc];
}

@end