//
//  ZRAnimationAsUCView.m
//  ZRAnimationAsUC
//
//  Created by 58赶集 on 16/1/26.
//  Copyright © 2016年 ZhangHongyun. All rights reserved.
//

#import "ZRAnimationAsUCView.h"


#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define MIN_HEIGHT 200

@interface ZRAnimationAsUCView ()

@property (nonatomic, assign) CGFloat mHeight;
@property (nonatomic, assign) CGFloat curveX;
@property (nonatomic, assign) CGFloat curveY;
@property (nonatomic, strong) UIView * curveView;

@property (nonatomic, strong) CAShapeLayer * shapeLayer;
@property (nonatomic, strong) CAShapeLayer * circleLayer;
@property (nonatomic, strong) CAShapeLayer * moveCircleLayer;

@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UILabel * label;

@property (nonatomic,assign) CGFloat circleY;

@end

@implementation ZRAnimationAsUCView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self configShapeLayer];
        [self configCurveView];
        [self configAction];
        [self updateShapeLayerPath];
    }
    
    return self;
}
#pragma mark - 手势以及视图的初始化

- (void)configAction
{
    _mHeight = 100;                       // 手势移动时相对高度
    _isAnimating = NO;                    // 是否处于动效状态
    _circleY = 0;
    
    // 手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:pan];
    
    // CADisplayLink默认每秒运行60次calculatePath是算出在运行期间_curveView的坐标，从而确定_shapeLayer的形状
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES;
}

- (void)configShapeLayer
{
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = [UIColor colorWithRed:0.22 green:0.54 blue:0.73 alpha:1].CGColor;
    [self.layer addSublayer:_shapeLayer];
    
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_circleLayer];
    
    _moveCircleLayer = [CAShapeLayer layer];
    _moveCircleLayer.fillColor = [UIColor colorWithRed:0.22 green:0.54 blue:0.73 alpha:1].CGColor;
    [self.layer addSublayer:_moveCircleLayer];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(0, MIN_HEIGHT / 2 + 20, kScreenWidth, 30);
    _label.text = @"松开进入头条";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor whiteColor];
    _label.alpha = 0;
    
    [self addSubview:_label];
}

- (void)configCurveView
{
    _curveX = kScreenWidth / 2.0;
    _curveY = MIN_HEIGHT;
    _curveView = [[UIView alloc] initWithFrame:CGRectMake(_curveX, _curveY, 0, 0)];
    [self addSubview:_curveView];
}

#pragma mark - 手势动作的对应操作

- (void)handlePanAction:(UIPanGestureRecognizer *)pan
{
    if(!_isAnimating)
    {
        if(pan.state == UIGestureRecognizerStateChanged)
        {
            // 手势移动时，_shapeLayer跟着手势向下扩大区域
            CGPoint point = [pan translationInView:self];
            
            // 这部分代码使r5红点跟着手势走
            _mHeight = point.y + MIN_HEIGHT;
            _curveX = kScreenWidth / 2.0 ;//+ point.x;
            _curveY = _mHeight > MIN_HEIGHT ? _mHeight : MIN_HEIGHT;
            _curveView.frame = CGRectMake(_curveX,
                                          _curveY,
                                          _curveView.frame.size.width,
                                          _curveView.frame.size.height);
            
            if (_mHeight >= MIN_HEIGHT && _mHeight < 1.5 * MIN_HEIGHT)
            {
                _circleY = (float)point.y * 2 / MIN_HEIGHT * 40;
                _label.alpha = (float)point.y  * 2 / MIN_HEIGHT;
                
            }
            else if (_mHeight >= 1.5 * MIN_HEIGHT)
            {
                _circleY = 40;
                _label.alpha = 1.0;
            }
            
            // 根据r5的坐标,更新_shapeLayer形状
            [self updateShapeLayerPath];
            
        }
        else if (pan.state == UIGestureRecognizerStateCancelled ||
                 pan.state == UIGestureRecognizerStateEnded ||
                 pan.state == UIGestureRecognizerStateFailed)
        {
            // 手势结束时,_shapeLayer返回原状并产生弹簧动效
            _isAnimating = YES;
            _displayLink.paused = NO;           //开启displaylink,会执行方法calculatePath.
            
            // 弹簧动效
            [UIView animateWithDuration:1.0
                                  delay:0.0
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 // 曲线点(r5点)是一个view.所以在block中有弹簧效果.然后根据他的动效路径,在calculatePath中计算弹性图形的形状
                                 _curveView.frame = CGRectMake(kScreenWidth / 2.0, MIN_HEIGHT, 3, 3);
                                 _circleY = 0;
                                 _label.alpha = 0;
                             } completion:^(BOOL finished) {
                                 
                                 if(finished)
                                 {
                                     _displayLink.paused = YES;
                                     _isAnimating = NO;
                                 }
                                 
                             }];
        }
    }
}

- (void)updateShapeLayerPath
{
    // 更新_shapeLayer形状
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    [tPath moveToPoint:CGPointMake(0, 0)];                          // r1点
    [tPath addLineToPoint:CGPointMake(kScreenWidth, 0)];            // r2点
    [tPath addLineToPoint:CGPointMake(kScreenWidth,  MIN_HEIGHT)];  // r4点
    [tPath addQuadCurveToPoint:CGPointMake(0, MIN_HEIGHT)
                  controlPoint:CGPointMake(_curveX, _curveY)]; // r3,r4,r5确定的一个弧线
    [tPath closePath];
    _shapeLayer.path = tPath.CGPath;
    
    //月牙视图的下层圆，一开始被覆盖掉
    UIBezierPath *pPath = [UIBezierPath bezierPath];
    [pPath addArcWithCenter:CGPointMake(kScreenWidth / 2, MIN_HEIGHT / 2) radius:10 + _circleY / 4 startAngle:0 endAngle:100 clockwise:1];
    _circleLayer.path = pPath.CGPath;
    
    //月牙视图的上层圆，用来覆盖在上边，随着手势下滑，逐渐移开，呈现出月牙形状
    UIBezierPath * mPath = [UIBezierPath bezierPath];
    [mPath addArcWithCenter:CGPointMake(kScreenWidth / 2, MIN_HEIGHT / 2 + _circleY) radius:10 + _circleY / 4 startAngle:0 endAngle:100 clockwise:1];
    _moveCircleLayer.path = mPath.CGPath;
}


- (void)calculatePath
{
    // 由于手势结束时,r5执行了一个UIView的弹簧动画,把这个过程的坐标记录下来,并相应的画出_shapeLayer形状
    CALayer *layer = _curveView.layer.presentationLayer;
    _curveX = layer.position.x;
    _curveY = layer.position.y;
    [self updateShapeLayerPath];
}


@end
