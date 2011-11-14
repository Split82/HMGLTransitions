//
//  CubeTransition.h
//  HMGLTransitions
//
//  Created by Patrick Pietens on 11/14/11.
//  Copyright (c) 2011 PatrickPietens.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMGLTransition.h"

typedef enum {
	CubeTransitionRight,	
	CubeTransitionLeft
} CubeTransitionType;

@interface CubeTransition : HMGLTransition
{    
	CubeTransitionType transitionType;	
	GLfloat animationTime;
}

@property (nonatomic, assign) CubeTransitionType transitionType;

@end
