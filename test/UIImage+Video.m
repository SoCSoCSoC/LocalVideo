//
//  UIImage+Video.m
//  test
//
//  Created by Joe on 16/4/28.
//  Copyright © 2016年 QQ. All rights reserved.
//

#import "UIImage+Video.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (Video)

+ (UIImage *)getImage:(NSString *)videoURL

{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
    
    
    
}

@end
