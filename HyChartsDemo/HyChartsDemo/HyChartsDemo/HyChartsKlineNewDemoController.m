//
//  HyChartsKlineNewDemoController.m
//  HyChartsDemo
//
//  Created by Hy on 2018/4/19.
//  Copyright © 2018 Hy. All rights reserved.
//

#import "HyChartsKlineNewDemoController.h"
#import <HyCategoriess/HyCategories.h>
#import <HyCycleView/HySegmentView.h>
#import "HyCharts.h"
#import "HyChartKLineView.h"

@interface HyChartsKlineNewDemoController ()

@property (nonatomic, strong) HyChartKLineView *klineView;

@property (nonatomic,strong) HySegmentView *segmentView;
@property (nonatomic,strong) HySegmentView *technicalSegmentView;
@property (nonatomic,strong) HySegmentView *auxiliarySegmentView;

@end

@implementation HyChartsKlineNewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

    UIView *backV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 150)];
    backV.backgroundColor = UIColor.blackColor;
    [scrollView insertSubview:backV atIndex:0];


    [scrollView addSubview:self.segmentView];
    [scrollView addSubview:self.technicalSegmentView];
    [scrollView addSubview:self.auxiliarySegmentView];
    [scrollView addSubview:self.klineView];
    scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.klineView.frame) + 50);

    [self requestDataWithType:@"201"];
}

- (void)requestDataWithType:(NSString *)type {
    
    __weak typeof(self) _self = self;
    
    NSString *string = [NSString stringWithFormat:@"https://api.idcs.io:8323/api/LineData/GetLineData?TradingConfigId=_DSQ3BmslE-cS-HP3POlnA&LineType=%@&PageIndex=1&PageSize=400&ClientType=2&LanguageCode=zh-CN", type];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.center = CGPointMake(self.klineView.width / 2, self.klineView.height / 2);
    [self.klineView addSubview:indicatorView];
    [indicatorView startAnimating];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    [[session dataTaskWithURL:[NSURL URLWithString:string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (!error) {
            
            __strong typeof(_self) self = _self;
            NSDictionary *successObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *array = successObject[@"Data"];
            
            NSInteger (^itemsBlock)(void) = ^NSInteger {
                return array.count;
            };
            
            void (^ItemAtIndexBlock)(id<HyChartKLineModelProtocol>, NSInteger) =
            ^(id<HyChartKLineModelProtocol>  _Nonnull model, NSInteger index){
                
                NSDictionary *dict = array[index];
                model.closePrice = [NSNumber numberWithFloat:[dict[@"Closed"] floatValue]];
                model.openPrice = [NSNumber numberWithFloat:[dict[@"Opened"] floatValue]];
                model.highPrice = [NSNumber numberWithFloat:[dict[@"Highest"] floatValue]];
                model.lowPrice = [NSNumber numberWithFloat:[dict[@"Lowest"] floatValue]];
                model.volume = [NSNumber numberWithFloat:[dict[@"DNum"] floatValue]];

                time_t timeInterval = [dict[@"Timestamp"] doubleValue];
                struct tm *cTime = localtime(&timeInterval);
                NSString *string = [NSString stringWithFormat:@"%02d-%02d %02d:%02d", cTime->tm_mon + 1, cTime->tm_mday, cTime->tm_hour, cTime->tm_min];
                model.text = string;
                
            };
            
            [[self.klineView.dataSource.modelDataSource configNumberOfItems:itemsBlock] configModelForItemAtIndex:ItemAtIndexBlock];
         
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [indicatorView stopAnimating];
                [indicatorView removeFromSuperview];
                self.klineView.timeLine = [type isEqualToString:@"101"];
                [self.klineView setNeedsRendering];
                
            });
        }
    }] resume];
}

