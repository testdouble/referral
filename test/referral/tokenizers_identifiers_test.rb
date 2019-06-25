require "test_helper"
require "referral/tokenizes_identifiers"
require "referral/value/token"
require "referral/token_types"

module Referral
  class TokenizesIdentifiersTest < ReferralTest
    FILE = "foo.rb"

    def subject
      @subject ||= TokenizesIdentifiers.new
    end

    def test_naked_module_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        module Neet
        end
      RUBY
      root_node = node.children.last
      root_token = token_for(root_node)

      result = subject.call(root_node, root_token)

      assert_equal 1, result.size
      assert_equal Value::Token.new(
        name: :Neet,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 1,
        column: 7
      ), result.first
      assert_equal result, root_token.identifiers
      assert_equal :Neet, root_token.name
      assert_equal "Neet", root_token.literal_name
      assert_equal "Neet", root_token.full_name
    end

    def test_nested_module_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        module Super::Neet
        end
      RUBY
      root_node = node.children.last
      root_token = token_for(root_node)

      result = subject.call(root_node, root_token)

      assert_equal 2, result.size
      assert_equal Value::Token.new(
        name: :Super,
        node_type: TOKEN_TYPES[:constant_ref],
        parent: root_token,
        file: FILE,
        line: 1,
        column: 7
      ), result[0]
      assert_equal Value::Token.new(
        name: :Neet,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 1,
        column: 7
      ), result[1]
      assert_equal result, root_token.identifiers
      assert_equal :Neet, root_token.name
      assert_equal "Super::Neet", root_token.literal_name
      assert_equal "Super::Neet", root_token.full_name
    end

    def test_2_deep_nested_module_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        module Really::Quite
          module Super::Duper::Neet
          end
        end
      RUBY
      quite_node = node.children.last
      quite_token = token_for(quite_node)
      subject.call(quite_node, quite_token) # for the side effect…
      root_node = node.children[2].children[1].children[2].children[1]
      root_token = token_for(root_node, quite_token)

      result = subject.call(root_node, root_token)

      assert_equal 3, result.size
      assert_equal Value::Token.new(
        name: :Super,
        node_type: TOKEN_TYPES[:constant_ref],
        parent: root_token,
        file: FILE,
        line: 2,
        column: 9
      ), result[0]
      assert_equal Value::Token.new(
        name: :Duper,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 2,
        column: 9
      ), result[1]
      assert_equal Value::Token.new(
        name: :Neet,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 2,
        column: 9
      ), result[2]
      assert_equal result, root_token.identifiers
      assert_equal :Neet, root_token.name
      assert_equal "Super::Duper::Neet", root_token.literal_name
      assert_equal "Really::Quite::Super::Duper::Neet", root_token.full_name
    end

    def test_2_deep_nested_class_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        class Really::Quite
          class Super::Duper::Neet
          end
        end
      RUBY
      quite_node = node.children.last
      quite_token = token_for(quite_node)
      subject.call(quite_node, quite_token) # for the side effect…
      root_node = quite_node.children.last.children.last.children.last
      root_token = token_for(root_node, quite_token)

      result = subject.call(root_node, root_token)

      assert_equal 3, result.size
      assert_equal Value::Token.new(
        name: :Super,
        node_type: TOKEN_TYPES[:constant_ref],
        parent: root_token,
        file: FILE,
        line: 2,
        column: 8
      ), result[0]
      assert_equal Value::Token.new(
        name: :Duper,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 2,
        column: 8
      ), result[1]
      assert_equal Value::Token.new(
        name: :Neet,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 2,
        column: 8
      ), result[2]
      assert_equal result, root_token.identifiers
      assert_equal :Neet, root_token.name
      assert_equal "Super::Duper::Neet", root_token.literal_name
      assert_equal "Really::Quite::Super::Duper::Neet", root_token.full_name
    end

    def test_constant_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        Foo::Bar::BAZ = "Stuff"
      RUBY
      root_node = node.children.last
      root_token = token_for(root_node)

      result = subject.call(root_node, root_token)

      assert_equal 3, result.size
      assert_equal Value::Token.new(
        name: :Foo,
        node_type: TOKEN_TYPES[:constant_ref],
        parent: root_token,
        file: FILE,
        line: 1,
        column: 0
      ), result[0]
      assert_equal Value::Token.new(
        name: :Bar,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 1,
        column: 0
      ), result[1]
      assert_equal Value::Token.new(
        name: :BAZ,
        node_type: TOKEN_TYPES[:double_colon],
        parent: root_token,
        file: FILE,
        line: 1,
        column: 0
      ), result[2]
      assert_equal result, root_token.identifiers
    end

    def test_instance_method_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        def foo(c)
        end
      RUBY
      root_node = node.children.last
      root_token = token_for(root_node)

      result = subject.call(root_node, root_token)

      assert_equal 0, result.size
      assert_equal result, root_token.identifiers
      assert_equal :foo, root_token.name
      assert_equal "foo", root_token.literal_name
      assert_equal "foo", root_token.full_name
    end

    def test_class_method_def
      node = RubyVM::AbstractSyntaxTree.parse <<~RUBY
        def self.bar(a, b)
        end
      RUBY
      root_node = node.children.last
      root_token = token_for(root_node)

      result = subject.call(root_node, root_token)

      assert_equal 0, result.size
      assert_equal result, root_token.identifiers
      assert_equal :bar, root_token.name
      assert_equal "bar", root_token.literal_name
      assert_equal "bar", root_token.full_name
    end

    private

    # reinvented here to avoid indirectly calling the thing under test
    def token_for(node, parent = nil)
      return unless (type = TOKEN_TYPES.values.find { |d|
                       d.token_type == :definition && node.type == d.ast_type
                     })

      Value::Token.new(
        name: type.name_finder.call(node),
        node_type: type,
        parent: parent,
        file: FILE,
        line: node.first_lineno,
        column: node.first_column
      )
    end
  end
end
