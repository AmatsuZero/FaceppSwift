Pod::Spec.new do |s|
    s.name = 'FaceppSwift'
    s.version = '0.1.8'
    s.license = 'MIT'
    s.summary = 'Facepp API Wrapper in Swift'
    s.homepage = 'https://github.com/AmatsuZero/FaceppSwift'
    s.authors = { 'Daubert Jiang' => 'jzh16s@hotmail.com' }
    s.source = { :git => 'https://github.com/AmatsuZero/FaceppSwift.git', :tag => s.version }
    s.swift_versions = ['5.0', '5.1']
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
    s.source_files = 'Sources/FaceppSwift/FaceppSwift.swift'
    s.frameworks = 'CFNetwork'
    s.default_subspec = 'Core'

    s.subspec 'Core' do |ss| 
      ss.ios.deployment_target = '10.0'
      ss.osx.deployment_target = '10.12'
      ss.tvos.deployment_target = '10.0'
      ss.watchos.deployment_target = '3.0'
      ss.source_files = 'Sources/FaceppSwift/**/*'
    end
    
    s.subspec 'UIKit' do |ss|
      ss.ios.deployment_target = '10.0'
      ss.tvos.deployment_target = '10.0'
      ss.watchos.deployment_target = '3.0'
      ss.source_files = 'UIKit+Facepp'
      ss.ios.framework = 'UIKit'
      ss.dependency 'FaceppSwift/Core'
    end

    s.subspec 'WebKit' do |ss|
      ss.ios.deployment_target = '10.0'
      ss.source_files = 'WebKit+Facepp'
      ss.ios.framework = 'UIKit', 'WebKit'
      ss.dependency 'FaceppSwift/UIKit'
    end
  end