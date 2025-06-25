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

@property (nonatomic, strong) ZZAssetPickerViewController *assetSelectionVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZZAssetPickerConfiguration *configuration = [[ZZAssetPickerConfiguration alloc] init];
    
    ZZAssetPickerUserInterfaceConfiguration *userInterfaceConfig = [[ZZAssetPickerUserInterfaceConfiguration alloc] init];
    userInterfaceConfig.__unsafe_tabTypes = [[NSArray alloc] initWithObjects:@(ZZAPTabTypeAll), @(ZZAPTabTypeVideos), @(ZZAPTabTypePhotos), @(ZZAPTabTypeLivePhotos), nil];
    userInterfaceConfig.mediaSubtypeBadgeOption = ZZAPMediaSubtypeBadgeOptionLivePhoto;
    configuration.userInterfaceConfig = userInterfaceConfig;
    
    
    ZZAssetPickerSelectionConfiguration *selectoinConfiguration = [[ZZAssetPickerSelectionConfiguration alloc] init];
    selectoinConfiguration.selectionMode = ZZAPSelectionModeMultipleCompact;
    selectoinConfiguration.maximumSelection = 3;
    configuration.selectionConfig = selectoinConfiguration;
    
    
    ZZAssetPickerViewController *vc = [[ZZAssetPickerViewController alloc] initWithConfig:configuration];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

@end
