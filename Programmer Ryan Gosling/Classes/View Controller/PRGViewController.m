//
//  PRGViewController.m
//  Programmer Ryan Gosling
//
//  Created by Alexsander Akers on 7/11/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "PRGDetailViewController.h"
#import "PRGLoadMoreCell.h"
#import "PRGPhotoCell.h"
#import "PRGViewController.h"

static NSString *const PRGLoadMoreCellIdentifier = @"LoadMoreCell";
static NSString *const PRGPhotoCellIdentifier = @"PhotoCell";
static NSString *const PRGShowDetailSegueIdentifier = @"DisplayDetail";
static NSString *const PRGTumblrOAuthConsumerKey = @"rtYhQTwu2QeAzWvLXsJwuFudj6sxINfijXQ5jJtE00pplr6L8V";

@interface PRGViewController ()

@property (nonatomic, getter = isRefreshing) BOOL refreshing;
@property (nonatomic, strong) NSMutableArray *photoURLs;

@end

@implementation PRGViewController

- (void)fetch:(BOOL)clearFirst completionHandler:(void (^)(void))completionHandler
{
	NSString *urlString = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/programmerryangosling.tumblr.com/posts/photo?api_key=%@", PRGTumblrOAuthConsumerKey];
	if (!clearFirst) urlString = [urlString stringByAppendingFormat:@"&offset=%d", self.photoURLs.count];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSMutableArray *tmpPhotoURLs = [NSMutableArray arrayWithCapacity:20];
		[JSON[@"response"][@"posts"] enumerateObjectsUsingBlock:^(NSDictionary *photoDictionary, NSUInteger idx, BOOL *stop) {
			NSArray *photos = photoDictionary[@"photos"];
			NSDictionary *lastPhoto = photos.firstObject;
			NSString *urlString = lastPhoto[@"original_size"][@"url"];
			NSURL *url = [NSURL URLWithString:urlString];
			[tmpPhotoURLs addObject:url];
		}];
		
		[self.collectionView performBatchUpdates:^{
			NSUInteger photoURLsCount = self.photoURLs.count;
			if (clearFirst) {
				[self.photoURLs removeAllObjects];
				
				NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:photoURLsCount];
				for (NSUInteger i = 0; i < photoURLsCount; i++) {
					[indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
				}
				[self.collectionView deleteItemsAtIndexPaths:indexPaths];
				
				photoURLsCount = 0;
			}
			
			NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:tmpPhotoURLs.count];
			for (NSUInteger i = 0; i < tmpPhotoURLs.count; i++) {
				[indexPaths addObject:[NSIndexPath indexPathForItem:photoURLsCount + i inSection:0]];
			}
			[self.collectionView insertItemsAtIndexPaths:indexPaths];
			
			[self.photoURLs addObjectsFromArray:tmpPhotoURLs];
		} completion:^(BOOL finished) {
			if (completionHandler) completionHandler();
		}];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		NSLog(@"Error: %@", error);
		if (completionHandler) completionHandler();
	}];
	[operation start];
}
- (void)loadMoreWithCompletionHandler:(void (^)(void))completionHandler
{
	[self fetch:NO completionHandler:completionHandler];
}
- (void)refreshWithCompletionHandler:(void (^)(void))completionHandler
{
	[self fetch:YES completionHandler:completionHandler];
}
- (void)startRefresh:(UIRefreshControl *)refreshControl
{
	[self.collectionView performBatchUpdates:^{
		self.refreshing = YES;
		[self.collectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:self.photoURLs.count inSection:0] ]];
	} completion:^(BOOL finished) {
		[self refreshWithCompletionHandler:^{
			[self.collectionView performBatchUpdates:^{
				self.refreshing = NO;
				[self.collectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:self.photoURLs.count inSection:0] ]];
			} completion:nil];
		}];
	}];
}

#pragma mark - Actions

- (void)closeDetail:(UIStoryboardSegue *)segue
{
	
}

#pragma mark - <UICollectionViewControllerDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.photoURLs.count + !self.refreshing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item < self.photoURLs.count) {
		PRGPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PRGPhotoCellIdentifier forIndexPath:indexPath];
		[cell configureWithURL:self.photoURLs[indexPath.item]];
		return cell;
	} else {
		PRGLoadMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PRGLoadMoreCellIdentifier forIndexPath:indexPath];
		cell.refreshing = self.refreshing;
		cell.buttonTapped = ^(PRGRefreshFinishedBlock block) {
			[self loadMoreWithCompletionHandler:block];
		};
		
		return cell;
	}
}

#pragma mark - UIViewController

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:PRGShowDetailSegueIdentifier]) {
		PRGPhotoCell *cell = sender;
		return !cell.loading;
	} else {
		return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:PRGShowDetailSegueIdentifier]) {
		NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
		
		UINavigationController *navigationController = segue.destinationViewController;
		PRGDetailViewController *detail = navigationController.viewControllers.firstObject;
		detail.title = [NSString stringWithFormat:NSLocalizedString(@"%d of %d", nil), indexPath.item + 1, self.photoURLs.count];
		[detail configureWithURL:self.photoURLs[indexPath.item]];
	} else {
		[super prepareForSegue:segue sender:sender];
	}
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.photoURLs = [NSMutableArray arrayWithCapacity:20];
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:refreshControl];
	[self startRefresh:refreshControl];
}

@end
