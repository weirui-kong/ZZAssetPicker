//
//  ViewController.m
//  ZZAssetPickerDemo
//
//  Created by 孔维锐 on 6/14/25.
//

#import "ViewController.h"
@import ZZAssetPicker;
@import SnapKit;
#import "UIView+Toast.h"
@interface ViewController () <ZZAPAssetSelectionDelegate>

@property (nonatomic, strong) ZZAssetPickerViewController *assetPicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSelectionDidChange:)
                                                 name:@"ZZAPSelectionDidChangeNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSelectionDidFail:)
                                                 name:@"ZZAPSelectionDidFailNotification"
                                               object:nil];
    
    ZZAssetPickerConfiguration *configuration = [[ZZAssetPickerConfiguration alloc] init];
    
    ZZAssetPickerUserInterfaceConfiguration *userInterfaceConfig = [[ZZAssetPickerUserInterfaceConfiguration alloc] init];
    userInterfaceConfig.__unsafe_tabTypes = [[NSArray alloc] initWithObjects:@(ZZAPTabTypeAll), @(ZZAPTabTypeVideos), @(ZZAPTabTypePhotos), @(ZZAPTabTypeLivePhotos), nil];
    userInterfaceConfig.mediaSubtypeBadgeOption = ZZAPMediaSubtypeBadgeOptionLivePhoto;
    configuration.userInterfaceConfig = userInterfaceConfig;
    
    
    ZZAssetPickerSelectionConfiguration *selectoinConfiguration = [[ZZAssetPickerSelectionConfiguration alloc] init];
    selectoinConfiguration.selectionMode = ZZAPSelectionModeMultipleCompact;
    selectoinConfiguration.maximumSelection = 3;
    selectoinConfiguration.minimumSize = CGSizeMake(720, 1280);
    selectoinConfiguration.minimumDuration = 3;
    selectoinConfiguration.maximumDuration = 60;
    selectoinConfiguration.requireFaces = YES;
    selectoinConfiguration.requireQrCodes = NO;
    configuration.selectionConfig = selectoinConfiguration;
    
    
    self.assetPicker = [[ZZAssetPickerViewController alloc] initWithConfig:configuration];
    self.assetPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:self.assetPicker animated:YES completion:nil];
    });
}

- (void)handleSelectionDidChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary<NSNumber *, id<ZZAPAsset>> *selectedAssets = userInfo[@"selectedAssets"];
    id sender = userInfo[@"sender"];

    NSString *message = [NSString stringWithFormat:@"✅ Selection changed from: %@\n Selected Assets Count: %lu", sender, (unsigned long)selectedAssets.count];
    [self.assetPicker.view makeToast:message];
}

- (void)handleSelectionDidFail:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    id<ZZAPAsset> asset = userInfo[@"asset"];
    ZZAPAssetValidationFailure *failure = userInfo[@"failure"];
    id sender = userInfo[@"sender"];

    NSString *message = [NSString stringWithFormat:@"❌ Selection failed for asset: %@\nReason: %@\n\nFrom: %@", asset.id ?: @"(nil)", failure.message, sender];
    [self.assetPicker.view makeToast:message];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
