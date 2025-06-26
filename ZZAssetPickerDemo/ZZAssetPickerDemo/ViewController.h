//
//  ViewController.h
//  ZZAssetPickerDemo
//
//  Created by 孔维锐 on 6/14/25.
//

#import <UIKit/UIKit.h>

#define ZZAP_RUN_ON_MAIN_ASYNC(block) \
    do { \
        if ([NSThread isMainThread]) { \
            block(); \
        } else { \
            dispatch_async(dispatch_get_main_queue(), block); \
        } \
    } while (0)


@interface ViewController : UIViewController


@end

