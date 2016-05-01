//
//  ViewController.m
//  test
//
//  Created by Joe on 16/4/28.
//  Copyright © 2016年 QQ. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NextViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

// 照片原图路径
#define KOriginalPhotoImagePath   \[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]

// 视频URL路径
#define KVideoUrlPath   \[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]

// caches路径
#define KCachesPath   \[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface ViewController ()

@property (nonatomic, strong) NextViewController    *nextVC;
@property (nonatomic, strong) NSMutableArray        *groupArrays;
@property (nonatomic, strong) UIImageView           *litimgView1;
@property (nonatomic, strong) UIImageView           *litimgView2;
@property (nonatomic, strong) UIImageView           *litimgView3;
@property (nonatomic, strong) NSMutableArray        *urlArray;
@property (nonatomic, strong) NSMutableArray        *imgArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor orangeColor];
    
    // 初始化
    self.groupArrays = [NSMutableArray array];
    self.urlArray = [NSMutableArray array];
    self.imgArray = [NSMutableArray array];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(30, 200, 50, 50);
    btn.backgroundColor = [UIColor cyanColor];
    [btn addTarget:self action:@selector(testRun:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    // 图片或者视频的缩略图显示
    self.litimgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 120, 120)];
    self.litimgView1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickPanGestureRecognizer:)];
    [self.litimgView1 addGestureRecognizer:tap];
    [self.view addSubview:_litimgView1];
    
    self.litimgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(100, 220, 120, 120)];
    self.litimgView2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickPanGestureRecognizer:)];
    [self.litimgView2 addGestureRecognizer:tap2];
    [self.view addSubview:_litimgView2];
    
    self.litimgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(100, 340, 120, 120)];
    self.litimgView3.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickPanGestureRecognizer:)];
    [self.litimgView3 addGestureRecognizer:tap3];
    [self.view addSubview:_litimgView3];
    
    
}

- (void)testRun:(UIButton *)sender
{
    __weak ViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [weakSelf.groupArrays addObject:group];
            } else {
                [weakSelf.groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if ([result thumbnail] != nil) {
                            // 照片
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                                
                                NSDate *date= [result valueForProperty:ALAssetPropertyDate];
                                UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                NSString *fileName = [[result defaultRepresentation] filename];
                                NSURL *url = [[result defaultRepresentation] url];
                                int64_t fileSize = [[result defaultRepresentation] size];
                                [self.urlArray addObject:url];
                                [self.imgArray addObject:image];
                                NSLog(@"date = %@",date);
                                NSLog(@"fileName = %@",_imgArray);
                                NSLog(@"url = %@",_urlArray);
                                NSLog(@"fileSize = %lld",fileSize);
                                
                                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    switch (self.imgArray.count) {
                                        case 1:
                                            self.litimgView1.image = self.imgArray[0];
                                            break;
                                        case 2:
                                            self.litimgView2.image = self.imgArray[1];
                                            break;
                                        case 3:
                                            self.litimgView3.image = self.imgArray[2];
                                            break;

                                        default:
                                            break;
                                    }
                                });
                            }
                        }
                    }];
                }];
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
        {
            
            NSString *errorMessage = nil;
            
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                    break;
                    
                default:
                    errorMessage = @"Reason unknown.";
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误,无法访问!"
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil];
                [alertView show];
            });
        };
        
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}

- (void)didClickPanGestureRecognizer:(UITapGestureRecognizer *)sender
{
    NSLog(@"-------");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
