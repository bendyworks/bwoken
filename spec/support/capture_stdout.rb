def capture_stdout
  begin
    result = StringIO.new
    $stdout = result
    yield
  ensure
    $stdout = STDOUT
  end
  result.string
end

