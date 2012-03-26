module StubProjPath

  def proj_path
    File.expand_path('../../tmp/FakeProject', __FILE__)
  end

  def stub_proj_path
    Dir.stub(:pwd => proj_path)
  end

end

RSpec.configure do |c|
  c.include StubProjPath, :stub_proj_path

  c.before(:all, :stub_proj_path) { FileUtils.mkdir_p(proj_path) }
end
