Pod::Spec.new do |s|
  s.name             = 'LHXBoltsAddition'
  s.version          = '0.1.4'
  s.summary          = 'Add-on for Bolts'
  s.description      = <<-DESC
          Add-on for Bolts
                       DESC

  s.homepage         = 'https://github.com/caoer/LHXBoltsAddition'
  s.license          = { :type => 'COMMERCIAL', :file => 'LICENSE' }
  s.author           = { 'caoer' => 'caoer115@gmail.com' }
  s.source           = { :git => 'https://github.com/caoer/LHXBoltsAddition.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'LHXBoltsAddition/Classes/**/*'
  s.dependency 'Bolts'
  s.dependency 'LHXCore'
end
