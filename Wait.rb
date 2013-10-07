class Wait
  def initialize()
    @time = rand(3.0..10.0)
    sleep(@time)
  end
end
