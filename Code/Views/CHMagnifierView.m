//
//  CHMagnifierView.m
//  Magnifier
//
//  Created by Chenhao on 14-2-25.
//  Copyright (c) 2014年 Chenhao. All rights reserved.
//

#import "CHMagnifierView.h"
#define MAGNIFIER_SMALL_IMAGE    @"magni.png"
#define MAGNIFIER_BIG_IMAGE      @"magnifier_big.png"

@interface CHMagnifierView ()

@property (strong, nonatomic) CALayer *contentLayer;
@property (strong, nonatomic) UIImageView *loupeImageView;
@property (assign) BOOL isPurchased;

@end

@implementation CHMagnifierView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
       _isPurchased =[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_%ld", @"in_app_purchase_for_magnifier",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"userid"]]];
        
        if (!_isPurchased)
            self.frame = CGRectMake(0, 0, 100, 100);
        else
            self.frame = CGRectMake(0, 0, 300, 300);
            
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        //self.layer.cornerRadius = 25;
        self.layer.masksToBounds = YES;
        self.windowLevel = UIWindowLevelAlert;
        
        NSString *magnifierImageName = (_isPurchased == YES ? MAGNIFIER_BIG_IMAGE : MAGNIFIER_SMALL_IMAGE);
        _loupeImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(CGRectInset(self.bounds, 0.0, 0.0), 0, 0)];
        _loupeImageView.image = [UIImage imageNamed:magnifierImageName];
        _loupeImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_loupeImageView];
        
        
        self.contentLayer = [CALayer layer];
        
        if (!_isPurchased) {
            self.contentLayer.cornerRadius = 30;
            self.contentLayer.frame = CGRectMake(8, 2.2, 59, 62);
        }
        else {
            self.contentLayer.cornerRadius = 90;
            self.contentLayer.frame = CGRectMake(22.5, 5, 179.5, 189);
        }
        
        self.contentLayer.delegate = self;
       
        self.contentLayer.masksToBounds = YES;
        self.contentLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:self.contentLayer];
        
        /*self.frame = CGRectMake(0, 0, 70, 70);
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.cornerRadius = 35;
        self.layer.masksToBounds = YES;
        self.windowLevel = UIWindowLevelAlert;
       
        
        self.contentLayer = [CALayer layer];
        self.contentLayer.frame = self.bounds;
        self.contentLayer.delegate = self;
        self.contentLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:self.contentLayer];*/
        
       
    }
    
    return self;
}

- (void)setPointToMagnify:(CGPoint)pointToMagnify
{
    _pointToMagnify = pointToMagnify;
    
    CGPoint tempPoint = _pointToMagnify;
    tempPoint.y = tempPoint.y - (_isPurchased == YES ?150:30);
    _pointToMagnify = tempPoint;

    
    CGPoint center = CGPointMake(pointToMagnify.x, self.center.y);
    if (pointToMagnify.y > CGRectGetHeight(self.bounds) * 0.5) {
        center.y = pointToMagnify.y -  CGRectGetHeight(self.bounds) / 2;
    }
    
    self.center = center;
    [self.contentLayer setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
 
}
*/

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
	CGContextScaleCTM(ctx, 1.2, 1.2);
	CGContextTranslateCTM(ctx, -1 * self.pointToMagnify.x, -1 * self.pointToMagnify.y);
	[self.viewToMagnify.layer renderInContext:ctx];
}

@end
