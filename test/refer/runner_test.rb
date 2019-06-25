require "test_helper"

module Refer
  class RunnerTest < ReferTest
    def setup
      @subject = Runner.new
    end

    def test_fixture_1
      @file = "test/fixture/1.rb"

      result = @subject.call(
        file_pattern: "test/fixture/1.r*"
      )

      defs = result.definitions
      defs.each { |d| d.identifiers = nil } # <- not ideal but makes assert hard
      assert_includes defs, bar = token_for(:Bar, :module, 2, 0)
      assert_includes defs, token_for(:STUFFS, :constant_def, 3, 2, bar)
      assert_includes defs, token_for(:baz, :class_method, 4, 2, bar)
      assert_includes defs, token_for(:qux!, :instance_method, 7, 2, bar)
      assert_includes defs, foo = token_for(:Foo, :class, 10, 2, bar)
      assert_includes defs, token_for(:THINGS, :constant_def, 11, 4, foo)
      assert_includes defs, token_for(:foz, :class_method, 13, 4, foo)
      assert_includes defs, token_for(:fiz, :instance_method, 16, 4, foo)

      refs = result.references
      # line 2: module Bar
      assert_includes refs, token_for(:Bar, :double_colon, 2, 7)
      # line 10: class Foo
      assert_includes refs, token_for(:Foo, :double_colon, 10, 8)
      # line 22: Bar.baz
      assert_includes refs, bar = token_for(:Bar, :constant_ref, 22, 0)
      assert_includes refs, token_for(:baz, :call, 22, 0, bar)
      # line 24: puts "#{Bar::Foo::THINGS}!"
      assert_includes refs, bar = token_for(:Bar, :constant_ref, 24, 8)
      assert_includes refs, foo = token_for(:Foo, :double_colon, 24, 8, bar)
      assert_includes refs, token_for(:THINGS, :double_colon, 24, 8, foo)
      # line 26: Bar::Foo.new.fiz
      assert_includes refs, bar = token_for(:Bar, :constant_ref, 26, 0)
      assert_includes refs, foo = token_for(:Foo, :double_colon, 26, 0, bar)
      assert_includes refs, new = token_for(:new, :call, 26, 0, foo)
      assert_includes refs, token_for(:fiz, :call, 26, 0, new)
    end

    private

    def token_for(name, type, line, column, parent = nil, file = @file)
      Value::Token.new(
        name: name,
        node_type: TOKEN_TYPES[type],
        parent: parent,
        file: file,
        line: line,
        column: column,
      )
    end
  end
end
