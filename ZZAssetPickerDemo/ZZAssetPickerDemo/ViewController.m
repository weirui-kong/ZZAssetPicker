//
//  ViewController.m
//  ZZAssetPickerDemo
//
//  Created by 孔维锐 on 6/14/25.
//

#import "ViewController.h"
@import ZZAssetPicker;
@import SnapKit;

@interface ViewController () <ZZAPAssetSelectionDelegate>

@property (nonatomic, strong) ZZAPAssetSelectionViewController *assetSelectionVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.assetSelectionVC = [[ZZAPAssetSelectionViewController alloc] init];

    [self addChildViewController:self.assetSelectionVC];
    self.assetSelectionVC.view.frame = self.view.bounds;
    self.assetSelectionVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.assetSelectionVC.view];

    [self.assetSelectionVC didMoveToParentViewController:self];
}

@end
