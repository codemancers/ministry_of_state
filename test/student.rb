class Student < User
  add_state :foo
  
  add_event(:activate) do
    transitions(:from => [:foo,:pending],:to => :active)
  end

  add_event(:make_foo) do
    transitions(:from => [:pending,:active], :to => :foo)
  end
end
