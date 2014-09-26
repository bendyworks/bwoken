require 'fileutils'

require 'spec_helper'
require 'bwoken'

describe Bwoken do

  describe '.app_name', :stub_proj_path do
    it "returns the app's name without the .app prefix" do
      stub_proj_path
      Bwoken.stub(:workspace_or_project => "#{proj_path}/FakeProject.xcworkspace")
      Bwoken.app_name.should == 'FakeProject'
    end
  end

  describe '.project_path' do
    it 'returns the root directory of the project' do
      Dir.should_receive(:pwd).and_return(:foo)
      Bwoken.project_path.should == :foo
    end
  end

  describe '.workspace_or_project_flag', :stub_proj_path do
    context 'xcworkspace exists' do
      it 'returns the workspace flag' do
        File.stub(:exists? => true)
        stub_proj_path
        Bwoken.stub(:xcworkspace => "#{proj_path}/FakeProject.xcworkspace")
        Bwoken.workspace_or_project_flag.should == "-workspace \"#{proj_path}/FakeProject.xcworkspace\""
      end
    end

    context 'no xcworkspace' do
      it 'returns the xcodeproj project flag' do
        File.stub(:exists? => false)
        stub_proj_path
        Bwoken.stub(:xcodeproj => "#{proj_path}/FakeProject.xcodeproj")
        Bwoken.workspace_or_project_flag.should == "-project \"#{proj_path}/FakeProject.xcodeproj\""
      end
    end
  end


  describe '.xcworkspace', :stub_proj_path do
    it 'returns the workspace directory' do
      stub_proj_path

      Dir.should_receive(:[]).
        with("#{proj_path}/*.xcworkspace").
        and_return(["#{proj_path}/FakeProject.xcworkspace"])

      Bwoken.xcworkspace
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