- (HySegmentView *)segmentView {
    if (!_segmentView){

        NSArray<NSString *> *titleArray = @[@"Time", @"M5", @"M15", @"M30", @"H1", @"D1", @"W1", @"MN"];
        NSArray<NSString *> *typeArray = @[@"101", @"102", @"103", @"104", @"201", @"301", @"310", @"401"];
        __weak typeof(self) _self = self;
        _segmentView =
        [HySegmentView segmentViewWithFrame:CGRectMake(0, 0, self.view.width, 40)
                             configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
                        
            configure
            .numberOfItems(titleArray.count)
            .startIndex(4)
            .insetAndMarginRatio(.65)
            .viewForItemAtIndex(^UIView *(UIView *currentView,
                                          NSInteger currentIndex,
                                          CGFloat progress,
                                          HySegmentViewItemPosition position,
                                          NSArray<UIView *> *animationViews){

                UILabel *label = (UILabel *)currentView;
                if (!label) {
                    label = [UILabel new];
                    label.text = titleArray[currentIndex];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = UIColor.whiteColor;
                    label.font = [UIFont systemFontOfSize:15];
                    [label sizeToFit];
                    label.width += 10;
                }
                if (progress == 0 || progress == 1) {
                    label.textColor =  progress == 0 ? [UIColor hy_colorWithHexString:@"#3A5775"] : UIColor.whiteColor;
                }
                return label;
            })
            .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                
                NSArray<UIView *> *array = currentAnimations;
                
                if (!array.count) {
                    UIView *view = [UIView new];
                    view.backgroundColor = [UIColor hy_colorWithHexString:@"#2E7FD0"];
                    view.layer.cornerRadius = 1;
                    view.heightValue(24).topValue(8);
                    view.layer.cornerRadius = view.height / 2;
                    array = @[view];
                }
                
                CGFloat margin = toCell.centerX - fromCell.centerX;
                CGFloat widthMargin = (toCell.width - fromCell.width);
                array.firstObject
                .widthValue(fromCell.width + 15  + widthMargin * progress)
                .centerXValue(fromCell.centerX + margin * progress);
  
                return array;
            })
            .clickItemAtIndex(^BOOL(NSInteger currentIndex, BOOL isRepeat){
                 __weak typeof(_self) self = _self;
                if (!isRepeat) {
                    [self requestDataWithType:typeArray[currentIndex]];
                }
                return YES;
            });
        }];
        _segmentView.backgroundColor = [UIColor colorWithRed:14.0 / 255 green:33.0 / 255 blue:60.0 / 255 alpha:1];
    }
    return _segmentView;
}

- (HySegmentView *)technicalSegmentView {
    if (!_technicalSegmentView){

        NSArray<NSString *> *titleArray = @[@"MA", @"EMA", @"BOLL"];
        __weak typeof(self) _self = self;
        _technicalSegmentView =
        [HySegmentView segmentViewWithFrame:CGRectMake(0, self.segmentView.bottom + 1, self.view.width, 40)
                             configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
                        
            configure
            .numberOfItems(titleArray.count)
            .itemMargin(20)
            .viewForItemAtIndex(^UIView *(UIView *currentView,
                                          NSInteger currentIndex,
                                          CGFloat progress,
                                          HySegmentViewItemPosition position,
                                          NSArray<UIView *> *animationViews){

                UILabel *label = (UILabel *)currentView;
                if (!label) {
                    label = [UILabel new];
                    label.text = titleArray[currentIndex];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = UIColor.whiteColor;
                    label.font = [UIFont systemFontOfSize:15];
                    [label sizeToFit];
                    label.width += 10;
                }
                if (progress == 0 || progress == 1) {
                    label.textColor =  progress == 0 ? [UIColor hy_colorWithHexString:@"#3A5775"] : UIColor.whiteColor;
                }
                return label;
            })
            .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                
                NSArray<UIView *> *array = currentAnimations;
                
                if (!array.count) {
                    UIView *view = [UIView new];
                    view.backgroundColor = [UIColor hy_colorWithHexString:@"#2E7FD0"];
                    view.layer.cornerRadius = 1;
                    view.heightValue(24).topValue(8);
                    view.layer.cornerRadius = view.height / 2;
                    array = @[view];
                }
                
                CGFloat margin = toCell.centerX - fromCell.centerX;
                CGFloat widthMargin = (toCell.width - fromCell.width);
                array.firstObject
                .widthValue(fromCell.width + 15  + widthMargin * progress)
                .centerXValue(fromCell.centerX + margin * progress);
  
                return array;
            })
            .clickItemAtIndex(^BOOL(NSInteger currentIndex, BOOL isRepeat){
                 __weak typeof(_self) self = _self;
                if (!isRepeat) {
                    [self.klineView switchKLineTechnicalType:currentIndex + 1];
                }
                return YES;
            });
        }];
        _technicalSegmentView.backgroundColor = [UIColor colorWithRed:14.0 / 255 green:33.0 / 255 blue:60.0 / 255 alpha:1];
    }
    return _technicalSegmentView;
}

