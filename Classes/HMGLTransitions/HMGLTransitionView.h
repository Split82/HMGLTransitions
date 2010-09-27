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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "HMGLTransition.h"

@protocol HMGLTransitionViewDelegate;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface HMGLTransitionView : UIView {    

    EAGLContext *context;
	
    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
	
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
	GLuint depthRenderbuffer;

	//
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
	
	// transition
	HMGLTransition *transition;
	
	// textures
	GLuint beginTexture;
	GLuint endTexture;
	
	GLfloat textureWidthNormalized;
	GLfloat textureHeightNormalized;
	
	// frame times
	NSTimeInterval lastTime, thisTime, calcTime;
	
	// delegate
	id <HMGLTransitionViewDelegate> delegate;
	
	// frames frame
	int framesCount;
}

@property (nonatomic, readonly) GLfloat textureWidthNormalized;
@property (nonatomic, readonly) GLfloat textureHeightNormalized;

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) HMGLTransition *transition;
@property (nonatomic, assign) id <HMGLTransitionViewDelegate> delegate;

- (void)startAnimation;
- (void)stopAnimation;
- (void)reset;

- (UIImage*)createBeginTextureWithView:(UIView*)view;
- (void)createEndTextureWithView:(UIView*)view;

@end


@protocol HMGLTransitionViewDelegate <NSObject>

- (void)transitionViewDidFinishTransition:(HMGLTransitionView*)transitionView;

@end

