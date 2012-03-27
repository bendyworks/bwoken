def stub_out obj, method, value
  obj.stub(method => value)
  value
end
