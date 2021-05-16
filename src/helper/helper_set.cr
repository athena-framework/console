class Athena::Console::Helper::HelperSet
  @helpers = Hash(ACON::Helper.class, ACON::Helper::Interface).new
  property command : ACON::Command? = nil

  def self.new(*helpers : ACON::Helper::Interface) : self
    helper_set = new
    helpers.each do |helper|
      helper_set << helper
    end
    helper_set
  end

  def initialize(@helpers : Hash(ACON::Helper.class, ACON::Helper::Interface) = Hash(ACON::Helper.class, ACON::Helper::Interface).new); end

  def <<(helper : ACON::Helper::Interface) : Nil
    @helpers[helper.class] = helper

    helper.helper_set = self
  end

  def has?(helper_class : ACON::Helper.class) : Bool
    @helpers.has_key? helper_class
  end

  def []?(helper_class : T.class) : T? forall T
    {% T.raise "Helper class type '#{T}' is not an 'ACON::Helper::Interface'." unless T <= ACON::Helper::Interface %}

    @helpers[helper_class]?.as? T
  end

  def [](helper_class : ACON::Helper.class) : ACON::Helper::Interface
    raise ACON::Exceptions::InvalidArgument.new "The helper '#{helper_class}' is not defined." unless self.has? helper_class

    @helpers[helper_class]
  end
end
