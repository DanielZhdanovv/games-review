module YAMLPsychAliasFix
  def load_file(filename, **kwargs)
    super(filename, **kwargs, aliases: true)
  end
end

Psych.singleton_class.prepend(YAMLPsychAliasFix)