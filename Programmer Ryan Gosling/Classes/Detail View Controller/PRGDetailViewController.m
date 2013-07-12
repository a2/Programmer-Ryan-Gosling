//
//  PRGDetailViewController.m
//  Programmer Ryan Gosling
//
//  Created by Alexsander Akers on 7/11/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "PRGDetailViewController.h"

@interface PRGDetailViewController ()

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation PRGDetailViewController

- (void)configureWithURL:(NSURL *)URL
{
	if (self.isViewLoaded) {
		[self.imageView setImageWithURL:URL];
	} else {
		self.URL = URL;
	}
}
- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (error) {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
	} else {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Image Saved", nil) message:NSLocalizedString(@"The image was successfully saved to your Photos.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
	}
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
	UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self.view addGestureRecognizer:tap];
	
	if (self.URL) [self.imageView setImageWithURL:self.URL];
}

@end
