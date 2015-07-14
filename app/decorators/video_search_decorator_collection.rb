class VideoSearchDecoratorCollection
  include Enumerable

  attr_reader :objects
  attr_reader :decorated_objects

  delegate :[], :count, :each, to: :objects, to: :decorated_objects

  def initialize(objects)
    @objects = objects
    @decorated_objects = @objects.map { |object| VideoSearchDecorator.decorate(object) }
  end
end

