class KFunc < BasicObject
  attr_accessor :code
  attr_accessor :arguments
  attr_accessor :value
  def to_ary
    [@code.flatten]
  end

  def to_s
    @code.join
  end
  
  def inspect
    @code.join
  end

  def do(&block)
    instance_eval &block
  end

  def initialize
    @code = []
  end

  def t(obj)
    case obj when ::Symbol then obj.to_s else obj.inspect end
  end
  def method_missing(sym, *args)
    @code << "#{sym}(#{args.map{|x| t x}.join(',')});\n"
  end

  def assign(sym, v)
    @code << "#{sym} = #{t v};\n"
  end

  def define(type, name)
    @code << "#{type} #{name};\n"
  end

  def scope(sig)
    @code << "#{sig}{"
    yield
    @code << "}"
  end
end

class KStruct 
  attr_accessor :funcs
  def initialize
    @funcs = {}
  end
  def method_missing(sym, *args, &block)  
    if sym[/=$/]
      r = sym.to_s.chomp("=").to_sym
       @funcs[r] = KFunc.new
       @funcs[r].code << @funcs[r].t(args[0])
       @funcs[r].value = args[0]
       @funcs[r]
    else
      @funcs[sym] ||= KFunc.new
      @funcs[sym].do(&block) if block
      @funcs[sym].arguments = args
      @funcs[sym]
    end
  end
end


#Structs
class KFunc
  def struct(name, fields)
    fields.each{|k, v|
      assign "#{name}.#{k}", v
    }
  end
end

Program = KStruct.new