- (HySegmentView *)auxiliarySegmentView {
    if (!_auxiliarySegmentView){
        
        NSArray<NSString *> *titleArray = @[@"MCAD", @"KDJ", @"RSI"];
        __weak typeof(self) _self = self;
        _auxiliarySegmentView =
        [HySegmentView segmentViewWithFrame:CGRectMake(0, self.technicalSegmentView.bottom + 1, self.view.width, 40)
                             configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
                        
            configure
            .numberOfItems(titleArray.count)
            .itemMargin(20)
            .viewForItemAtIndex(^UIView *(UIView *currentView,
                                          NSInteger currentIndex,
                                          CGFloat progress,
                                          HySegmentViewItemPosition position,
                                          NSArray<UIView *> *animationViews){

                UILabel *label = (UILabel *)currentView;
                if (!label) {
                    label = [UILabel new];
                    label.text = titleArray[currentIndex];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = UIColor.whiteColor;
                    label.font = [UIFont systemFontOfSize:15];
                    [label sizeToFit];
                    label.width += 10;
                }
                if (progress == 0 || progress == 1) {
                    label.textColor =  progress == 0 ? [UIColor hy_colorWithHexString:@"#3A5775"] : UIColor.whiteColor;
                }
                return label;
            })
            .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                
                NSArray<UIView *> *array = currentAnimations;
                
                if (!array.count) {
                    UIView *view = [UIView new];
                    view.backgroundColor = [UIColor hy_colorWithHexString:@"#2E7FD0"];
                    view.layer.cornerRadius = 1;
                    view.heightValue(24).topValue(8);
                    view.layer.cornerRadius = view.height / 2;
                    array = @[view];
                }
                
                CGFloat margin = toCell.centerX - fromCell.centerX;
                CGFloat widthMargin = (toCell.width - fromCell.width);
                array.firstObject
                .widthValue(fromCell.width + 15  + widthMargin * progress)
                .centerXValue(fromCell.centerX + margin * progress);
  
                return array;
            })
            .clickItemAtIndex(^BOOL(NSInteger currentIndex, BOOL isRepeat){
                 __weak typeof(_self) self = _self;
                if (!isRepeat) {
                    [self.klineView switchKLineAuxiliaryType:currentIndex];
                }
                return YES;
            });
        }];
        _auxiliarySegmentView.backgroundColor = [UIColor colorWithRed:14.0 / 255 green:33.0 / 255 blue:60.0 / 255 alpha:1];
    }
    return _auxiliarySegmentView;
}


