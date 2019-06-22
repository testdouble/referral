require "test_helper"

module Refer
  class RunnerTest < ReferTest
    def test_fixture_1
      @file = "test/fixture/1.rb"
      runner = Runner.new(
        file_pattern: "test/fixture/1.r*"
      )

      result = runner.call

      defs = result.definitions
      assert_includes defs, bar = def_for(:Bar, :module, 2, 0)
      assert_includes defs, def_for(:STUFFS, :constant, 3, 2, bar)
      assert_includes defs, def_for(:baz, :static_method, 4, 2, bar)
      assert_includes defs, def_for(:qux!, :instance_method, 7, 2, bar)
      assert_includes defs, foo = def_for(:Foo, :class, 10, 2, bar)
      assert_includes defs, def_for(:THINGS, :constant, 11, 4, foo)
      assert_includes defs, def_for(:foz, :static_method, 13, 4, foo)
      assert_includes defs, def_for(:fiz, :instance_method, 16, 4, foo)

      refs = result.references
      # line 22: Bar.baz
      assert_includes refs, bar = ref_for(:Bar, :constant, 22, 0)
      assert_includes refs, ref_for(:baz, :call, 22, 0, bar)
      # line 24: puts "#{Bar::Foo::THINGS}!"
      assert_includes refs, bar = ref_for(:Bar, :constant, 24, 8)
      assert_includes refs, foo = ref_for(:Foo, :double_colon, 24, 8, bar)
      assert_includes refs, ref_for(:THINGS, :double_colon, 24, 8, foo)
      # line 26: Bar::Foo.new.fiz
      assert_includes refs, bar = ref_for(:Bar, :constant, 26, 0)
      assert_includes refs, foo = ref_for(:Foo, :double_colon, 26, 0, bar)
      assert_includes refs, new = ref_for(:new, :call, 26, 0, foo)
      assert_includes refs, ref_for(:fiz, :call, 26, 0, new)
    end

    private

    def def_for(name, type, line, column, parent = nil, file = @file)
      Value::Definition.new(
        name: name,
        node_type: Value::Definition::TYPES[type],
        parent: parent,
        file: file,
        line: line,
        column: column,
      )
    end

    def ref_for(name, type, line, column, parent = nil, file = @file)
      Value::Reference.new(
        name: name,
        node_type: Value::Reference::TYPES[type],
        parent: parent,
        file: file,
        line: line,
        column: column,
      )
    end
  end
end
