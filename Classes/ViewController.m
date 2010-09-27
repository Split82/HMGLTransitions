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

#import "ViewController.h"

#import "HMGLTransitionManager.h"

#import "Switch3DTransition.h"
#import "FlipTransition.h"
#import "RotateTransition.h"
#import "ClothTransition.h"

#import "ModalController.h"

@implementation ViewController

@synthesize view1;
@synthesize view2;

- (void)viewDidLoad {
	
	// Creating singleton of transition manager in this place helps to reduce lag when showing first transition.
	[HMGLTransitionManager sharedTransitionManager];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

// transitions
- (void)switch3DTransitionRight {

	Switch3DTransition *transition = [[[Switch3DTransition alloc] init] autorelease];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:self.view];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view2.frame = view1.frame;
	[view1 removeFromSuperview];
	[self.view addSubview:view2];
	
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)switch3DTransitionLeft {
	
	// Set up transition
	Switch3DTransition *transition = [[[Switch3DTransition alloc] init] autorelease];
	transition.transitionType = Switch3DTransitionLeft;
	
	// Set transition
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	// Begin transition on container view
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:self.view];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view1.frame = view2.frame;
	[view2 removeFromSuperview];	
	[self.view addSubview:view1];
	
	// Commit transition
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)flipTransitionRight {
	
	FlipTransition *transition = [[[FlipTransition alloc] init] autorelease];
	transition.transitionType = FlipTransitionRight;
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:self.view];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view2.frame = view1.frame;
	[view1 removeFromSuperview];
	[self.view addSubview:view2];
	
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)flipTransitionLeft {
	
	FlipTransition *transition = [[[FlipTransition alloc] init] autorelease];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:self.view];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view1.frame = view2.frame;
	[view2 removeFromSuperview];
	[self.view addSubview:view1];
	
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)rotateToView2 {
	
	RotateTransition *transition = [[[RotateTransition alloc] init] autorelease];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:self.view];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view2.frame = view1.frame;
	[view1 removeFromSuperview];
	[self.view addSubview:view2];
	
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)rotateToView1 {
	
	RotateTransition *transition = [[[RotateTransition alloc] init] autorelease];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:self.view];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view1.frame = view2.frame;
	[view2 removeFromSuperview];
	[self.view addSubview:view1];
	
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)modalController {
	
	ClothTransition *transition = [[[ClothTransition alloc] init] autorelease];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	

	ModalController *newController;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		newController = [[ModalController alloc] initWithNibName:@"ModalController-iPad" bundle:nil];
	}
	else {
		newController = [[ModalController alloc] initWithNibName:@"ModalController" bundle:nil];
	}
	
	newController.delegate = self;
	[[HMGLTransitionManager sharedTransitionManager] presentModalViewController:newController onViewController:self];
	[ModalController release];
}

- (void)modalControllerDidFinish:(ModalController *)modalController {
	ClothTransition *transition = [[[ClothTransition alloc] init] autorelease];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	
	[[HMGLTransitionManager sharedTransitionManager] dismissModalViewController:modalController];
}


// actions
- (IBAction)button1Pressed:(id)sender {
	UIButton *button = (UIButton*)sender;
	switch (button.tag) {
		case 1: 
			[self switch3DTransitionRight];
			break;
		case 2: 
			[self flipTransitionRight];
			break;
		case 3: 
			[self rotateToView2];
			break;
		case 4:
			[self modalController];
			break;

	}
}

- (IBAction)button2Pressed:(id)sender {
	UIButton *button = (UIButton*)sender;
	switch (button.tag) {
		case 1: 
			[self switch3DTransitionLeft];
			break;
		case 2: 
			[self flipTransitionLeft];
			break;				
		case 3:
			[self rotateToView1];
			break;
	}	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	self.view1 = nil;
	self.view2 = nil;
}


- (void)dealloc {
	[view1 release];
	[view2 release];
	
    [super dealloc];
}

@end
