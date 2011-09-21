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

#import "RootViewController.h"

#import "Switch3DTransition.h"
#import "FlipTransition.h"
#import "RotateTransition.h"
#import "ClothTransition.h"
#import "DoorsTransition.h"

#import "ModalViewController.h"

@interface RootViewController()

@property (nonatomic, retain) HMGLTransition *transition;

@end


@implementation RootViewController

@synthesize view1;
@synthesize view2;

@synthesize transition;

#pragma mark -
#pragma mark UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	
		Switch3DTransition *t1 = [[[Switch3DTransition alloc] init] autorelease];
		t1.transitionType = Switch3DTransitionLeft;
		
		FlipTransition *t2 = [[[FlipTransition alloc] init] autorelease];
		t2.transitionType = FlipTransitionRight;		
		
		transitionsArray = [[NSArray alloc] initWithObjects:
							[[[Switch3DTransition alloc] init] autorelease],
							t1,
							[[[ClothTransition alloc] init] autorelease],							
							[[[FlipTransition alloc] init] autorelease],
							t2,
							[[[RotateTransition alloc] init] autorelease],
							[[[DoorsTransition alloc] init] autorelease],
							nil];
		
		transitionsNamesArray = [[NSArray alloc] initWithObjects:
								 @"Switch 3D right",
								 @"Switch 3D left",
								 @"Cloth",
								 @"Flip left",
								 @"Flip right",
								 @"Rotate",
								 @"Doors",
								 nil];
								 
		
		self.transition = [transitionsArray objectAtIndex:0];
		
	}
	return self;
}

- (void)viewDidLoad {
	
	// Creating singleton of transition manager here helps to reduce lag when showing first transition.
	[HMGLTransitionManager sharedTransitionManager];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Transitions
- (void)switchToView2 {
	
	UIView *containerView = view1.superview;

	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:containerView];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view2.frame = view1.frame;
	[view1 removeFromSuperview];
	[containerView addSubview:view2];
	
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

- (void)switchToView1 {
	
	UIView *containerView = view2.superview;	

	// Set transition
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	[[HMGLTransitionManager sharedTransitionManager] beginTransition:containerView];
	
	// Here you can do whatever you want except changing position, size or transformation of container view, or removing it from view hierarchy.
	view1.frame = view2.frame;
	[view2 removeFromSuperview];	
	[containerView addSubview:view1];
	
	// Commit transition
	[[HMGLTransitionManager sharedTransitionManager] commitTransition];
}

#pragma mark -
#pragma mark ModalController delegate
- (void)modalControllerDidFinish:(ModalViewController *)modalController {

	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];		
	[[HMGLTransitionManager sharedTransitionManager] dismissModalViewController:modalController];
}

#pragma mark -
#pragma mark Actions
- (IBAction)viewTransitionButtonPressed:(id)sender {
	UIButton *button = (UIButton*)sender;
	
	// view transition to view1 or view2 depending on actual view
	if (button.superview == view1) {
		[self switchToView2];
	}
	else {
		[self switchToView1];
	}
}

- (IBAction)modalPresentationButtonPressed:(id)sender {
	
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];	
	
	ModalViewController *newController;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		newController = [[ModalViewController alloc] initWithNibName:@"ModalViewController-iPad" bundle:nil];
	}
	else {
		newController = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
	}
	newController.delegate = self;
	
	[[HMGLTransitionManager sharedTransitionManager] presentModalViewController:newController onViewController:self];
	
	[newController release];
}

#pragma mark -
#pragma mark TableView delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [transitionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([transitionsArray objectAtIndex:indexPath.row] == transition) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedTransitionIdx = indexPath.row;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.textLabel.text = [transitionsNamesArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row != selectedTransitionIdx) {
		
		self.transition = [transitionsArray objectAtIndex:indexPath.row];		
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, [NSIndexPath indexPathForRow:selectedTransitionIdx inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark -
#pragma mark Memory
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
	[transitionsArray release];
	[transition release];
	
	[view1 release];
	[view2 release];
	
    [super dealloc];
}

@end
