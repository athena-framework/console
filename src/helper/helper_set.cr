class Athena::Console::Helper::HelperSet
  @helpers = Hash(ACON::Helper.class, ACON::Helper::Interface).new
  property command : ACON::Command? = nil

  def initialize(@helpers : Hash(ACON::Helper.class, ACON::Helper::Interface) = Hash(ACON::Helper.class, ACON::Helper::Interface).new); end

  def <<(helper : ACON::Helper::Interface) : Nil
    @helpers[helper.class] = helper

    helper.helper_set = self
  end

  def has?(helper_class : ACON::Helper.class) : Bool
    @helpers.has_key? helper_class
  end

  def get(helper_class : ACON::Helper.class) : ACON::Helper::Interface
    raise ACON::Exceptions::InvalidArgument.new "The helper '#{helper_class}' is not defined." unless self.has? helper_class

    @helpers[helper_class]
  end
end
