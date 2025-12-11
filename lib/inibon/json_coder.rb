class Inibon::JsonCoder
  def self.dump(obj)
    obj.to_json
  end

  def self.load(str)
    str.present? ? JSON.parse(str) : {}
  end
end
