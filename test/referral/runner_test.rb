require "test_helper"
require "referral/runner"
require "referral/value/options"

module Referral
  class RunnerTest < ReferralTest
    def setup
      @subject = Runner.new
    end

    def test_fixture_1
      @file = "test/fixture/1.rb"

      result = @subject.call(Value::Options.default(files: [@file]))

      tokens = result.tokens
      tokens.each { |d| d.identifiers = nil } # <- not ideal but makes assert hard
      assert_includes tokens, bar = token_for(:Bar, :module, 2, 0)
      assert_includes tokens, token_for(:STUFFS, :constant_def, 3, 2, bar)
      assert_includes tokens, token_for(:baz, :class_method, 4, 2, bar)
      assert_includes tokens, token_for(:qux!, :instance_method, 7, 2, bar)
      assert_includes tokens, foo = token_for(:Foo, :class, 10, 2, bar)
      assert_includes tokens, token_for(:THINGS, :constant_def, 11, 4, foo)
      assert_includes tokens, token_for(:foz, :class_method, 13, 4, foo)
      assert_includes tokens, token_for(:fiz, :instance_method, 16, 4, foo)
      # line 22: Bar.baz
      assert_includes tokens, bar = token_for(:Bar, :constant_ref, 22, 0, nil, true)
      assert_includes tokens, token_for(:baz, :call, 22, 0, bar)
      # line 24: puts "#{Bar::Foo::THINGS}!"
      assert_includes tokens, bar = token_for(:Bar, :constant_ref, 24, 8, nil, true)
      assert_includes tokens, foo = token_for(:Foo, :double_colon, 24, 8, bar, true)
      assert_includes tokens, token_for(:THINGS, :double_colon, 24, 8, foo)
      # line 26: Bar::Foo.new.fiz
      assert_includes tokens, bar = token_for(:Bar, :constant_ref, 26, 0, nil, true)
      assert_includes tokens, foo = token_for(:Foo, :double_colon, 26, 0, bar, true)
      assert_includes tokens, new = token_for(:new, :call, 26, 0, foo, true)
      assert_includes tokens, token_for(:fiz, :call, 26, 0, new)
    end

    private

    def token_for(name, type, line, column, parent = nil, hidden = nil)
      Value::Token.new(
        name: name,
        node_type: TOKEN_TYPES[type],
        parent: parent,
        file: @file,
        line: line,
        column: column,
        hidden: hidden
      )
    end
  end
end
