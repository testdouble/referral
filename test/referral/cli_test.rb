require "test_helper"

module Referral
  class CliTest < ReferralTest
    def test_basic_use
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new([]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:1:0: A (module)
        a_1.rb:2:0: A::Car (class)
        a_1.rb:3:2: A::Car::THINGS (constant_declaration)
        a_1.rb:4:2: A::Car#vroom! (instance_method)
        a_1.rb:8:0: A::B (module)
        a_2.rb:3:6: A::Car.new (call)
        a_2.rb:5:5: A::Car::THINGS (constant)
        a_2.rb:7:0: vroom! (call)
      RUBY
    end

    def test_tab_delimited
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n vroom -d \t]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:4:2:	A::Car#vroom!	(instance_method)
        a_2.rb:7:0:	vroom!	(call)
      RUBY
    end

    def test_name_filter
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: A::Car (class)
        a_1.rb:3:2: A::Car::THINGS (constant_declaration)
        a_1.rb:4:2: A::Car#vroom! (instance_method)
        a_2.rb:3:6: A::Car.new (call)
        a_2.rb:5:5: A::Car::THINGS (constant)
      RUBY
    end

    def test_name_filter_over_colon2
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: A::Car (class)
        a_1.rb:3:2: A::Car::THINGS (constant_declaration)
        a_1.rb:4:2: A::Car#vroom! (instance_method)
        a_2.rb:3:6: A::Car.new (call)
        a_2.rb:5:5: A::Car::THINGS (constant)
      RUBY
    end

    def test_exact_name
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: A::Car (class)
      RUBY
    end

    def test_pattern_filter
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-p THI]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: A::Car::THINGS (constant_declaration)
        a_2.rb:5:5: A::Car::THINGS (constant)
      RUBY
    end
  end
end
