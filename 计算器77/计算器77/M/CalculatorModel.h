//
//  CalculatorModel.h
//  计算器77
//
//  Created by 吴桐 on 2025/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalculatorModel : NSObject
//@property (nonatomic, strong) NSMutableArray* ansArray;
//@property (nonatomic, strong) NSMutableArray* calArray;
//@property (nonatomic, strong) NSString* returnString;
-(NSString*) calculate :(NSString*) string;
@end

NS_ASSUME_NONNULL_END
