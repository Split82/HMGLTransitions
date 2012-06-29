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
#import "CubeTransition.h"
#import "FoldTransition.h"

#import "ModalViewController.h"

@interface RootViewController()

@property (nonatomic, strong) HMGLTransition *transition;

@end


@implementation RootViewController

@synthesize view1;
@synthesize view2;

@synthesize transition;

#pragma mark -
#pragma mark UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	
		Switch3DTransition *t1 = [[Switch3DTransition alloc] init];
		t1.transitionType = Switch3DTransitionLeft;
		
		FlipTransition *t2 = [[FlipTransition alloc] init];
		t2.transitionType = FlipTransitionRight;		
        
        DoorsTransition *t3 = [[DoorsTransition alloc] init]; 
        t3.transitionType = DoorsTransitionTypeClose; 
		
        FoldTransition* tfld1 = [[FoldTransition alloc] init];
        tfld1.foldDirection = FoldDirectionRight;
        FoldTransition* tfld2 = [[FoldTransition alloc] init];
        tfld2.foldDirection = FoldDirectionLeft;
        
        FoldTransition* tufld1 = [[FoldTransition alloc] init];
        tufld1.foldDirection = FoldDirectionRight;
        tufld1.foldType = Unfold;
        FoldTransition* tufld2 = [[FoldTransition alloc] init];
        tufld2.foldDirection = FoldDirectionLeft;
        tufld2.foldType = Unfold;

		transitionsArray = [[NSArray alloc] initWithObjects:
							[[Switch3DTransition alloc] init],
							t1,
							[[ClothTransition alloc] init],							
							[[FlipTransition alloc] init],
							t2,
							[[RotateTransition alloc] init],
							[[DoorsTransition alloc] init],
                            t3, 
                            [[CubeTransition alloc] init], 
                            tfld1,
                            tfld2,
                            tufld1,
                            tufld2,
							nil];
		
		transitionsNamesArray = [[NSArray alloc] initWithObjects:
								 @"Switch 3D right",
								 @"Switch 3D left",
								 @"Cloth",
								 @"Flip left",
								 @"Flip right",
								 @"Rotate",
								 @"Opening doors",
								 @"Closing doors",
                                 @"Cube", 
								 @"Fold Right",
								 @"Fold Left",
								 @"Unfold Right",
								 @"Unfold Left",
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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



@end
