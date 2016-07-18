require_relative 'pw_app'

run Rack::URLMap.new({
  '/pw' => PwApp,
})
