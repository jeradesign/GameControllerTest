//
//  ViewController.m
//  GameControllerTest
//
//  Created by John Brewer on 11/25/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"
#import <GameController/GameController.h>
#import "JoystickView.h"

@interface ViewController () {
    GCController *_controller;
    __weak IBOutlet UILabel *_leftShoulder;
    __weak IBOutlet UILabel *_rightShoulder;
    __weak IBOutlet UILabel *_dpadUp;
    __weak IBOutlet UILabel *_dpadDown;
    __weak IBOutlet UILabel *_dpadLeft;
    __weak IBOutlet UILabel *_dpadRight;
    __weak IBOutlet UILabel *_aButton;
    __weak IBOutlet UILabel *_bButton;
    __weak IBOutlet UILabel *_xButton;
    __weak IBOutlet UILabel *_yButton;
    __weak IBOutlet UILabel *_leftTrigger;
    __weak IBOutlet UILabel *_rightTrigger;
    __weak IBOutlet UIImageView *_leftShoulderIcon;
    __weak IBOutlet UIImageView *_rightShoulderIcon;
    __weak IBOutlet UIImageView *_aButtonIcon;
    __weak IBOutlet UIImageView *_bButtonIcon;
    __weak IBOutlet UIImageView *_xButtonIcon;
    __weak IBOutlet UIImageView *_yButtonIcon;
    __weak IBOutlet UIImageView *_leftTriggerIcon;
    __weak IBOutlet UIImageView *_rightTriggerIcon;
    __weak IBOutlet JoystickView *_leftJoystick;
    __weak IBOutlet JoystickView *_rightJoystick;
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
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
        [self log:@"Done discovering wireless controllers."];
    }];
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

    __block ViewController *blockSelf = self;

    if (_controller.extendedGamepad) {
        _controller.extendedGamepad.valueChangedHandler =
        ^(GCExtendedGamepad *gamepad, GCControllerElement *element) {
            [blockSelf updateControlValues];
        };
    } else {
        _controller.gamepad.valueChangedHandler =
        ^(GCGamepad *gamepad, GCControllerElement *element) {
            [blockSelf updateControlValues];
        };
    }
}

- (void)updateControlValues
{
    [self updateView:_leftShoulder forButton:_controller.gamepad.leftShoulder andView:_leftShoulderIcon];
    [self updateView:_rightShoulder forButton:_controller.gamepad.rightShoulder andView:_rightShoulderIcon];
    [self updateView:_dpadUp forButton:_controller.gamepad.dpad.up andView:nil];
    [self updateView:_dpadDown forButton:_controller.gamepad.dpad.down andView:nil];
    [self updateView:_dpadLeft forButton:_controller.gamepad.dpad.left andView:nil];
    [self updateView:_dpadRight forButton:_controller.gamepad.dpad.right andView:nil];
    [self updateView:_aButton forButton:_controller.gamepad.buttonA andView:_aButtonIcon];
    [self updateView:_bButton forButton:_controller.gamepad.buttonB andView:_bButtonIcon];
    [self updateView:_xButton forButton:_controller.gamepad.buttonX andView:_xButtonIcon];
    [self updateView:_yButton forButton:_controller.gamepad.buttonY andView:_yButtonIcon];
    if (_controller.extendedGamepad == nil) {
        return;
    }
    [self updateView:_leftTrigger forButton:_controller.extendedGamepad.leftTrigger andView:_leftTriggerIcon];
    [self updateView:_rightTrigger forButton:_controller.extendedGamepad.rightTrigger andView:_rightTriggerIcon];
    [self updateView:_leftJoystick forJoystick:_controller.extendedGamepad.leftThumbstick];
    [self updateView:_rightJoystick forJoystick:_controller.extendedGamepad.rightThumbstick];
}

- (void)updateView:(UIView*)view forButton:(GCControllerButtonInput*)button andView:(UIImageView*)image_view
{
    if (button.isPressed) {
        view.backgroundColor = UIColor.grayColor;
        image_view.backgroundColor = UIColor.grayColor;
    } else {
        view.backgroundColor = UIColor.whiteColor;
        image_view.backgroundColor = UIColor.whiteColor;
    }


    if (image_view != nil)
    {
        // It's naive to query this every update, but otherwise we need to
        // listen for focus loss/gain messages to ensure we refresh the
        // button icons. For this demo app, this is fine.
        GCControllerButtonInput *input = button;
        NSString *name = input.sfSymbolsName;
        if (name == nil) {
            name = input.unmappedSfSymbolsName;
        }

        if (name == nil) {
            name = @"questionmark.square";
        }

        if (@available(iOS 13.0, *)) {
            //~ NSLog(@"sfSymbolsName: %@", name);
            int height = 150;
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration
                configurationWithPointSize:(CGFloat)height];
            UIImage *vanilla = [UIImage
                systemImageNamed:name
                withConfiguration:config];

            image_view.image = vanilla;

        } else {
            [self log:@"UIImage.systemImageNamed API not available."];
        }
    }

}

- (void)updateView:(JoystickView*)view forJoystick:(GCControllerDirectionPad*)joystick
{
    view.xAxis = joystick.xAxis.value;
    view.yAxis = joystick.yAxis.value;
}

- (void)controllerDisconnected:(NSNotification*)notification
{
    GCController *controller = notification.object;
    [self log:[NSString stringWithFormat:@"Controller %@ disconnected", controller]];
}

@end
