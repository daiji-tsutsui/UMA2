# frozen_string_literal: true

module Uma2
  # Presentation for nonnegative distributions with $n$-dim
  class Positives < Array
    # TODO: 環境変数化
    NON_NEGATIVE_MARGIN = 1e-5

    def initialize(w = [])
      w.nil? ? super([]) : super(w)
      # NOTE: the 0-th element is dummy!!
      self.push(1.0) if empty?
    end

    # v: $(n-1)$-dim eta-vector
    def move!(v)
      v.each.with_index(1) do |v_i, i|
        self[i] += v_i
      end
    end

    # v: $(n-1)$-dim eta-vector
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
      self.map! { |v| [v, NON_NEGATIVE_MARGIN].max }
    end

    # $(n-1) \times (n-1)$ matrix
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
