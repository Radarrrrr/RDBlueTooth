//
//  RDBlueTooth.m
//  RDBlueToothDemo
//
//  Created by Radar on 2017/9/18.
//  Copyright © 2017年 Radar. All rights reserved.
//

#import "RDBlueTooth.h"



@interface RDBlueTooth ()

@property (assign) id <RDBlueToothDelegate> delegate;

@property (nonatomic, strong) CBCentralManager *manager;   //蓝牙中心控制器对象
@property (nonatomic, strong) NSMutableArray *deviceArray; //本地保存的设备数组，用于保存本次扫描到的所有设备，同时会在存储的同时剔除掉无用的外设

@end




@implementation RDBlueTooth

- (id)init{
    self = [super init];
    if(self){
        //do something
        self.deviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RDBlueTooth *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RDBlueTooth alloc] init];
    });
    return instance;
}



#pragma mark - 内部方法




#pragma mark - 外部方法
- (void)startScaningForTarget:(id)target //开始扫描外设
{
    //先尝试停止扫描，释放管理器
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(_manager)
    {
        [_manager stopScan];
        self.manager = nil;
    }
    
    //清空扫描结果列表
    [_deviceArray removeAllObjects];
    
    //给target赋值
    self.delegate = target;
        
    //重新创建管理中心，创建方法会自动触发一次蓝牙状态回调
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)stopScaning  //停止扫描外设
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(_manager)
    {
        [_manager stopScan];
        self.manager = nil;
    }
    
    self.delegate = nil;
}






#pragma mark - CBCentralManagerDelegate
//接收本机蓝牙可用状态回调
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"%@",central);
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"可用，打开");
            
            //开始扫描外设
            NSLog(@"开始扫描外设...");
            [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"可用，未打开");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"SDK不支持");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"程序未授权");
            break;
        case CBManagerStateResetting:
            NSLog(@"CBManagerStateResetting");
            break;
        case CBManagerStateUnknown:
            NSLog(@"CBManagerStateUnknown");
            break;
    }
}

//接收到扫描到的外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name.length <= 0) {
        return ;
    }
    
    //NSLog(@"扫描到外设：%@", peripheral);
    //NSLog(@"Discovered name:%@,identifier:%@,advertisementData:%@,RSSI:%@", peripheral.name, peripheral.identifier,advertisementData,RSSI);
    
    //把扫描到的外设的属性打包成字典，保存到本地以后，再返回给上层
    NSMutableDictionary *periDic = [[NSMutableDictionary alloc] init];
    
    [periDic setObject:peripheral forKey:@"peripheral"];
    [periDic setObject:RSSI forKey:@"RSSI"];
    if(advertisementData)
    {
        [periDic setObject:advertisementData forKey:@"advertisementData"];
    }
    
    //做排重处理
    if(self.deviceArray.count == 0)
    {
        [self.deviceArray addObject:periDic];
    } 
    else 
    {
        BOOL isExist = NO;
        for(int i = 0; i < self.deviceArray.count; i++)
        {
            NSDictionary *dict = [self.deviceArray objectAtIndex:i];
            CBPeripheral *per = dict[@"peripheral"];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
            {
                isExist = YES;
                [_deviceArray replaceObjectAtIndex:i withObject:periDic];
            }
        }
        
        if(!isExist)
        {
            [self.deviceArray addObject:periDic];
        }
    }
    
    //返回给上层
    if(_delegate && [_delegate respondsToSelector:@selector(RDBlueToothDidDiscoverNewPeripheral:allDiscoveredPeripherals:)])
    {
        [_delegate RDBlueToothDidDiscoverNewPeripheral:periDic allDiscoveredPeripherals:_deviceArray];
    }
    
}


@end
