require "test_helper"
require "referral/translates_node_to_token"

module Referral
  class ArityTest < ReferralTest
    def translate(node)
      TranslatesNodeToToken.new.call(node, nil, "foo.rb")
    end

    def test_call_ignore_arity
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        foo(a, b)
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal TOKEN_TYPES[:function_call], token.node_type
    end

    def test_call_arity0
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        foo()
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 0, token.arity
    end

    def test_call_arity1
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        foo a
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 1, token.arity
    end

    def test_call_arity2
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        foo(a, b)
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 2, token.arity
    end

    def test_member_call_arity
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        bar.foo(a, b, c)
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 3, token.arity
    end

    def test_class_call_arity
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        BAR::foo(a, b, c, d)
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 4, token.arity
    end

    def test_call_kwargs_arity
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        foo(a: 1, b: 2)
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 1, token.arity
    end

    def test_call_kwargs_and_positional_arity
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        foo(a, b: 2, c: 3)
      RUBY
      root_node = node.children.last
      token = translate(root_node)
      assert_equal 2, token.arity
    end
  end
end
