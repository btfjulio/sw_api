require_relative './weight_list.rb'
class BaseSuplement < ApplicationRecord
    belongs_to :brand, optional: true
    has_many :sup_photos, dependent: :destroy 
    accepts_nested_attributes_for :sup_photos


    def is_display?
        display_pattern = /(\bde\b)|(saches)|(sticks)|(unid)/i
        self.weight.parameterize.match?(display_pattern)
    end

    def match_pattern(unit)
        self.weight.downcase.gsub(/\W/, '').match(/\d{1,4}#{unit}s?/i)
    end

    def is_shaker?
        self.name.parameterize.match?(/(coqueteleira)|(shaker)|(squeeze)|(copo)|(galao)/)
    end

    def is_caps?
        self.weight.parameterize.match?(/(tabs?)|(comp?)|(softgels?)|(caps)/)
    end

    def is_clothe?
        self.weight.parameterize.match?(/\A(XL|XXG|XXL|GG|G|P|M|EG)\z/i)
    end

    def is_gel?
        self.name.parameterize.match?(/(gel|carb|stick|gum)/i)
    end

    def is_pack?
        self.name.parameterize.match?(/pack/i)
    end

    def is_bar?
        self.name.parameterize.match?(/bar/i)
    end
     
    def weight_list
        WEIGHT_LIST[self.weight.to_sym]
    end

    def weight_pattern
        return "wl" if WEIGHT_LIST[self.weight.to_sym]
        return "kg" if self.match_pattern('kg')
        return "lb" if self.match_pattern('lb')
        return "g" if self.match_pattern('g')
        return "shaker" if self.is_shaker?
        return "ml" if self.match_pattern('ml')
        return "caps" if self.is_caps?
        return "pack" if self.is_pack?
        return "gel" if self.is_gel?
        return "bar" if self.is_bar?
        return "clothe" if self.is_clothe?
    end

    include PgSearch::Model
    pg_search_scope :name_search,
    against: :name,
    using: {
        tsearch: { prefix: true }
    }

end

