require "test_helper"

module Referral
  class CliTest < ReferralTest
    def test_basic_use
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new([]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:1:0: module A
        a_1.rb:2:0: class A::Car
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_1.rb:4:2: instance_method A::Car#vroom!
        a_1.rb:8:0: module A::B
        a_2.rb:3:0: local_var_assign car
        a_2.rb:3:6: call A::Car.new
        a_2.rb:5:5: constant A::Car::THINGS
        a_2.rb:7:0: call car.vroom!
      RUBY
    end

    def test_variables
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[3.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        3.rb:1:0: class Neat
        3.rb:2:2: instance_method Neat#cool
        3.rb:3:4: local_var_assign Neat#cool->foo
        3.rb:5:4: instance_var_assign Neat#cool->@bar
        3.rb:7:4: class_var_assign Neat#cool->@@baz
        3.rb:9:4: global_var_assign Neat#cool->$qux
        3.rb:11:12: local_var foo
        3.rb:11:19: instance_var @bar
        3.rb:11:27: class_var @@baz
        3.rb:11:36: global_var $qux
        3.rb:13:2: constant_declaration Super::Duper::THINGS
        3.rb:14:7: constant Super::Duper::THINGS
      RUBY
    end

    def test_tab_delimited
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n vroom -d \t]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:4:2:	instance_method	A::Car#vroom!
        a_2.rb:7:0:	call	car.vroom!
      RUBY
    end

    def test_name_filter
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class A::Car
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_1.rb:4:2: instance_method A::Car#vroom!
        a_2.rb:3:6: call A::Car.new
        a_2.rb:5:5: constant A::Car::THINGS
      RUBY
    end

    def test_name_filter_plural
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n THING,vroom]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_1.rb:4:2: instance_method A::Car#vroom!
        a_2.rb:5:5: constant A::Car::THINGS
        a_2.rb:7:0: call car.vroom!
      RUBY
    end

    def test_name_filter_over_colon2
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class A::Car
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_1.rb:4:2: instance_method A::Car#vroom!
        a_2.rb:3:6: call A::Car.new
        a_2.rb:5:5: constant A::Car::THINGS
      RUBY
    end

    def test_exact_name
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class A::Car
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_1.rb:4:2: instance_method A::Car#vroom!
        a_2.rb:3:6: call A::Car.new
        a_2.rb:5:5: constant A::Car::THINGS
      RUBY
    end

    def test_exact_name_with_silly_joiner
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name A.Car#THINGS]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_2.rb:5:5: constant A::Car::THINGS
      RUBY
    end

    def test_full_name
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--full-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class A::Car
      RUBY
    end

    def test_full_name_plural_with_silly_joiners
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--full-name A::Car,A::Car.vroom!]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class A::Car
        a_1.rb:4:2: instance_method A::Car#vroom!
      RUBY
    end

    def test_exact_name_filter_plural
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name THING,vroom!]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:4:2: instance_method A::Car#vroom!
        a_2.rb:7:0: call car.vroom!
      RUBY
    end

    def test_pattern_filter
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-p THI]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: constant_declaration A::Car::THINGS
        a_2.rb:5:5: constant A::Car::THINGS
      RUBY
    end

    def test_default_exclude_unnamed
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[2.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        2.rb:1:5: call zap.+
        2.rb:1:5: local_var_assign zap
        2.rb:3:5: local_var_assign zip
        2.rb:3:5: call zip.*
        2.rb:5:5: call zoop.-
        2.rb:5:5: local_var_assign zoop
        2.rb:7:8: local_var zip
        2.rb:7:15: local_var zap
        2.rb:7:22: local_var zoop
      RUBY
    end

    def test_include_unnamed
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[--include-unnamed 2.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        2.rb:1:5: call zap.+
        2.rb:1:5: local_var_assign zap
        2.rb:3:5: local_var_assign zip
        2.rb:3:5: call zip.*
        2.rb:5:5: call zoop.-
        2.rb:5:5: local_var_assign zoop
        2.rb:7:8: local_var zip
        2.rb:7:15: local_var zap
        2.rb:7:22: local_var zoop
        2.rb:9:5: call []
        2.rb:11:5: call =~
      RUBY
    end

    def test_print_headers_pipe_delimited
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--print-headers -d | --full-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        location|type|full_name
        a_1.rb:2:0:|class|A::Car
      RUBY
    end

    def test_custom_column_ordering
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-c name,type]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        A module
        Car class
        THINGS constant_declaration
        vroom! instance_method
        B module
        car local_var_assign
        new call
        THINGS constant
        vroom! call
      RUBY
    end
  end
end