- (HyChartKLineView *)klineView {
    if (!_klineView) {
        _klineView = HyChartKLineView.new;
        _klineView.frame = CGRectMake(0, self.auxiliarySegmentView.bottom + 2, self.view.bounds.size.width, self.view.bounds.size.width * 1.3);
        _klineView.backgroundColor = [UIColor colorWithRed:14.0 / 255 green:33.0 / 255 blue:60.0 / 255 alpha:1];
        _klineView.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        
        NSArray<NSNumber *> *yaxisIndexs = @[@4, @1, @1];
        [[_klineView.dataSource.axisDataSource configXAxisWithModel:^(id<HyChartXAxisModelProtocol>  _Nonnull xAxisModel) {
            xAxisModel.topXaxisDisabled = NO;
            [[[[xAxisModel configNumberOfIndexs:4] configAxisGridLineInfo:^(id<HyChartAxisGridLineInfoProtocol>  _Nonnull axisGridLineInfo) {
                axisGridLineInfo.axisGridLineColor = [UIColor colorWithWhite:1 alpha:.25];
            }] configTopXAxisInfo:^(id<HyChartXAxisInfoProtocol>  _Nonnull xAxisInfo) {
                xAxisInfo.autoSetText = NO;
                xAxisInfo.axisLineColor = [UIColor colorWithWhite:1 alpha:.25];
            }] configBottomXAxisInfo:^(id<HyChartXAxisInfoProtocol>  _Nonnull xAxisInfo) {
                xAxisInfo.axisLineColor = [UIColor colorWithWhite:1 alpha:.25];
            }];
        }] configYAxisWithModelAndViewType:^(id<HyChartYAxisModelProtocol>  _Nonnull yAxisModel, HyChartKLineViewType type) {
            
            yAxisModel.yAxisMaxValueExtraPrecent = @(0.1);
            yAxisModel.yAxisMinValueExtraPrecent = @(0.1);
            yAxisModel.rightYAaxisDisabled = NO;
            
            [[[[yAxisModel configNumberOfIndexs:[yaxisIndexs[type] integerValue]] configLeftYAxisInfo:^(id<HyChartYAxisInfoProtocol>  _Nonnull yAxisInfo) {
                yAxisInfo.axisLineColor = [UIColor colorWithWhite:1 alpha:.25];
                yAxisInfo.autoSetText = NO;
            }] configAxisGridLineInfo:^(id<HyChartAxisGridLineInfoProtocol>  _Nonnull axisGridLineModel) {
                axisGridLineModel.axisGridLineColor = [UIColor colorWithWhite:1 alpha:.25];
            }] configRightYAxisInfo:^(id<HyChartYAxisInfoProtocol>  _Nonnull yAxisInfo) {
                yAxisInfo.axisLineColor = [UIColor colorWithWhite:1 alpha:.25];
                yAxisInfo.axisTextColor = UIColor.whiteColor;
                yAxisInfo.axisTextPosition = HyChartAxisTextPositionBinus;
            }];
        }];
        
        [_klineView.dataSource.configreDataSource configConfigure:^(id<HyChartKLineConfigureProtocol>  _Nonnull configure) {
            
            configure.width = 6;
            configure.margin = 3;
            configure.edgeInsetStart = 3;
            configure.edgeInsetEnd = 3;
            configure.trendUpColor = [UIColor hy_colorWithHexString:@"#E97C5E"];
            configure.trendDownColor = [UIColor hy_colorWithHexString:@"#1ABD93"];
            configure.minScaleToLine = YES;
            configure.priceDecimal = 4;
            configure.newpriceColor = UIColor.whiteColor;
            configure.maxminPriceColor = UIColor.whiteColor;
            
        
            UIColor *lineColor =   Hy_ColorWithRGBA(46, 127, 208, 1);
            NSArray<UIColor *> *colors = @[Hy_ColorWithRGBA(46, 127, 208, .2),
                                           Hy_ColorWithRGBA(46, 127, 208, .1),
                                           Hy_ColorWithRGBA(46, 127, 208, .05)];

            configure.timeLineColor =
            configure.minScaleLineColor = lineColor;

            configure.timeLineShadeColors =
            configure.minScaleLineShadeColors = colors;


            configure.smaDict = @{@(5)  : UIColor.yellowColor,
                                  @(10) : UIColor.orangeColor,
                                  @(30) : UIColor.purpleColor};

            configure.emaDict = @{@(5)  : UIColor.yellowColor,
                                  @(10) : UIColor.orangeColor,
                                  @(30) : UIColor.purpleColor};

            configure.bollDict = @{@"20" : @[UIColor.yellowColor,
                                             UIColor.orangeColor,
                                             UIColor.purpleColor]};
        
            configure.macdDict = @{@[@12, @26, @9] : @[UIColor.orangeColor, UIColor.blueColor, [UIColor hy_colorWithHexString:@"#E97C5E"], [UIColor hy_colorWithHexString:@"#1ABD93"]]};
            configure.kdjDict = @{@[@9, @3, @3] : @[UIColor.orangeColor, UIColor.blueColor, UIColor.redColor]};
            configure.rsiDict = @{@6 : UIColor.orangeColor};
            
            configure.klineViewDict = @{@(HyChartKLineViewTypeMain) : @(.6),
                                        @(HyChartKLineViewTypeVolume) : @(.2),
                                        @(HyChartKLineViewTypeAuxiliary) : @(.2)};
        }];
        
        [_klineView switchKLineTechnicalType:HyChartKLineTechnicalTypeSMA];
    }
    return _klineView;
}

@end