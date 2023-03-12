# frozen_string_literal: true

module Uma2
  # Presentation for nonnegative distributions with $(n+1)$-dim
  class Positives < Array
    def initialize(w = [])
      w.nil? ? super([]) : super(w)
      # NOTE: the 0-th element is dummy!!
      self.push(1.0) if empty?
    end

    # v: $n$-dim eta-vector
    def move!(v)
      v.each.with_index(1) do |v_i, i|
        self[i] += v_i
      end
    end

    # v: $n$-dim eta-vector
    def move_with_natural_grad!(v)
      v_natural = fisher.map do |row|
        row.map.with_index { |entry, j| entry * v[j] }.sum
      end
      move!(v_natural)
    end

    def extend_to!(trg_size)
      ext = Array.new(trg_size - size, 1.0)
      self.concat(ext)
    end

    # Schur product a.k.a. Hadamard or element-wise product
    def schur(array)
      self.map.with_index { |r, i| r * array[i] }
    end

    # Inner-product
    def dot(array)
      schur(array).sum
    end

    private

    def normalize!
      margin = Settings.uma2.nonnegative_margin
      self.map! { |v| [v, margin].max }
    end

    # $n \times n$ matrix
    def fisher
      size1 = size - 1 # since 0-th element is dummy
      (0..size1 - 1).map do |i|
        (0..size1 - 1).map do |j|
          i == j ? self[i + 1] : 0.0
        end
      end
    end
  end
end
