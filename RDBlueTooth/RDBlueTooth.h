//
//  RDBlueTooth.h
//  RDBlueToothDemo
//
//  Created by Radar on 2017/9/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol RDBlueToothDelegate <NSObject>
@optional

//@Radar 为什么这个方法用代理而不是block？因为考虑到这个数据会在扫描过程中多次返回，如果用block会在调用方代码中造成大段的连续代码，反而不是更好的方式。
//发现一个新外设时回调一次，同时会把已经发现的所有外设也返回。 字典结构为：@{@"peripheral":peripheral, @"RSSI":RSSI, @"advertisementData":advertisementData}
- (void)RDBlueToothDidDiscoverNewPeripheral:(NSDictionary*)periDic allDiscoveredPeripherals:(NSMutableArray*)allPeriDics; 

@end



@interface RDBlueTooth : NSObject <CBCentralManagerDelegate>

//单实例
+ (instancetype)sharedInstance;


- (void)startScaningForTarget:(id)target; //开始扫描外设
- (void)stopScaning;  //停止扫描外设



@end
