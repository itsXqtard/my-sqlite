class Statement
  attr_accessor :type, :select, :insert, :update, :delete

  def initialize(sel = nil, ins = nil, upd = nil, del = nil)
    @select = sel
    @insert = ins
    @update = upd
    @delete = del
    @type = :none
  end

  def set_type(type)
    @type = type
  end

  def get_type
    return @type
  end

  def set_statement_instance(stmt)
    if @type == :select
      self.set_select(stmt)
    elsif @type == :update 
      self.set_update(stmt)
    elsif @type == :insert
      self.set_insert(stmt)
    elsif @type == :delete
      self.set_delete(stmt)
    else
      raise 'Wrong type for call to set_statement_instance()'
    end
  end

  def set_select(sel)
    @select = sel
    self
  end

  def set_insert(ins)
    @insert = ins
    self
  end

  def set_update(upd)
    @update = upd
    self
  end

  def set_delete(del)
    @delete = del
    self
  end

  def get_select
    return @select
  end

  def get_insert
    return @insert
  end

  def get_update
    return @update
  end

  def get_delete
    return @delete
  end

end