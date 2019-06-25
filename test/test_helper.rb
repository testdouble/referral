$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "referral"

require "minitest/autorun"

class ReferralTest < Minitest::Test
  make_my_diffs_pretty!

  def pry!(b)
    require "pry"
    b.pry
  end

  def do_with_fake_io(cwd: Dir.pwd, fake_out: StringIO.new, fake_err: StringIO.new)
    og_cwd = Dir.pwd
    og_stdout, og_stderr = $stdout, $stderr

    Dir.chdir(cwd)
    $stdout, $stderr = fake_out, fake_err
    result = yield
    $stdout, $stderr = og_stdout, og_stderr
    Dir.chdir(og_cwd)

    [fake_out, fake_err, result]
  ensure
    $stdout, $stderr = og_stdout, og_stderr
    Dir.chdir(og_cwd)
  end
end
