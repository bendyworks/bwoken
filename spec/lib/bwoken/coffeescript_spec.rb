require 'bwoken/coffeescript'
require 'stringio'

require 'spec_helper'

describe Bwoken::Coffeescript do
  let(:subject) { Bwoken::Coffeescript }

  describe '#compile' do
    it "compiles js to coffeescript" do
      subject.stub(:source_contents => 'a = 1')
      subject.compile.should match /var/
    end
  end

  describe '#capture_imports raw_javascript' do
    let(:test_js) {"var foo;\n#import bazzle.js\nvar bar;"}
    it "collects the #import tag" do
      subject.capture_imports(test_js)
      subject.import_strings.should == ["#import bazzle.js"]
    end
  end

  describe '#remove_imports raw_javascript' do
    let(:test_js) {"var foo;\n#import bazzle.js\nvar bar;"}
    it 'removes the #import tag' do
      subject.remove_imports(test_js).should == "var foo;\n\nvar bar;"
    end
  end

end
