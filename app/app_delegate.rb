class AppDelegate

  attr_accessor :window

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # Test if device is compatible
    # MSDeviceCompatibleWithSDK()
    # see : https://github.com/Moodstocks/moodstocks-sdk/blob/master/sample/iphone/demo/Demo/MSAppDelegate.m#L46

    # Here you should implement propre error management
    # see : https://github.com/Moodstocks/moodstocks-sdk/blob/master/sample/iphone/demo/Demo/MSAppDelegate.m#L61
    scanner = MSScanner.sharedInstance
    error_ptr = Pointer.new(:object)
    scanner.open(error_ptr)

    controller = RootViewController.alloc.init
    navigationController = UINavigationController.alloc.initWithRootViewController(controller)
    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.window.rootViewController = navigationController
    self.window.makeKeyAndVisible

    true
  end

end