module Hamming

  ALGOS = %i(compute1 compute2 compute3)

  module_function

  def compute(this, other, algo_name = :compute1)
    raise ArgumentError, 'string lengths must be equal' unless this.size == other.size
    __send__(algo_name, this, other)
  end

  def compute1(this, other)
    this_chars  = this.to_s.split(//)
    other_chars = other.to_s.split(//)
    this_chars.zip(other_chars).count { |a, b| a != b }
  end

  # with lambdas
  def compute2(this, other)
    charser = -> (val)  { val.to_s.split(//) }
    matcher = -> (unit) { unit.first != unit.last }
    charser.(this).zip(charser.(other)).count(&matcher)
  end

  # squishier
  def compute3(this, other)
    0.upto(this.size).count { |i| this.slice(i) != other.slice(i) }
  end

  # squishier-still
  def compute4(o1, o2)
    (0...(o1.size)).count { |i| o1[i] != o2[i] }
  end

end
