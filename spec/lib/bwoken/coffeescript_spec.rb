require 'bwoken/coffeescript'
require 'stringio'

require 'spec_helper'

describe Bwoken::Coffeescript do
  let(:subject) { Bwoken::Coffeescript }

  describe '.precompile' do
    describe '"#import"' do
      let(:test_coffee) {"foo = 1\n#import bazzle.js\nbar = 2"}
      it 'splits #import statements from other statements' do
        subject.precompile(test_coffee).should == [
          ["#import bazzle.js\n"],
          ["foo = 1\n", "bar = 2"]
        ]
      end
    end

    describe '"#github"' do
      let(:test_coffee) {"#github alexvollmer/tuneup_js\n#import bazzle.js\nfoo = 1\nbar = 2"}
      it 'converts github to import' do
        subject.precompile(test_coffee).should == [
          ["#github alexvollmer/tuneup_js\n", "#import bazzle.js\n"],
          ["foo = 1\n", "bar = 2"]
        ]
      end
    end
  end

  describe '.compile' do
    before do
      subject.stub(:precompile => [[], []])
      IO.stub(:read)
      subject.stub(:write)
      subject.stub(:coffeescript_to_javascript)
      subject.stub(:githubs_to_imports)
    end

    after { subject.compile 'a', 'b' }

    it 'precompiles' do
      subject.should_receive(:precompile)
    end

    it 'cofffeescript-compiles' do
      subject.should_receive(:coffeescript_to_javascript)
    end

    it 'resolves github imports' do
      subject.should_receive(:githubs_to_imports)
    end

    it 'writes to disk' do
      subject.should_receive(:write)
    end
  end

  describe '.write' do
    it 'saves the javascript to the destination_file' do
      stringio = StringIO.new
      destination_file = 'bazzle/bar.js'

      File.should_receive(:open).with(destination_file, 'w').and_yield(stringio)

      subject.write('foo', '', 'bar', :to => destination_file)

      stringio.string.should == "foo\nbar\n"
    end
  end

end
