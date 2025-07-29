//
//  CalculatorModel.m
//  计算器77
//
//  Created by 吴桐 on 2025/7/26.
//
#import "CalculatorModel.h"
#import <math.h>

@interface CalculatorModel () {
    NSMutableArray *_operandStack;
    NSMutableArray *_operatorStack;
}
@end

@implementation CalculatorModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _operandStack = [NSMutableArray array];
        _operatorStack = [NSMutableArray array];
    }
    return self;
}



- (BOOL)isOperator:(unichar)c {
    return c == '+' || c == '-' || c == '*' || c == '/';
}
//包括小数点
- (BOOL)isDigit:(unichar)c {
    return (c >= '0' && c <= '9') || c == '.';
}

- (int)precedenceForOperator:(unichar)op {
    switch (op) {
        case '(': return 0;
        case '+': return 1;
        case '-': return 1;
        case '*': return 2;
        case '/': return 2;
        default: return -1;
    }
}

- (double)applyOperator:(unichar)op to:(double)a and:(double)b {
    switch (op) {
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/':
            if (b == 0) {
                return NAN;
            }
            return a / b;
        default: return 0;
    }
}

- (void)applyTopOperator {
    //栈里没有两个元素
    if (_operandStack.count < 2 || _operatorStack.count == 0) return;
    
    unichar op = [_operatorStack.lastObject characterAtIndex:0];
    [_operatorStack removeLastObject];
    
    //两个运算的数字
    double b = [[_operandStack lastObject] doubleValue];
    [_operandStack removeLastObject];
    double a = [[_operandStack lastObject] doubleValue];
    [_operandStack removeLastObject];
    double result = [self applyOperator:op to:a and:b];
    [_operandStack addObject:@(result)];
}

//结果处理
- (NSString *)formatResult:(double)value {
    //检查是否为非数字/无穷大，学到了
    if (isnan(value) || isinf(value)) {
        return @"ERROR";
    }
    
    // 整数
    if (fmod(value, 1) == 0) {  //返回value / 1的余数
        return [NSString stringWithFormat:@"%.0f", value];
    }
    NSString *result = [NSString stringWithFormat:@"%.6f", value];

    // 删除小数点后多余的0
    NSRange dotRange = [result rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {  //从后往前
        // 遍历后缀，找到从后往前第一个不是0的位置
        NSUInteger i = result.length;
        while (i > dotRange.location + 1 && [result characterAtIndex:i - 1] == '0') {
            i--;
        }
        result = [result substringToIndex:i];
        // 如果最后是小数点，也去掉
        if ([result hasSuffix:@"."]) {
            result = [result substringToIndex:result.length - 1];
        }
    }
    return result;
}

- (NSString *)calculate:(NSString *)expression {
        [_operandStack removeAllObjects];
        [_operatorStack removeAllObjects];
        expression = [expression stringByReplacingOccurrencesOfString:@"×" withString:@"*"];
        expression = [expression stringByReplacingOccurrencesOfString:@"÷" withString:@"/"];
        
        // 添加结束符，我也没想清楚有嘛用
        expression = [expression stringByAppendingString:@" "];
        NSInteger length = expression.length;
        NSInteger i = 0;
    
        //负
        BOOL isNegative = NO;
        BOOL expectOperand = YES;
        
        while (i < length) {
            unichar c = [expression characterAtIndex:i];
            if (c == ' ') {
                i++;
                continue;
            }
            // 负数，有负号且不准备被操作
            if (c == '-' && expectOperand) {
                isNegative = YES;
                i++;
                continue;
            }
            // 处理数字
            if ([self isDigit:c]) {
                NSInteger start = i;
                //循环手机数字
                while (i < length && [self isDigit:[expression characterAtIndex:i]]) {
                    i++;
                }
                NSString *numStr = [expression substringWithRange:NSMakeRange(start, i - start)];
                double value = [numStr doubleValue];//类型转换
                //fushu处理
                if (isNegative) {
                    value = -value;
                    isNegative = NO;
                }
                [_operandStack addObject:@(value)];
                expectOperand = NO;
                continue;
            }
            
            // 处理左括号
            if (c == '(') {
                [_operatorStack addObject:[NSString stringWithCharacters:&c length:1]];//操作栈
                expectOperand = YES; // 可能跟着负数
                i++;
                continue;
            }
            
            // 处理右括号
            if (c == ')') {
                //一直运算知道遇到左括号
                while (_operatorStack.count > 0) {
                    unichar top = [_operatorStack.lastObject characterAtIndex:0];
                    //括号内算完了
                    if (top == '(') {
                        [_operatorStack removeLastObject]; // 弹出左括号
                        break;
                    }
                    //做一次运算
                    [self applyTopOperator];
                }
                expectOperand = NO;
                i++;
                continue;
            }
            
            // 处理运算符
            if ([self isOperator:c]) {
                // 处理运算符优先级
                while (_operatorStack.count > 0) {
                    unichar top = [_operatorStack.lastObject characterAtIndex:0];
                    // 遇到左括号停止
                    if (top == '(') {
                        break;
                    }
                    // 比较优先级
                    if ([self precedenceForOperator:top] >= [self precedenceForOperator:c]) {
                        [self applyTopOperator];
                    } else {
                        break;
                    }
                }
                [_operatorStack addObject:[NSString stringWithCharacters:&c length:1]];
                expectOperand = YES; // 运算符后可能跟着负数
                i++;
                continue;
            }
            i++;
        }
        
        // 处理栈中剩余的操作符
        while (_operatorStack.count > 0) {
            [self applyTopOperator];//函数
        }
        
        // 获取结果
        if (_operandStack.count == 1) {
            double result = [[_operandStack lastObject] doubleValue];
            if (isnan(result) || isinf(result)) {
                return @"错误"; // 这里替代异常处理，直接返回错误提示，或者可以用@catch那个东西，以后详细学习
            }
            return [self formatResult:result];
        }
        
        return @"ERROR";
}

@end
