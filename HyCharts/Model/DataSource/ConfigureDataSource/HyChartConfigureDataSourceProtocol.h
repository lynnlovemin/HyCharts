//
//  HyChartConfigureDataSourceProtocol.h
//  HyChartsDemo
//
//  Created by Hy on 2018/3/26.
//  Copyright © 2018 Hy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HyChartConfigureProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HyChartConfigureDataSourceProtocol <NSObject>

- (id<HyChartConfigureDataSourceProtocol>)configConfigure:(void (^_Nullable)(id<HyChartConfigureProtocol> configure))block;

@property (nonatomic, strong, readonly) id<HyChartConfigureProtocol> configure;

@end

NS_ASSUME_NONNULL_END
