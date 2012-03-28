RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.filter_run_excluding :platform => :osx unless RUBY_PLATFORM =~ /darwin/i
end

Dir[File.expand_path('../support', __FILE__) + '/**/*.rb'].each {|file| require file}
