require "test_helper"

class Refer::CliTest < ReferTest
  def test_basic_use
    fake_out, fake_err, exit_code = do_with_fake_io(cwd: "test/fixture/a") {
      Refer::Cli.new([]).call
    }
    assert_equal 0, exit_code
    assert_empty fake_err.string
    assert_equal <<~RUBY, fake_out.string
      a_1.rb:1:0: def: A (module)
      a_1.rb:2:0: def: Car (class)
      a_1.rb:3:2: def: Car#vroom! (instance_method)
      a_1.rb:7:0: def: B (module)
      a_2.rb:3:6: ref: A::Car.new (call)
      a_2.rb:3:6: ref: A::Car (double_colon)
      a_2.rb:3:6: ref: A (constant)
      a_2.rb:5:0: ref: vroom! (call)
      a_1.rb:1:7: ref: A (double_colon)
      a_1.rb:2:6: ref: A::Car (double_colon)
      a_1.rb:2:6: ref: A (constant)
      a_1.rb:7:7: ref: A::B (double_colon)
      a_1.rb:7:7: ref: A (constant)
    RUBY
  end
end
