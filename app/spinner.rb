module Spinner

  def startSpinner
    @spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    @spinner.center = [self.view.size.width / 2, self.view.size.height / 2]
    @spinner.hidesWhenStopped = true
    @spinner.startAnimating
    self.view.addSubview(@spinner)
  end

  def stopSpinner
    @spinner.stopAnimating
    @spinner.removeFromSuperview
  end

end