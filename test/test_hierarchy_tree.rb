require 'minitest/autorun'
require 'hierarchy_tree'
require 'active_record'
require 'active_support/core_ext/object/inclusion.rb'

class TestHierarchyTree < Minitest::Test
  Object.const_set('Book', Class.new(ActiveRecord::Base))
  Object.const_set('Page', Class.new(ActiveRecord::Base))
  Object.const_set('Line', Class.new(ActiveRecord::Base))
  Object.const_set('Word', Class.new(ActiveRecord::Base))
  Object.const_set('Letter', Class.new(ActiveRecord::Base))
  Book.class_eval { has_many :pages }
  Page.class_eval { has_many :lines }
  Line.class_eval { has_many :words }
  Word.class_eval { has_many :letters }

  def test_should_not_return_the_person
    assert_equal(Hierarchy.associations(Book), [{ pages: [{ lines: [{ words: [:letters] }] }] }])
  end

  def test_should_not_return_the_descendants
    assert_equal(Hierarchy.descendants(Book), %w[Page Line Word Letter])
  end

  def test_should_not_be_a_loop
    assert_equal(Hierarchy.loop?(Book), false)
  end
end
