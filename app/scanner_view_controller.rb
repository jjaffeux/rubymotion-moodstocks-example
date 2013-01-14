class ScannerViewController < UIViewController
  include Flash
  include Spinner

  def initWithNibName(nibNameOrNil, bundle:nibBundleOrNil)
    super
    @scannerSession = MSScannerSession.alloc.initWithScanner(MSScanner.sharedInstance)
    @scannerSession.setScanOptions(MS_RESULT_TYPE_IMAGE)
    @scannerSession.setDelegate(self)
    self
  end

  def loadView
    super
    self.title = "SCANNER"
    videoFrame = [[0, 0],self.view.frame[1]]
    @videoPreview = UIView.alloc.initWithFrame(videoFrame)
    @videoPreview.backgroundColor = UIColor.blackColor
    @videoPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    @videoPreview.autoresizesSubviews = true
    self.view.addSubview(@videoPreview)

    self.view.when_tapped { snapAction }
  end

  def viewWillDisappear(animated)
    super
    @scannerSession.stopCapture
    @scannerSession.cancel
  end

  def viewDidLoad
    super
    videoPreviewLayer = @videoPreview.layer
    videoPreviewLayer.setMasksToBounds(true)
    
    captureLayer = @scannerSession.previewLayer
    captureLayer.setFrame(@videoPreview.bounds)
    
    videoPreviewLayer.insertSublayer(captureLayer, below:videoPreviewLayer.sublayers)

    @scannerSession.startCapture
  end

  def snapAction
    self.showFlash
    self.startSpinner
    @scannerSession.snap
    @scannerSession.pause
  end

  def shouldAutorotateToInterfaceOrientatio(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

  def session(session, didScan:result)
  end

  def session(scanner, failedToScan:error)
    self.stopSpinner
    @scannerSession.resume
  end

  def scannerWillSearch(scanner)
  end

  def scanner(scanner, didSearchWithResult:result)
    self.stopSpinner
    if result.nil?
      App.alert "Image not found"
    else
      App.alert "Image found #{result.getValue}"
    end
    @scannerSession.resume
  end

end