require 'fileutils'

require 'spec_helper'
require 'bwoken'

describe Bwoken do

  describe '.app_name', :stub_proj_path do
    it "returns the app's name without the .app prefix" do
      stub_proj_path
      Bwoken.app_name.should == 'FakeProject'
    end
  end

  describe '.app_dir', :stub_proj_path do
    it "returns the app's name with the .app suffix" do
      stub_proj_path
      Bwoken.app_dir.should == "#{proj_path}/build/FakeProject.app"
    end
  end

  describe '#formatter' do
    it 'returns Bwoken::ColorfulFormatter' do
      subject.formatter.should be_kind_of(Bwoken::ColorfulFormatter)
    end
  end

  describe '.project_path' do
    it 'returns the root directory of the project' do
      Dir.should_receive(:pwd).and_return(:foo)
      Bwoken.project_path.should == :foo
    end
  end

  describe '.path_to_automation_template' do
    it 'returns the location of the Automation template', :platform => :osx do
      File.file?(Bwoken.path_to_automation_template).should be_true
    end
  end

  describe '.build_path', :stub_proj_path do
    context "when it doesn't yet exist" do
      it 'creates the build directory' do
        stub_proj_path
        FileUtils.rm_r("#{proj_path}/build")
        Bwoken.build_path
        File.directory?("#{proj_path}/build").should be_true
      end
    end

    it 'returns the build directory' do
      stub_proj_path
      Bwoken.build_path.should == "#{proj_path}/build"
    end
  end

  describe '.workspace', :stub_proj_path do
    it 'returns the workspace directory' do
      stub_proj_path
      Bwoken.workspace.should == "#{proj_path}/FakeProject.xcworkspace"
    end
  end

  describe '.path' do
    it 'returns bwokens working directory' do
      Bwoken.stub(:project_path => 'foo/bar')
      Bwoken.path.should == "foo/bar/integration"
    end
  end

  describe '.tmp_path' do
    it 'returns bwokens temporary directory' do
      Bwoken.stub(:path => 'foo/bar')
      Bwoken.tmp_path.should == "foo/bar/tmp"
    end
  end

  describe '.results_path', :stub_proj_path do
    context "when it doesn't yet exist" do
      it 'creates the results directory' do
        stub_proj_path
        File.should_receive(:directory?).with("#{proj_path}/integration/tmp/results").and_return(false)
        FileUtils.should_receive(:mkdir_p).with("#{proj_path}/integration/tmp/results")
        Bwoken.results_path
      end
    end
    it 'returns the results path' do
      stub_proj_path
      File.stub(:directory?).and_return(true)
      Bwoken.results_path.should == "#{proj_path}/integration/tmp/results"
    end
  end

end
