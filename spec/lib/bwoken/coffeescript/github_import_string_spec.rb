require 'bwoken/coffeescript/github_import_string'

describe Bwoken::Coffeescript::GithubImportString do
  let(:string) { '#github alexvollmer/tuneup_js/tuneup.js' }
  subject { Bwoken::Coffeescript::GithubImportString.new(string) }

  describe '#parse' do
    it 'ensures the github repo is pulled' do
      subject.should_receive(:ensure_github)
      subject.parse
    end
  end

  describe '#to_s' do
    it 'resolves to the right path' do
      Bwoken.stub(:path => '/foo/integration')
      expect(subject.to_s).to eq(%Q|#import "/foo/integration/github/alexvollmer/tuneup_js/tuneup.js"|)
    end
  end

  describe '#ensure_github' do
    before { subject.stub(:repo_exists? => repo_exists) }
    context 'when repo is not downloaded' do
      let(:repo_exists) { false }
      it 'cleans and downloads the repo' do
        subject.should_receive(:clean_repo)
        subject.should_receive(:download_repo)
        subject.send(:ensure_github)
      end
    end

    context 'when repo is already downloaded' do
      let(:repo_exists) { true }
      it 'does not download the repo' do
        subject.should_not_receive(:download_repo)
        subject.send(:ensure_github)
      end

      context 'when FORCE is enabled' do
        around do |ex|
          begin
            ENV['FORCE_GITHUB'] = 'true'
            ex.run
          ensure
            ENV.delete('FORCE_GITHUB')
          end
        end

        it 'cleans and downloads the repo' do
          subject.should_receive(:clean_repo)
          subject.should_receive(:download_repo)
          subject.send(:ensure_github)
        end
      end

    end
  end

  describe '#clean_repo' do
    before { subject.stub(:repo_exists? => repo_exists) }

    context 'when the repo exists' do
      let(:repo_exists) { true }
      it 'deletes the repo directory' do
        subject.should_receive(:delete_repo)
        subject.send(:clean_repo)
      end
    end

    context 'when the repo does not exist' do
      let(:repo_exists) { false }
      it 'does not try to delete the repo directory' do
        subject.should_not_receive(:delete_repo)
        subject.send(:clean_repo)
      end
    end
  end

  describe '#delete_repo' do
    it 'deletes the repo' do
      subject.stub(:repo_path => '../github/account/project')
      FileUtils.should_receive(:rm_rf).with('../github/account/project')
      subject.send(:delete_repo)
    end
  end

  describe '#github_repo_path' do
    it 'returns the right repo path' do
      subject.stub(:repo_name => 'account/project')
      Bwoken.stub(:path => 'prefix')
      expect(subject.send(:repo_path)).to eq('prefix/github/account/project')
    end
  end

  describe '#parse_parts' do
    shared_examples_for 'correctly parsing repo name' do
      it 'parses the repo name' do
        expect(subject.repo_name).to eq('alexvollmer/tuneup_js')
      end
      it 'parses the file path' do
        expect(subject.file_path).to eq('tuneup.js')
      end
    end

    context 'with a non-quoted project' do
      let(:string) { '#github alexvollmer/tuneup_js/tuneup.js' }
      it_should_behave_like 'correctly parsing repo name'
    end

    context 'with a single-quoted project' do
      let(:string) { "#github 'alexvollmer/tuneup_js/tuneup.js'" }
      it_should_behave_like 'correctly parsing repo name'
    end

    context 'with a double-quoted project' do
      let(:string) { '#github "alexvollmer/tuneup_js/tuneup.js"' }
      it_should_behave_like 'correctly parsing repo name'
    end
  end

  describe '#download_repo' do
    it 'clones the repo then deletes .git' do
      subject.should_receive(:prepare_repo_path).ordered
      subject.should_receive(:clone_repo).ordered
      subject.should_receive(:delete_dot_git).ordered
      subject.send(:download_repo)
    end
  end

end
