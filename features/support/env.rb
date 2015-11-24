require 'aruba/cucumber'
require 'fileutils'

Before do
  # @dirs = ["somewhere/else"] # working dir during test
  FileUtils.cp('airparse.rb', 'tmp/aruba/')
  # Dir.mkdir(directory_name) unless File.exists?(directory_name)
  FileUtils.mkdir_p 'tmp/aruba/lib/'
  FileUtils.cp('lib/airparselib.rb', 'tmp/aruba/lib/')
  FileUtils.cp('lib/airparsedefaultrules.rb', 'tmp/aruba/lib/')
  FileUtils.cp('lib/norules.rb', 'tmp/aruba/lib/')
end

After do |scenario|
  # Do something after each scenario.
  # The +scenario+ argument is optional, but
  # if you use it, you can inspect status with
  # the #failed?, #passed? and #exception methods.

  # if scenario.failed?
  #   subject = "[Project X] #{scenario.exception.message}"
  #   send_failure_email(subject)
  # end

  # Tell Cucumber to quit after this scenario is done - if it failed.
  Cucumber.wants_to_quit = true if scenario.failed?
end

Aruba.configure do |config|
  config.exit_timeout = 500 # 500s timeout should allow 1000x stress test
end

# require 'aruba'
# require 'aruba/in_process'

# Aruba.process = Aruba::Processes::InProcess
# Aruba.process.main_class = MyMain
