require "test_helper"

module Referral
  class CliTest < ReferralTest
    def test_basic_use
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new([]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:1:0: module  A
        a_1.rb:2:0: class  A::Car
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_1.rb:4:2: instance_method A::Car vroom!
        a_1.rb:5:4: function_call A::Car#vroom! puts
        a_1.rb:8:0: module  A::B
        a_2.rb:1:0: function_call  require_relative
        a_2.rb:3:0: local_var_assign  car
        a_2.rb:3:6: call  A::Car.new
        a_2.rb:5:0: function_call  puts
        a_2.rb:5:5: constant  A::Car::THINGS
        a_2.rb:7:0: call  car.vroom!
      RUBY
    end

    def test_variables
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[3.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        3.rb:1:0: class  Neat
        3.rb:2:2: instance_method Neat cool
        3.rb:3:4: local_var_assign Neat#cool foo
        3.rb:5:4: instance_var_assign Neat#cool @bar
        3.rb:7:4: class_var_assign Neat#cool @@baz
        3.rb:9:4: global_var_assign Neat#cool $qux
        3.rb:11:4: function_call Neat#cool puts
        3.rb:11:12: local_var  foo
        3.rb:11:19: instance_var  @bar
        3.rb:11:27: class_var  @@baz
        3.rb:11:36: global_var  $qux
        3.rb:13:2: constant_declaration  Super::Duper::THINGS
        3.rb:14:2: function_call Neat puts
        3.rb:14:7: constant  Super::Duper::THINGS
      RUBY
    end

    def test_tab_delimited
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n vroom -d \t]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:4:2:	instance_method	A::Car	vroom!
        a_1.rb:5:4:	function_call	A::Car#vroom!	puts
        a_2.rb:7:0:	call		car.vroom!
      RUBY
    end

    def test_name_filter
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class  A::Car
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_1.rb:4:2: instance_method A::Car vroom!
        a_1.rb:5:4: function_call A::Car#vroom! puts
        a_2.rb:3:6: call  A::Car.new
        a_2.rb:5:5: constant  A::Car::THINGS
      RUBY
    end

    def test_name_filter_plural
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n THING,vroom]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_1.rb:4:2: instance_method A::Car vroom!
        a_1.rb:5:4: function_call A::Car#vroom! puts
        a_2.rb:5:5: constant  A::Car::THINGS
        a_2.rb:7:0: call  car.vroom!
      RUBY
    end

    def test_name_filter_over_colon2
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-n A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class  A::Car
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_1.rb:4:2: instance_method A::Car vroom!
        a_1.rb:5:4: function_call A::Car#vroom! puts
        a_2.rb:3:6: call  A::Car.new
        a_2.rb:5:5: constant  A::Car::THINGS
      RUBY
    end

    def test_exact_name
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class  A::Car
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_1.rb:4:2: instance_method A::Car vroom!
        a_1.rb:5:4: function_call A::Car#vroom! puts
        a_2.rb:3:6: call  A::Car.new
        a_2.rb:5:5: constant  A::Car::THINGS
      RUBY
    end

    def test_exact_name_with_silly_joiner
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name A.Car#THINGS]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_2.rb:5:5: constant  A::Car::THINGS
      RUBY
    end

    def test_full_name
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--full-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class  A::Car
      RUBY
    end

    def test_full_name_plural_with_silly_joiners
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--full-name A::Car,A::Car.vroom!]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:2:0: class  A::Car
        a_1.rb:4:2: instance_method A::Car vroom!
      RUBY
    end

    def test_exact_name_filter_plural
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--exact-name THING,vroom!]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:4:2: instance_method A::Car vroom!
        a_1.rb:5:4: function_call A::Car#vroom! puts
        a_2.rb:7:0: call  car.vroom!
      RUBY
    end

    def test_pattern_filter
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-p THI[Nn]G]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a_1.rb:3:2: constant_declaration A::Car THINGS
        a_2.rb:5:5: constant  A::Car::THINGS
      RUBY
    end

    def test_default_exclude_unnamed
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[2.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        2.rb:1:0: function_call  puts
        2.rb:1:5: local_var_assign  zap
        2.rb:1:5: call  zap.+
        2.rb:3:0: function_call  puts
        2.rb:3:5: local_var_assign  zip
        2.rb:3:5: call  zip.*
        2.rb:5:0: function_call  puts
        2.rb:5:5: local_var_assign  zoop
        2.rb:5:5: call  zoop.-
        2.rb:7:0: function_call  puts
        2.rb:7:8: local_var  zip
        2.rb:7:15: local_var  zap
        2.rb:7:22: local_var  zoop
        2.rb:9:0: function_call  puts
        2.rb:11:0: function_call  puts
      RUBY
    end

    def test_include_unnamed
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[--include-unnamed 2.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        2.rb:1:0: function_call  puts
        2.rb:1:5: local_var_assign  zap
        2.rb:1:5: call  zap.+
        2.rb:3:0: function_call  puts
        2.rb:3:5: local_var_assign  zip
        2.rb:3:5: call  zip.*
        2.rb:5:0: function_call  puts
        2.rb:5:5: local_var_assign  zoop
        2.rb:5:5: call  zoop.-
        2.rb:7:0: function_call  puts
        2.rb:7:8: local_var  zip
        2.rb:7:15: local_var  zap
        2.rb:7:22: local_var  zoop
        2.rb:9:0: function_call  puts
        2.rb:9:5: call  []
        2.rb:11:0: function_call  puts
        2.rb:11:5: call  =~
      RUBY
    end

    def test_print_headers_pipe_delimited
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[--print-headers -d | --full-name A::Car]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        location|type|scope|name
        a_1.rb:2:0:|class||A::Car
      RUBY
    end

    def test_custom_column_ordering
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture/a") {
        Cli.new(%w[-c full_name,type]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        A module
        A::Car class
        A::Car::THINGS constant_declaration
        A::Car#vroom! instance_method
        A::Car#vroom!.puts function_call
        A::B module
        require_relative function_call
        car local_var_assign
        A::Car.new call
        puts function_call
        A::Car::THINGS constant
        car.vroom! call
      RUBY
    end

    def test_failure_to_parse
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[unparseable.rb]).call
      }
      assert_equal <<~RUBY, fake_err.string
        ERROR: Failed to parse "unparseable.rb": syntax error, unexpected end-of-input, expecting end (SyntaxError)
      RUBY
      assert_empty fake_out.string
    end

    def test_passing_a_directory
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[a]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        a/a_1.rb:1:0: module  A
        a/a_1.rb:2:0: class  A::Car
        a/a_1.rb:3:2: constant_declaration A::Car THINGS
        a/a_1.rb:4:2: instance_method A::Car vroom!
        a/a_1.rb:5:4: function_call A::Car#vroom! puts
        a/a_1.rb:8:0: module  A::B
        a/a_2.rb:1:0: function_call  require_relative
        a/a_2.rb:3:0: local_var_assign  car
        a/a_2.rb:3:6: call  A::Car.new
        a/a_2.rb:5:0: function_call  puts
        a/a_2.rb:5:5: constant  A::Car::THINGS
        a/a_2.rb:7:0: call  car.vroom!
      RUBY
    end

    def test_passing_a_not_existing_file
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[bs.js]).call
      }
      assert_equal <<~RUBY, fake_err.string
        ERROR: Failed to read "bs.js": No such file or directory @ rb_sysopen - bs.js (Errno::ENOENT)
      RUBY
      assert_empty fake_out.string
    end

    def test_scope_sort
      fake_out, fake_err, _ = do_with_fake_io(cwd: "test/fixture") {
        Cli.new(%w[-s scope 5.rb]).call
      }
      assert_empty fake_err.string
      assert_equal <<~RUBY, fake_out.string
        5.rb:4:0: module  X
        5.rb:12:0: class  X::W
        5.rb:22:0: class  X::W
        5.rb:13:2: instance_method X::W p?
        5.rb:23:2: instance_method X::W r?
        5.rb:1:0: module  Z
        5.rb:7:0: module  Z
        5.rb:8:2: class Z Y
        5.rb:17:0: class  Z::Y
        5.rb:18:2: instance_method Z::Y q?
      RUBY
    end
  end
end
