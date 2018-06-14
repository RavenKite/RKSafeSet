
Pod::Spec.new do |s|

  s.name         = "RKSafeSet"

  s.version      = "0.1.0"

  s.summary      = "NSArray和NSDictionary以JSON格式打印；显示中文字符；安全的取值、赋值"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { '李沛倬' => 'lipeizhuo0528@outlook.com' }

  s.homepage     = "https://github.com/RavenKite/RKSafeSet"

  s.source       = { :git => 'https://github.com/RavenKite/RKSafeSet.git', :tag => s.version.to_s }

  s.platform     = :ios, "6.0"

  s.source_files = 'Classes/**/*'

  s.frameworks   = 'Foundation'

end
