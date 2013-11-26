//
//  ViewController.m
//  GameControllerTest
//
//  Created by John Brewer on 11/25/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"
#import <GameController/GameController.h>

@interface ViewController () {
    GCController *_controller;
    GCGamepad *_gamepad;
    GCExtendedGamepad *_extendedGamepad;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerConnected:)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerDisconnected:)
                                                 name:GCControllerDidDisconnectNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)log:(NSString*)string
{
    self.textView.text = [NSMutableString stringWithFormat:@"%@%@\n",
                          self.textView.text, string];
    CGRect caretRect = [_textView caretRectForPosition:_textView.endOfDocument];
    [_textView scrollRectToVisible:caretRect animated:NO];
}

- (void)listControllers
{
    NSArray *controllers = [GCController controllers];
    [self log:[NSString stringWithFormat:@"controllers = %@", controllers]];
    for (GCController *controller in controllers) {
        [self log:controller.description];
    }
}

- (void)controllerConnected:(NSNotification*)notification
{
    GCController *controller = notification.object;
    _controller = controller;
    [self log:[NSString stringWithFormat:@"vendorName: %@", _controller.vendorName]];
    [self log:[NSString stringWithFormat:@"playerIndex: %ld", (long)_controller.playerIndex]];
    if (_controller.attachedToDevice) {
        [self log:@"attachedToDevice"];
    }
    _controller.gamepad.leftShoulder.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self log:[NSString stringWithFormat:@"leftShoulder pressed = %d, value = %f",
                   pressed, value]];
    };
}


- (void)controllerDisconnected:(NSNotification*)notification
{
    GCController *controller = notification.object;
    [self log:[NSString stringWithFormat:@"Controller %@ disconnected", controller]];
}

@end
