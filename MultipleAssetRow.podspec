Pod::Spec.new do |s|
  s.name             = "MultipleAssetRow"
  s.version          = "3.0.0"
  s.summary          = "Eureka row for choosing multiple assets"
  s.homepage         = "https://github.com/lacyrhoades/MultipleAssetRow"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Lacy Rhoades" => "lacy@colordeaf.net" }
  s.source           = { git: "https://github.com/lacyrhoades/MultipleAssetRow.git" }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.ios.source_files = 'Shared/**/*', 'MultipleAssetRow/**/*'
  s.dependency 'Eureka', '~> 4.0'
end
