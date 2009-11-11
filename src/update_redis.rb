require 'lib/redis'

module Charyb

  def Charyb.update_redis()
    r = Redis.new({:host=>'localhost', :db=>0});
    r.set('one','1');
  end

end
