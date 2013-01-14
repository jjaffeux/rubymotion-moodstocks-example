# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'

Bundler.require

require 'bubble-wrap/all' #tweak this on your needs bubblewrap.io

Motion::Project::App.setup do |app|
  app.name = 'rubymotion-moodstocks-example'
  app.interface_orientations = [:portrait]
  app.deployment_target = "5.0"
  app.sdk_version = "6.0"

  app.codesign_certificate = "iPhone Developer: Joffrey Jaffeux"
  app.provisioning_profile = "wildcard_dev.mobileprovision"

  app.frameworks += ['Foundation', 'UIKit', 'CoreGraphics', 'AVFoundation', 'CoreVideo', 'CoreMedia', 'QuartzCore', 'ImageIO', 'Accelerate']

  app.vendor_project('vendor/MoodstocksSDK', :static)
end

