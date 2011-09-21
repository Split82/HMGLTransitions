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

@property (nonatomic, retain) UIViewController *oldController;
@property (nonatomic, retain) UIViewController *currentController;

@end


@implementation HMGLTransitionManager

@synthesize transitionView;
@synthesize containerView;

@synthesize oldController;
@synthesize currentController;

#pragma mark -
#pragma mark Singleton

static HMGLTransitionManager *sharedTransitionManager = nil;

- (HMGLTransitionManager*)init {
	if (self = [super init]) {
		tempOverlayView = [[UIImageView alloc] init];
		tempOverlayView.transform = CGAffineTransformScale(tempOverlayView.transform, 1, -1);		
		
		transitionType = HMGLTransitionTypeNone;
		
		// Just create transition view.
		[self transitionView];
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
	
	transitionType = HMGLTransitionTypeViewTransition;
	
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
	NSAssert(transitionType == HMGLTransitionTypeViewTransition, @"transitionType has changed between beginTransition / commitTransition");
	
	// create end texture
	[self.transitionView createEndTextureWithView:containerView];

	// transition view
	[containerView addSubview:transitionView];
	
	// add temp overlay view
	tempOverlayView.frame = containerView.bounds;
	[containerView insertSubview:tempOverlayView belowSubview:transitionView];	
	
	[transitionView startAnimation];
}

- (void)switchViewControllers {
	
	NSAssert(self.transitionView.transition, @"Transition not set.");
	
	transitionView.transform = CGAffineTransformIdentity;
	tempOverlayView.transform = CGAffineTransformIdentity;
	
	// transition view
	[self.transitionView reset];
	self.transitionView.transform = oldController.view.transform;
	self.transitionView.frame = oldController.view.frame;
	[transitionView layoutSubviews];
	
	// create begin texture
	UIImage *image = [transitionView createBeginTextureWithView:oldController.view];
	
	// temp overlay image
	tempOverlayView.image = image;
					
	// create end texture
	currentController.view.transform = oldController.view.transform;	
	currentController.view.frame = oldController.view.frame;
	[self.transitionView createEndTextureWithView:currentController.view];
	
	// transition view
	[oldController.view.superview addSubview:transitionView];
	
	// add temp overlay view
	CGRect rect = oldController.view.frame;
	
	// temp overlay view
	tempOverlayView.contentMode = UIViewContentModeBottomLeft;
	tempOverlayView.transform = oldController.view.transform;	
	tempOverlayView.transform = CGAffineTransformScale(tempOverlayView.transform, 1, -1);			
	tempOverlayView.frame = rect;	
	[oldController.view.superview insertSubview:tempOverlayView belowSubview:transitionView];	
	
	[transitionView startAnimation];	
}

- (void)presentModalViewController:(UIViewController*)modalViewController onViewController:(UIViewController*)viewController {

	transitionType = HMGLTransitionTypeControllerPresentation;
	self.oldController = viewController;
	self.currentController = modalViewController;
	[self switchViewControllers];
}

- (void)dismissModalViewController:(UIViewController*)modalViewController {

	transitionType = HMGLTransitionTypeControllerDismission;
	self.oldController = modalViewController;
	if ([modalViewController respondsToSelector:@selector(presentingViewController)]) {
        self.currentController = [modalViewController presentingViewController];
    }
    else {
        self.currentController = modalViewController.parentViewController;
    }
	[self switchViewControllers];
}

- (void)transitionViewDidFinishTransition:(HMGLTransitionView*)_transitionView {

	// finish transition
	[transitionView removeFromSuperview];
	[tempOverlayView removeFromSuperview];
	
	// view controllers
	if (transitionType == HMGLTransitionTypeControllerPresentation) {
		[oldController presentModalViewController:currentController animated:NO];
	}
	else if (transitionType == HMGLTransitionTypeControllerDismission) {
		[oldController dismissModalViewControllerAnimated:NO];
	}	
	
	// transition type
	transitionType = HMGLTransitionTypeNone;
}

#pragma mark -
#pragma mark Memory
- (void)dealloc {
	[tempOverlayView release];
	[containerView release];
	[transitionView release];
	
	[oldController release];
	[currentController release];
	
	[super dealloc];
}

@end
