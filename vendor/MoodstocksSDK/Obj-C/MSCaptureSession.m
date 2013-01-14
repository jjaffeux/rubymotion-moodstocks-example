/**
 * Copyright (c) 2012 Moodstocks SAS
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MSCaptureSession.h"

#import "MSObjC.h"

#if MS_SDK_REQUIREMENTS
static void ms_capturesession_cleanup(void *s) {
#if __has_feature(objc_arc)
    [((__bridge MSCaptureSession *) s) release_stub];
#else
    [((MSCaptureSession *) s) release_stub];
#endif
}
#endif

@interface MSCaptureSession ()
#if MS_SDK_REQUIREMENTS
- (void)setup;
- (void)setupVideoInput;
- (void)setupVideoOutput;
- (void)setupVideoPreview;
- (void)deviceOrientationDidChange;
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)backFacingCamera;
#endif
@end

@implementation MSCaptureSession

#if MS_SDK_REQUIREMENTS
@synthesize previewLayer = _previewLayer;
@synthesize orientation = _orientation;
@synthesize delegate = _delegate;
#endif

- (id)init {
    self = [super init];
    if (self) {
#if MS_SDK_REQUIREMENTS
        [self setup];
        
        self.orientation = AVCaptureVideoOrientationPortrait;
        self.delegate = nil;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
#endif
    }
    return self;
}

- (void)dealloc {
#if MS_SDK_REQUIREMENTS
    [self stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
#endif
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

#if MS_SDK_REQUIREMENTS
- (void)setup {
    _captureSession = [[AVCaptureSession alloc] init];
    
    [self setupVideoInput];
    [self setupVideoOutput];
    [self setupVideoPreview];
}

- (void)setupVideoInput {
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera]
                                                         error:nil];
    
    // Recommended setting: do  *NOT* change
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    else {
        // Fallback to 480x360 (e.g. on 3GS devices)
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
            [_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
        if ([_captureSession canAddInput:_videoInput]) {
            [_captureSession addInput:_videoInput];
        }
    }
}

- (void)setupVideoOutput {
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("moodstocks-capture-session", DISPATCH_QUEUE_SERIAL);
#if __has_feature(objc_arc)
    dispatch_set_context(videoDataOutputQueue, (__bridge void *)(self));
#else
    dispatch_set_context(videoDataOutputQueue, self);
#endif
    dispatch_set_finalizer_f(videoDataOutputQueue, ms_capturesession_cleanup);
    
    NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                         forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setVideoSettings:settings];
    [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [_videoOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([_captureSession canAddOutput:_videoOutput])
        [_captureSession addOutput:_videoOutput];
    
    dispatch_release(videoDataOutputQueue);
    [self retain_stub]; /* a release is made at `ms_capturesession_cleanup` time */
}

- (void)setupVideoPreview {
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)deviceOrientationDidChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		self.orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		self.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		self.orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		self.orientation = AVCaptureVideoOrientationLandscapeLeft;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    [_delegate session:self didOutputSampleBuffer:sampleBuffer];
}
#endif

- (void)start {
#if MS_SDK_REQUIREMENTS
    if (!_captureSession) [self setup];
    
    // Start your engine
    [self play];
#endif
}

- (void)stop {
#if MS_SDK_REQUIREMENTS
    if ([_captureSession isRunning])
        [_captureSession stopRunning];
        
    if ([[_captureSession inputs] containsObject:_videoInput])
        [_captureSession removeInput:_videoInput];
        
    [_videoInput release_stub];
    _videoInput = nil;
    
    if ([[_captureSession outputs] containsObject:_videoOutput])
        [_captureSession removeOutput:_videoOutput];
    
    [_videoOutput release_stub];
    _videoOutput = nil;
        
    [_previewLayer release_stub];
    _previewLayer = nil;
        
    [_captureSession release_stub];
    _captureSession = nil;
#endif
}

- (void)play {
#if MS_SDK_REQUIREMENTS
    if (![_captureSession isRunning])
        [_captureSession startRunning];
#endif
}

- (void)pause {
#if MS_SDK_REQUIREMENTS
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
    }
#endif
}

@end
