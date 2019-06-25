require "test_helper"

class Refer::CliTest < ReferTest
  def test_basic_use
    fake_out, fake_err, exit_code = do_with_fake_io(cwd: "test/fixture/a") {
      Refer::Cli.new([]).call
    }
    assert_equal 0, exit_code
    assert_empty fake_err.string
    assert_equal <<~RUBY, fake_out.string
      a_1.rb:1:0: A (module)
      a_1.rb:2:0: A::Car (class)
      a_1.rb:3:2: A::Car::THINGS (constant_declaration)
      a_1.rb:4:2: A::Car#vroom! (instance_method)
      a_1.rb:8:0: A::B (module)
      a_2.rb:3:6: A::Car.new (call)
      a_2.rb:3:6: A::Car (constant_reference)
      a_2.rb:3:6: A (constant_reference)
      a_2.rb:5:5: A::Car::THINGS (constant_reference)
      a_2.rb:5:5: A::Car (constant_reference)
      a_2.rb:5:5: A (constant_reference)
      a_2.rb:7:0: vroom! (call)
      a_1.rb:1:7: A (constant_reference)
      a_1.rb:2:6: A::Car (constant_reference)
      a_1.rb:2:6: A (constant_reference)
      a_1.rb:8:7: A::B (constant_reference)
      a_1.rb:8:7: A (constant_reference)
    RUBY
  end
end
