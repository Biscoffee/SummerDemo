//
//  View.h
//  计算器77
//
//  Created by 吴桐 on 2025/7/26.
//

#import <UIKit/UIKit.h>
@class View;

@protocol ViewDelegate <NSObject>
- (void)pressChange:(UIButton *)button;
@end
NS_ASSUME_NONNULL_BEGIN

@interface View : UIView
@property (nonatomic, strong) UILabel* topLabel;
@property (nonatomic, copy) NSArray* array;
@property (nonatomic, strong) UIButton* normalButton;
@property (nonatomic, strong) UIButton* zeroButton;
@property (nonatomic, weak) id<ViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
