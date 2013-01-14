module Flash

  def showFlash
    @flashView = UIView.alloc.initWithFrame(self.view.bounds)
    @flashView.backgroundColor = UIColor.whiteColor
    self.view.addSubview(@flashView)

    UIView.animateWithDuration(0.4,
      animations:lambda { @flashView.alpha = 0.0 },
      completion:lambda { |finished| @flashView.removeFromSuperview }
    )
  end

end