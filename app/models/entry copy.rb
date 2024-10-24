class Entry < ApplicationRecord
  after_update :update_dependents, unless: :still

  def update_dependents
    entries = Entry.where(id: self.dependents)
    entries.each do |e|
      result = e.calculate
      unless e.calc_was == result
        e.update(calc: result)
      end
    end
  end

  def precedent_ids
    formula_body.scan(/\#\{\d+\}/).map{|e| e[/\d+/]}
  end

  def precedents
    Entry.where(id: precedent_ids)
  end

  def calculate
    na = false
    output = "#{formula_body}"
    precedents.each do |p|
      r = p.value || p.calc
      na = true unless r
      output = output.gsub(/\#\{(#{p.id})\}/, r.to_s)
    end
    if na
      return
    else
      begin
        eval(output)
      rescue SyntaxError, StandardError => e
        Rails.logger.error("Cannot calculate #{self.id} based on formula #{output}")
        nil
      end
    end
  end

end
