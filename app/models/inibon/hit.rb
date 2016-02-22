class Inibon::Hit < ActiveRecord::Base

  self.table_name= 'inibon_hits'
  @@logger = ActiveSupport::Logger.new('log/inibon.log')

  belongs_to :translation

end
