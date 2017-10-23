
Pod::Spec.new do |s|

  s.name         = "SwiftF"
  s.version      = "0.0.7"
  s.summary      = "mobile frame"

  s.homepage     = "https://github.com/deo24/SwiftF"

  s.license      = "MIT"

  s.author       = { "deo24" => "email@address.com" }

  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/deo24/SwiftF.git", :tag => s.version }


  s.source_files = "SwiftF", "SwiftF/*.{swift}"
  s.requires_arc = true
end
