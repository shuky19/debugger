require_relative 'test_helper'

describe "Jump Command" do
  include TestDsl

  describe "successful" do
    it "must jump with absolute line number" do
      enter 'break 6', 'cont', "jump 8 #{fullpath('jump')}"
      debug_file('jump') { state.line.must_equal 8 }
    end

    it "must not initialize skipped variables during jump" do
      enter 'break 6', 'cont', "jump 8 #{fullpath('jump')}", 'next'
      enter 'var local'
      debug_file('jump')
      check_output_includes "a => 2", "b => nil", "c => nil", "d => 5"
    end

    it "must jump with relative line number (-)" do
      enter 'break 8', 'cont', "jump -2 #{fullpath('jump')}"
      debug_file('jump') { state.line.must_equal 6 }
    end

    it "must jump with relative line number (+)" do
      enter 'break 8', 'cont', "jump +2 #{fullpath('jump')}"
      debug_file('jump') { state.line.must_equal 10 }
    end
  end

  describe "errors" do
    it "must show an error if line number is invalid" do
      enter 'jump bla'
      debug_file('jump')
      check_output_includes "Bad line number: bla", interface.error_queue
    end

    it "must show an error if line number is not specified" do
      enter 'jump'
      debug_file('jump')
      check_output_includes '"jump" must be followed by a line number', interface.error_queue
    end

    describe "when there is no active code in specified line" do
      it "must not jump to there" do
        enter "jump 13 #{fullpath('jump')}"
        debug_file('jump') { state.line.must_equal 3 }
      end

      it "must show an error" do
        enter "jump 13 #{fullpath('jump')}"
        debug_file('jump')
        check_output_includes "Couldn't find active code at #{fullpath('jump')}:13", interface.error_queue
      end
    end
  end
end
