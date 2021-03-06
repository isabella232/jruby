require_relative '../../spec_helper'

platform_is :aix do
  # In AIX, if getrlimit(2) is called multiple times with RLIMIT_DATA,
  # the first call and the subsequent calls return slightly different
  # values of rlim_cur, even if the process does nothing between
  # the calls.  This behavior causes some of the tests in this spec
  # to fail, so call Process.getrlimit(:DATA) once and discard the result.
  # Subsequent calls to Process.getrlimit(:DATA) should return
  # a consistent value of rlim_cur.
  Process.getrlimit(:DATA)
end

describe "Process.getrlimit" do
  platform_is_not :windows do
    it "returns a two-element Array of Integers" do
      result = Process.getrlimit Process::RLIMIT_CORE
      result.size.should == 2
      result.first.should be_kind_of(Integer)
      result.last.should be_kind_of(Integer)
    end

    context "when passed an Object" do
      before do
        @resource = Process::RLIMIT_CORE
      end

      it "calls #to_int to convert to an Integer" do
        obj = mock("process getrlimit integer")
        obj.should_receive(:to_int).and_return(@resource)

        Process.getrlimit(obj).should == Process.getrlimit(@resource)
      end

      it "raises a TypeError if #to_int does not return an Integer" do
        obj = mock("process getrlimit integer")
        obj.should_receive(:to_int).and_return(nil)

        -> { Process.getrlimit(obj) }.should raise_error(TypeError)
      end
    end

    context "when passed a Symbol" do
      it "coerces the short name into the full RLIMIT_ prefixed name" do
        Process.constants.grep(/\ARLIMIT_/) do |fullname|
          short = fullname[/\ARLIMIT_(.+)/, 1]
          Process.getrlimit(short.to_sym).should == Process.getrlimit(Process.const_get(fullname))
        end
      end

      it "raises ArgumentError when passed an unknown resource" do
        -> { Process.getrlimit(:FOO) }.should raise_error(ArgumentError)
      end
    end

    context "when passed a String" do
      it "coerces the short name into the full RLIMIT_ prefixed name" do
        Process.constants.grep(/\ARLIMIT_/) do |fullname|
          short = fullname[/\ARLIMIT_(.+)/, 1]
          Process.getrlimit(short).should == Process.getrlimit(Process.const_get(fullname))
        end
      end

      it "raises ArgumentError when passed an unknown resource" do
        -> { Process.getrlimit("FOO") }.should raise_error(ArgumentError)
      end
    end

    context "when passed on Object" do
      before do
        @resource = Process::RLIMIT_CORE
      end

      it "calls #to_str to convert to a String" do
        obj = mock("process getrlimit string")
        obj.should_receive(:to_str).and_return("CORE")
        obj.should_not_receive(:to_int)

        Process.getrlimit(obj).should == Process.getrlimit(@resource)
      end

      it "calls #to_int if #to_str does not return a String" do
        obj = mock("process getrlimit string")
        obj.should_receive(:to_str).and_return(nil)
        obj.should_receive(:to_int).and_return(@resource)

        Process.getrlimit(obj).should == Process.getrlimit(@resource)
      end
    end
  end

  platform_is :windows do
    it "is not implemented" do
      Process.respond_to?(:getrlimit).should be_false
      lambda do
        Process.getrlimit(nil)
      end.should raise_error NotImplementedError
    end
  end
end