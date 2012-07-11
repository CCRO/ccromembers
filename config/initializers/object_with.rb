class Object
	def with(instance, &block)
    instance.instance_eval(&block)
    instance
  end
end