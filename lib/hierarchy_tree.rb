require 'active_record'
require 'active_support/core_ext/object/inclusion.rb'

################ Debug ################
# gem cleanup hierarchy-tree
# rm hierarchy-tree-X.Y.Z.gem
# gem build hierarchy_tree
# gem install hierarchy-tree-X.Y.Z.gem
# ruby -Itest test/test_hierarchy_tree.rb

class Hierarchy
  # Return the full hierarchy as associations starting from the provided class
  def self.associations(klass)
    build_hierarchy(class: klass)
  end

  # Return the full hierarchy as classes starting from the provided class
  def self.classes(klass)
    build_hierarchy(class: klass, classes?: true)
  end

  # Return the array of children classes
  def self.classes_list(klass)
    @classes_list = []
    build_descendants(klass)
    @classes_list
  end

  # Return all the possible ancestors associations by navigating through :belongs_to
  # Starting from the "from" class towards the "to" class
  def self.ancestors(from:, to:)
    return [] if from == to

    queue = [{ class: from, path: [] }]
    visited = { from => [] }
    paths = []

    while queue.any?
      current = queue.shift
      current_class = current[:class]
      current_path = current[:path]

      current_class.reflect_on_all_associations(:belongs_to).each do |relation|
        next_class = relation.klass
        next_path = current_path + [relation.name]

        if next_class.to_s == to.to_s
          paths << hashify(next_path)
        end

        if !visited.key?(next_class)
          visited[next_class] = next_path
          queue.push({ class: next_class, path: next_path })
        end
      end
    end

    paths
  end

  # Return the ancestors associations by navigating through :belongs_to
  # Starting from the "from" class towards the "to" class
  # Using BFS - Breadth First Search, thus finding the Shortest Path
  def self.ancestors_bfs(from:, to:)
    return if from == to

    queue = [{ class: from, path: [] }]
    visited = [from]

    while queue.any?
      current = queue.shift
      current_class = current[:class]
      current_path = current[:path]

      current_class.reflect_on_all_associations(:belongs_to).each do |relation|
        next_class = relation.klass
        next_path = current_path + [relation.name]

        return hashify(next_path) if next_class.to_s == to.to_s

        if visited.exclude?(next_class)
          visited << next_class
          queue.push({ class: next_class, path: next_path })
        end
      end
    end
  end

  # Return the ancestors associations by navigating through :belongs_to
  # Starting from the "from" class towards the "to" class
  # Using DFS - Depth First Search, thus finding the Deepest Path (more likely)
  def self.ancestors_dfs(from:, to:, descendants: [])
    return if from.to_s == to.to_s and descendants == [] # Base case
    return 'loop' if from.in? descendants # Avoids cycle

    descendants.push(from)

    from.reflect_on_all_associations(:belongs_to).map do |relation|
      return relation.name if relation.klass.to_s == to.to_s # Path is found
      path = ancestors_dfs(from: relation.klass, to: to, descendants: descendants)
      return { relation.name => path } if valid_path?(path, to.model_name.param_key.to_sym)
    end.compact.first
  end

  def self.loop?(klass)
    @cache = {}
    false if dfs_hierarchy(class: klass, classes?: false)
  rescue SystemStackError
    true
  end

  private_class_method

  def self.build_hierarchy(opts)
    @cache = {}
    dfs_hierarchy(opts)
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

  def self.hashify(array)
    if array.length == 1
      array.first
    else
      { array.first => hashify(array.drop(1)) }
    end
  end

  def self.valid_path?(path, target)
    return true if path == target

    case path
    when Array
      path.any? { |sub_path| valid_path?(sub_path, target) }
    when Hash
      path.values.any? { |value| valid_path?(value, target) }
    else
      false
    end
  end
end
