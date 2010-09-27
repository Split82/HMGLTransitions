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

#import "HMGLTransitionManager.h"

@interface HMGLTransitionManager()

@property (nonatomic, retain) HMGLTransitionView *transitionView;
@property (nonatomic, retain) UIView *containerView;

@end


@implementation HMGLTransitionManager

@synthesize transitionView;
@synthesize containerView;

#pragma mark -
#pragma mark Singleton

static HMGLTransitionManager *sharedTransitionManager = nil;

- (HMGLTransitionManager*)init {
	if (self = [super init]) {
		tempOverlayView = [[UIImageView alloc] init];
		tempOverlayView.transform = CGAffineTransformScale(tempOverlayView.transform, 1, -1);		
		
		// Just create transition view.
		self.transitionView;
	}
	return self;
}

+ (HMGLTransitionManager*)sharedTransitionManager {
	if (!sharedTransitionManager) {
		sharedTransitionManager = [[HMGLTransitionManager alloc] init];
	}
	return sharedTransitionManager;
}

#pragma mark -
#pragma mark Getters

- (HMGLTransitionView*)transitionView {
	if (!transitionView) {
		self.transitionView = [[[HMGLTransitionView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] autorelease];
		transitionView.delegate = self;
	}
	return transitionView;
}

 
#pragma mark -
#pragma mark Setters
- (void)setTransition:(HMGLTransition*)transition {
	self.transitionView.transition = transition;
}

#pragma mark -
#pragma mark Main controls
- (void)beginTransition:(UIView*)newContainerView {
			
	NSAssert(self.transitionView.transition, @"Transition must be set before calling beginTransition.");
	
	transitionView.transform = CGAffineTransformIdentity;
	tempOverlayView.transform = CGAffineTransformIdentity;
	tempOverlayView.transform = CGAffineTransformScale(tempOverlayView.transform, 1, -1);	
	tempOverlayView.contentMode = UIViewContentModeBottomLeft;

	// container
	self.containerView = newContainerView;
	
	// transition view
	[self.transitionView reset];
	self.transitionView.frame = containerView.bounds;
	[transitionView layoutSubviews];
	
	// create begin texture
	UIImage *image = [transitionView createBeginTextureWithView:containerView];
	
	// temp overlay image
	tempOverlayView.image = image;
}

- (void)commitTransition {
	
	NSAssert(containerView, @"Container view not set.");
	NSAssert(self.transitionView.transition, @"Transition not set.");
	
	// create end texture
	[self.transitionView createEndTextureWithView:containerView];

	// transition view
	[containerView addSubview:transitionView];
	
	// add temp overlay view
	tempOverlayView.frame = containerView.bounds;
	[containerView insertSubview:tempOverlayView belowSubview:transitionView];	
	
	[transitionView startAnimation];
}

- (void)switchViewController:(UIViewController*)viewController1 withController:(UIViewController*)viewController2 dismiss:(BOOL)dismiss {
	
	NSAssert(self.transitionView.transition, @"Transition not set.");
	
	transitionView.transform = CGAffineTransformIdentity;
	tempOverlayView.transform = CGAffineTransformIdentity;
	
	// transition view
	[self.transitionView reset];
	self.transitionView.transform = viewController1.view.transform;
	self.transitionView.frame = viewController1.view.frame;
	[transitionView layoutSubviews];
	
	// create begin texture
	UIImage *image = [transitionView createBeginTextureWithView:viewController1.view];
	
	// temp overlay image
	tempOverlayView.image = image;
	
	// present / dismiss controller
	if (dismiss) {
		[viewController1 dismissModalViewControllerAnimated:NO];
	} 
	else {
		[viewController1 presentModalViewController:viewController2 animated:NO];
	}
	
	// create end texture
	[self.transitionView createEndTextureWithView:viewController2.view];
	
	// transition view
	[viewController2.view.superview addSubview:transitionView];
	
	// add temp overlay view
	CGRect rect = viewController2.view.frame;
	
	// temp overlay view
	tempOverlayView.contentMode = UIViewContentModeBottomLeft;
	tempOverlayView.transform = viewController2.view.transform;	
	tempOverlayView.transform = CGAffineTransformScale(tempOverlayView.transform, 1, -1);			
	tempOverlayView.frame = rect;	
	[viewController2.view.superview insertSubview:tempOverlayView belowSubview:transitionView];	
	
	[transitionView startAnimation];	
}

- (void)presentModalViewController:(UIViewController*)modalViewController onViewController:(UIViewController*)viewController {

	[self switchViewController:viewController withController:modalViewController dismiss:NO];
}

- (void)dismissModalViewController:(UIViewController*)modalViewController {
	
	[self switchViewController:modalViewController withController:modalViewController.parentViewController dismiss:YES];
}

- (void)transitionViewDidFinishTransition:(HMGLTransitionView*)_transitionView {

	[transitionView removeFromSuperview];
	[tempOverlayView removeFromSuperview];
}

#pragma mark -
#pragma mark Memory
- (void)dealloc {
	[tempOverlayView release];
	[containerView release];
	[transitionView release];
	
	[super dealloc];
}

@end
