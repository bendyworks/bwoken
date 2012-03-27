require 'bwoken/coffeescript'
require 'stringio'

describe Bwoken::Coffeescript do
  let(:subject) { Bwoken::Coffeescript.new('foo') }
  describe '.source_folder' do
    it "should be 'automation'" do
      Bwoken::Coffeescript.source_folder.should match /automation\/coffeescript\Z/
    end
  end

  describe '.destination_folder' do
    it "should be 'automation'" do
      Bwoken::Coffeescript.destination_folder.should match /automation\/javascript\Z/
    end
  end

  describe '.test_files' do
    it 'wildcard includes coffeescript files' do
      Bwoken::Coffeescript.stub(:source_folder => 'z_source_folder')
      Bwoken::Coffeescript.test_files.should == 'z_source_folder/*.coffee'
    end
  end

  describe '.compile_all' do
    it 'calls make on each new instance of a coffeescript file' do
      Dir.should_receive(:[]).with('foo/*.coffee').and_return(['foo/bar.coffee'])
      Bwoken::Coffeescript.stub(:test_files => 'foo/*.coffee')

      coffee_stub = double('coffeescript')
      coffee_stub.should_receive(:make)
      Bwoken::Coffeescript.should_receive(:new).and_return(coffee_stub)

      Bwoken::Coffeescript.compile_all
    end
  end

  describe '#initialize filename' do
    it 'sets @source_file to filename' do
      filename = 'bazzle'
      Bwoken::Coffeescript.new(filename).instance_variable_get('@source_file').should == filename
    end
  end

  describe '#destination_file' do
    it 'is the path to the desired output (.js) file' do
      filename = 'bazzle.coffee'
      stub_folder = 'stub_folder'
      Bwoken::Coffeescript.stub(:destination_folder => stub_folder)
      subject = Bwoken::Coffeescript.new(filename)
      subject.destination_file.should == "stub_folder/bazzle.js"
    end
  end

  describe '#make' do
    before do
      subject.stub(:compile)
      subject.stub(:translate_to_uiautomation)
      subject.stub(:save)
    end

    it 'compiles' do
      subject.should_receive(:compile).once
      subject.make
    end

    it 'translates the compiled js' do
      test_js = '({js:"good"})();'
      subject.stub(:compile => test_js)
      subject.should_receive(:translate_to_uiautomation).with(test_js)
      subject.make
    end

    it 'saves the translated js' do
      test_js = 'eval {coffee: "pythony"}'
      subject.stub(:translate_to_uiautomation => test_js)
      subject.should_receive(:save).with(test_js)
      subject.make
    end
  end

  describe '#compile' do
    it "compiles js to coffeescript" do
      subject.stub(:source_contents => 'a = 1')
      subject.compile.should match /var/
    end
  end

  describe '#translate_to_uiautomation raw_javascript' do
    it "does something with the #import tag"
  end

  describe '#save javascript' do
    it 'saves the javascript to the destination_file' do
      stringio = StringIO.new
      destination_file = 'bazzle/bar.js'
      subject.stub(:destination_file => destination_file)

      File.should_receive(:open).
        any_number_of_times.
        with(destination_file, 'w').
        and_yield(stringio)

      subject.save 'some javascript'
      stringio.string.strip.should == 'some javascript'
    end
  end

end
