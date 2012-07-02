require 'bwoken/coffeescript'
require 'stringio'

require 'spec_helper'

describe Bwoken::Coffeescript do
  let(:subject) { Bwoken::Coffeescript }

  describe '.precompile' do
    let(:test_coffee) {"foo = 1\n#import bazzle.js\nbar = 2"}
    it 'splits #import statements from other statements' do
      subject.precompile(test_coffee).should == ["#import bazzle.js\n", "foo = 1\nbar = 2"]
    end
  end

  describe '.compile' do
    it 'precompiles' do
      subject.should_receive(:precompile)
      IO.stub(:read)
      subject.context.stub(:call)
      subject.stub(:write)
      subject.compile 'a', 'b'
    end

    it 'cofffeescript-compiles' do
      subject.stub(:precompile)
      IO.stub(:read)
      subject.context.should_receive(:call)
      subject.stub(:write)
      subject.compile 'a', 'b'
    end

    it 'writes to disk' do
      subject.stub(:precompile)
      IO.stub(:read)
      subject.context.stub(:call)
      subject.should_receive(:write)
      subject.compile 'a', 'b'
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
