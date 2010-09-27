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

#import "HMGLTransitionView.h"

@interface HMGLTransitionView()

- (void)deleteFramebuffer;
- (void)setContext:(EAGLContext *)newContext;
- (void)setFramebuffer;

@end


@implementation HMGLTransitionView

@synthesize textureWidthNormalized;
@synthesize textureHeightNormalized;
@synthesize animating;
@synthesize transition;
@dynamic animationFrameInterval;
@synthesize delegate;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark UIView
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = YES;
		self.opaque = YES;
		
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		/*EAGLContext *newContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (!newContext)
		{*/
		EAGLContext	*newContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		//}
		[self setContext:newContext];
		[newContext release];
		[self setFramebuffer];

		framesCount = 0;
		
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
    }

    return self;
}

#pragma mark -
#pragma mark OpenGL
- (EAGLContext *)context {
    return context;
}

- (void)setContext:(EAGLContext *)newContext {
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        [context release];
        context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer {
    if (context && !defaultFramebuffer)
    {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		
		glGenRenderbuffersOES(1, &depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);				
       	
		
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer {
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
		
        if (depthRenderbuffer)
        {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }		
    }
}

- (void)setFramebuffer {
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        glViewport(0, 0, backingWidth, backingHeight);
    }
}

- (BOOL)presentFramebuffer {
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews {
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

- (void)drawView:(id)sender {

	if (transition == nil) {
		return;
	}
		
	[self setFramebuffer];
	
	// frame time calculation
	NSTimeInterval frameTime;
	thisTime = [NSDate timeIntervalSinceReferenceDate];
	if (framesCount == 0) {
		// show only if view is going to be updated
		self.hidden = NO;

		// first frame should the same as beginning
		lastTime = thisTime;		
	}

	frameTime = thisTime - lastTime;
	lastTime = thisTime;
		
	// maximum frame time
	if (frameTime > 0.05f) {
		frameTime = 0.05f;
	}	
				
	// initialize transition in first frame
	if (framesCount == 0) {
		
		// Transition begining
		[transition initTransition];				
	}
	
	BOOL finished = NO;
	
	// Call transition
	finished = [transition calc:frameTime];
	[transition drawWithBeginTexture:beginTexture endTexture:endTexture];
		
	[self presentFramebuffer];
	
	framesCount++;
	
	if (finished) {
		[self stopAnimation];
	}
}

#pragma mark -
#pragma mark Texture
- (GLuint)genTexture {
	GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	return texture;
}

- (void)deleteTexture:(GLuint*)texture {
	if (texture == 0) {
		return;
	}
	
	glDeleteTextures(1, texture);
	(*texture) = 0;
}

- (UIImage*)updateTexture:(GLuint)texture withView:(UIView*)view needsUIImage:(BOOL)needsUIImage {
	
	// compute width and height of texture
	GLfloat textureWidth = 16;
	while (textureWidth < view.frame.size.width && textureWidth < 1024) {
		textureWidth *=2;
	}
	
	textureWidthNormalized = view.frame.size.width / textureWidth;
	
	GLfloat textureHeight = 16;
	while (textureHeight < view.frame.size.height && textureHeight < 1024) {
		textureHeight *=2;
	}	

	textureHeightNormalized = view.frame.size.height / textureHeight;	
	
	
	CGAffineTransform transform = [view.layer affineTransform];
	
	// set orientation of transition and TextCoords
	GLfloat w, h;
	
	if (transform.a == 0) {
		w = textureHeightNormalized;
		h = 1 - textureWidthNormalized;
	}
	else {
		w = textureWidthNormalized;
		h = 1 - textureHeightNormalized;		
	}
	
	TransitionTexCoords tc = {
		0.0, h,
		w, h,
		0.0, 1.0,
		w, 1.0,
	};
	transition.basicTexCoords = tc;

	
	// Prepare BitmapContext
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	GLubyte *textureData = malloc(textureWidth * textureHeight * 4);
	memset_pattern4(textureData, "\0\0\0\0", textureWidth * textureHeight * 4);
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * textureWidth;
	NSUInteger bitsPerComponent = 8;
	CGContextRef bitmapContext = CGBitmapContextCreate(textureData, textureWidth, textureHeight, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
		
	// draw layer
	[view.layer renderInContext:bitmapContext];
	
	// create image if needed
	UIImage *image = nil;
	if (needsUIImage) {
		CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
		image = [UIImage imageWithCGImage:cgImage];
		CGImageRelease(cgImage);
	}
		
	CGContextRelease(bitmapContext);
	
	// set data for texture
	glBindTexture(GL_TEXTURE_2D, texture);
	// set bitmap data into texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);	
	// Don't need this data anymore
	free(textureData);
	
	return image;
}

- (UIImage*)createBeginTextureWithView:(UIView*)view {
	
	if (beginTexture == 0) {
		beginTexture = [self genTexture];
	}
	
	return [self updateTexture:beginTexture withView:view needsUIImage:YES];
}

- (void)createEndTextureWithView:(UIView*)view {
	
	if (endTexture == 0) {
		endTexture = [self genTexture];
	}
	
	[self updateTexture:endTexture withView:view needsUIImage:NO];
}

#pragma mark -
#pragma mark AnimationFrameInterval
- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

#pragma mark -
#pragma mark Actions
- (void)startAnimation {
    if (!animating && transition) {
        if (displayLinkSupported) {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
		
        animating = TRUE;
    }
}

- (void)stopAnimation {
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
		
		[delegate transitionViewDidFinishTransition:self];

        animating = FALSE;
    }
}

- (void)reset {
	self.hidden = YES;
	framesCount = 0;
}

#pragma mark -
#pragma mark Memory
- (void)dealloc {
	
	[self deleteTexture:&beginTexture];
	[self deleteTexture:&endTexture];
	
    [self deleteFramebuffer];    
    [context release];
	
	[transition release];

    [super dealloc];
}

@end
