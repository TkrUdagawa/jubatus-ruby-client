# This file is auto-generated from ../src/server/regression.idl
# *** DO NOT EDIT ***

require 'msgpack/rpc'

module Jubatus

class Config_data
  def to_msgpack(out = '')
    [@method, @config].to_msgpack(out)
  end

  def from_unpacked(unpacked)
    @method, @config = unpacked
  end



  attr_accessor :method, :config
end

class Datum
  def to_msgpack(out = '')
    [@string_values, @num_values].to_msgpack(out)
  end

  def from_unpacked(unpacked)
    @string_values, @num_values = unpacked
  end



  attr_accessor :string_values, :num_values
end

end