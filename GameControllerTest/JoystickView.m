//
//  JoystickView.m
//  GameControllerTest
//
//  Created by John Brewer on 12/2/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import "JoystickView.h"

@implementation JoystickView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect    myFrame = self.bounds;
    
    // Set the line width to 10 and inset the rectangle by
    // 5 pixels on all sides to compensate for the wider line.
    CGContextSetLineWidth(context, 10);
    CGRectInset(myFrame, 5, 5);
    
    [[UIColor redColor] set];
    UIRectFrame(myFrame);
    
    CGPoint center = CGPointMake(myFrame.size.width/2, myFrame.size.height/2);
    CGPoint offset = CGPointMake(center.x + _xAxis * center.x, center.y - _yAxis * center.y);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, offset.x, offset.y);
    CGContextStrokePath(context);
}

-(void) setXAxis:(float)newValue
{
    if (newValue != _xAxis) {
        _xAxis = newValue;
        [self setNeedsDisplay];
    }
}

-(void) setYAxis:(float)newValue
{
    if (newValue != _yAxis) {
        _yAxis = newValue;
        [self setNeedsDisplay];
    }
}
@end
