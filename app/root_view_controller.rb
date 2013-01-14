class RootViewController < UIViewController

  def initWithNibName(nibNameOrNil, bundle:nibBundleOrNil)
    super
    @lastSync = 0
    self.sync
    self
  end

  def viewDidLoad
    self.title = "Demo"
    self.view.backgroundColor = UIColor.whiteColor
    
    scanButton = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    scanButton.addTarget(self, action: :scanAction, forControlEvents:UIControlEventTouchDown)
    scanButton.setTitle("Scan", forState:UIControlStateNormal)
    scanButton.frame = [[0,0],[200,30]]
    scanButton.center = [Device.screen.width/2,Device.screen.height/2]
    self.view.addSubview(scanButton)
  end

  def scanAction
    scannerController = ScannerViewController.alloc.init
    self.navigationController.pushViewController(scannerController, animated:true)
  end

  def sync
    scanner = MSScanner.sharedInstance
    return if scanner.isSyncing
    scanner.syncWithDelegate(self)
  end

  def scannerWillSync(scanner)
    App.shared.setNetworkActivityIndicatorVisible(true)
    p "[MOODSTOCKS SDK] WILL SYNC"
  end

  def scannerDidSync(scanner)
    App.shared.setNetworkActivityIndicatorVisible(false)
    @lastSync = NSDate.date.timeIntervalSince1970
    App.alert "Cache is synced, #{scanner.count(nil)} image(s) in database"
    p "[MOODSTOCKS SDK] DID SYNC. DATABASE SIZE = #{scanner.count(nil)} IMAGE(S)"
  end
  
  def scanner(scanner, failedToSyncWithError:error)
    App.shared.setNetworkActivityIndicatorVisible(false)
    p "[MOODSTOCKS SDK] Error : #{error.code}"
  end

end