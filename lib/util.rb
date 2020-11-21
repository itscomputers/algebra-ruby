module Util
  def bezout(a, b)
    pairs = [[1, 0], [0, 1]]
    orig = [a, b]

    while b != 0
      q, r = a.divmod(b)
      a, b = b, r
      next_pair = pairs.transpose.map { |(u0, u1)| u0 - u1 * q }
      pairs = [*pairs, next_pair].drop(1)
    end

    result = pairs.first
    if orig.zip(result).map { |(r, s)| r * s }.sum < 0
      result.map { |u| -u }
    else
      result
    end
  end

  module_function :bezout
end

