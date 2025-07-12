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

static inline id _Nullable ZZAPSafeValue(id _Nullable value) {
    return (value == (id)[NSNull null]) ? nil : value;
}


@interface ViewController () <ZZAPAssetSelectionDelegate>

@property (nonatomic, strong) ZZAssetPickerViewController *assetPicker;
@property (nonatomic, assign) BOOL toastEnabled;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(handleSelectionDidChange:)
                   name:@"ZZAPSelectionDidChangeNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(handleValidationDidEnd:)
                   name:@"ZZAPValidationDidEndNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(handleValidationDidStart:)
                   name:@"ZZAPValidationDidStartNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(handleValidationProgress:)
                   name:@"ZZAPValidationProgressNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(handleValidationShouldStop:)
                   name:@"ZZAPValidationShouldStopNotification"
                 object:nil];
    
    ZZAssetPickerConfiguration *configuration = [[ZZAssetPickerConfiguration alloc] init];
    
    ZZAssetPickerResourceConfiguration *resourceConfig = [ZZAssetPickerResourceConfiguration.alloc init];
    resourceConfig.thumbnailQuality = ZZAPThumbnailImageQualityMedium;
    configuration.resourceConfig = resourceConfig;
    
    ZZAssetPickerUserInterfaceConfiguration *userInterfaceConfig = [[ZZAssetPickerUserInterfaceConfiguration alloc] init];
    userInterfaceConfig.__unsafe_tabTypes = [[NSArray alloc] initWithObjects:@(ZZAPTabTypeAll), @(ZZAPTabTypeVideos), @(ZZAPTabTypePhotos), @(ZZAPTabTypeLivePhotos), nil];
    userInterfaceConfig.mediaSubtypeBadgeOption = ZZAPMediaSubtypeBadgeOptionLivePhoto;
    configuration.userInterfaceConfig = userInterfaceConfig;
    
    
    ZZAssetPickerSelectionConfiguration *selectoinConfiguration = [[ZZAssetPickerSelectionConfiguration alloc] init];
    selectoinConfiguration.selectionMode = ZZAPSelectionModeMultipleCompact;
    selectoinConfiguration.maximumSelection = 99;
    selectoinConfiguration.minimumSize = CGSizeMake(720, 1280);
    selectoinConfiguration.maximumSize = CGSizeMake(8192, 8192);
    selectoinConfiguration.minimumDuration = 3;
    selectoinConfiguration.maximumDuration = 60;
    selectoinConfiguration.requireFaces = NO;
    selectoinConfiguration.requireQrCodes = NO;
    configuration.selectionConfig = selectoinConfiguration;
    
    ZZAssetPickerValidationConfiguration *extraValidationConfig = [[ZZAssetPickerValidationConfiguration alloc] init];
    extraValidationConfig.extraRules = [NSArray arrayWithObjects:[ZZAPDurationRule greaterThanWithDuration:1], nil];
    configuration.extraValidationConfig = extraValidationConfig;
    
    
    self.assetPicker = [[ZZAssetPickerViewController alloc] initWithConfig:configuration];
    self.assetPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:self.assetPicker animated:YES completion:nil];
    });
}

// Selection changed
- (void)handleSelectionDidChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary<NSNumber *, id<ZZAPAsset>> *selectedAssets = ZZAPSafeValue(userInfo[@"selectedAssets"]);
    id sender = ZZAPSafeValue(userInfo[@"sender"]);

    NSString *message = [NSString stringWithFormat:@"✅ Selection changed from: %@\nSelected Assets Count: %lu",
                         sender ?: @"(null)", (unsigned long)selectedAssets.count];
    ZZAP_RUN_ON_MAIN_ASYNC(^{
        if (self.toastEnabled) {
            [self.assetPicker.view makeToast:message];
        }
    });
}

// Validation ended
- (void)handleValidationDidEnd:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    id<ZZAPAsset> asset = ZZAPSafeValue(userInfo[@"asset"]);
    ZZAPAssetValidationFailure *failure = ZZAPSafeValue(userInfo[@"failure"]);
    id sender = ZZAPSafeValue(userInfo[@"sender"]);

    NSString *message = [NSString stringWithFormat:failure ? @"❌ Selection failed for asset: %@\nReason: %@\n\nFrom: %@" : @"✅ Selection succeed for asset: %@\nReason: %@\n\nFrom: %@" ,
                         asset.id ?: @"(nil)", failure.message ?: @"(nil)", sender ?: @"(nil)"];
    ZZAP_RUN_ON_MAIN_ASYNC(^{
        if (self.toastEnabled) {
            [self.assetPicker.view makeToast:message];
        }
    });
}

// Validation started
- (void)handleValidationDidStart:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    id<ZZAPAsset> asset = ZZAPSafeValue(userInfo[@"asset"]);
    id sender = ZZAPSafeValue(userInfo[@"sender"]);

    NSString *message = [NSString stringWithFormat:@"🟢 Validation started for asset: %@\nFrom: %@",
                         asset.id ?: @"(nil)", sender ?: @"(nil)"];
    ZZAP_RUN_ON_MAIN_ASYNC(^{
        if (self.toastEnabled) {
            [self.assetPicker.view makeToast:message];
        }
    });
}

// Validation progress
- (void)handleValidationProgress:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    id<ZZAPAsset> asset = ZZAPSafeValue(userInfo[@"asset"]);
    NSNumber *current = ZZAPSafeValue(userInfo[@"current"]);
    NSNumber *total = ZZAPSafeValue(userInfo[@"total"]);
    id sender = ZZAPSafeValue(userInfo[@"sender"]);

    NSString *message = [NSString stringWithFormat:@"🔄 Validation progress for asset: %@\n%ld / %ld\nFrom: %@",
                         asset.id ?: @"(nil)",
                         (long)[current integerValue], (long)[total integerValue],
                         sender ?: @"(nil)"];
    ZZAP_RUN_ON_MAIN_ASYNC(^{
        if (self.toastEnabled) {
            [self.assetPicker.view makeToast:message];
        }
    });
}

// Validation should stop
- (void)handleValidationShouldStop:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    id<ZZAPAsset> asset = ZZAPSafeValue(userInfo[@"asset"]);
    NSNumber *shouldStop = ZZAPSafeValue(userInfo[@"shouldStop"]);
    id sender = ZZAPSafeValue(userInfo[@"sender"]);

    NSString *message = [NSString stringWithFormat:@"⏹️ Validation should stop for asset: %@\nShould Stop: %@\nFrom: %@",
                         asset.id ?: @"(nil)",
                         [shouldStop boolValue] ? @"YES" : @"NO",
                         sender ?: @"(nil)"];
    ZZAP_RUN_ON_MAIN_ASYNC(^{
        if (self.toastEnabled) {
            [self.assetPicker.view makeToast:message];
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
