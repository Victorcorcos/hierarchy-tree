require 'active_record'
require 'active_support/core_ext/object/inclusion.rb'

################ Debug ################
# rm hierarchy-tree-0.1.2.gem
# gem build hierarchy_tree
# gem install hierarchy-tree-0.1.2.gem
# ruby -Itest test/test_hierarchy_tree.rb

class Hierarchy
  # Return the full hierarchy starting from the provided class
  def self.associations(klass)
    build_hierarchy(klass)
  end

  # Return the full hierarchy starting from the provided class
  def self.classes(klass)
    build_hierarchy(klass)
  end

  # Return an array o
  def self.classes_list(klass)
    @classes_list = []
    build_descendants(klass)
    @classes_list
  end

  def self.loop?(klass)
    @cache = {}
    false if dfs_hierarchy(class: klass, classes?: false)
  rescue SystemStackError
    true
  end

  private_class_method

  def self.build_hierarchy(klass)
    @cache = {}
    dfs_hierarchy(class: klass)
  rescue SystemStackError
    Rails.logger.ap "Infinite loop detected and handled for #{opts[:class]} hierarchy", :warn
    []
  end

  def self.dfs_hierarchy(opts, klass_name = nil, ancestral_nodes = [])
    return @cache[klass_name] if klass_name.in? @cache.keys
    return klass_name if opts[:class].in? ancestral_nodes # Early abort to not enter in a cycle
    if leaf?(opts[:class])
      @cache[klass_name] = klass_name
      return klass_name if klass_name.present? # Leaf
      [] # Leaf and Root
    else
      ancestral_nodes.push(opts[:class])
      children_hierarchies = children_classes(opts).map do |c_class, c_name|
        dfs_hierarchy({ class: c_class, classes?: opts[:classes?] }, c_name, ancestral_nodes.dup)
      end
      @cache[klass_name] = { klass_name => children_hierarchies }
      return @cache[klass_name] if klass_name.present? # Middle
      children_hierarchies # Root
    end
  end

  def self.leaf?(klass)
    return true if walkables(klass).empty?
    false
  end

  def self.children_classes(opts)
    walkables(opts[:class]).map do |reflection|
      child_class = get_class(reflection)
      if opts[:classes?]
        [child_class, child_class.to_s]
      else
        [child_class, reflection.name]
      end
    end.uniq
  end

  def self.walkables(klass)
    # get all models associated with :has_many or :has_one that are walkable.
    klass.reflections.values.select do |r|
      r.macro.in? %i[has_one has_many] and not r.options.key?(:through)
    end
  end

  def self.get_class(reflection)
    child = reflection.name.to_s.singularize.classify
    child = reflection.options[:class_name].to_s if reflection.options.key?(:class_name)
    child.constantize
  end

  def self.build_descendants(klass)
    dfs_descendants(class: klass, classes?: true)
  rescue SystemStackError
    Rails.logger.ap "Infinite loop detected and handled for #{opts[:class]} classes_list", :warn
    []
  end

  def self.dfs_descendants(opts, klass_name = nil)
    return if klass_name.in? @classes_list
    @classes_list.push(klass_name) if klass_name.present?
    children_classes(opts).each do |child_klass, child_name|
      child_opts = { class: child_klass, classes?: opts[:classes?] }
      dfs_descendants(child_opts, child_name)
    end
    true
  end
end
