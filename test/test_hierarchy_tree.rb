require 'minitest/autorun'
require 'hierarchy_tree'
require 'active_record'
require 'active_support/core_ext/object/inclusion.rb'

class TestHierarchyTree < Minitest::Test
  # when the Book belongs to a Person
  class Book < ActiveRecord::Base
    belongs_to :person
  end

  class Person < ActiveRecord::Base
  end

  def test_should_not_return_the_person
    assert_equal(Hierarchy.associations(Book), [])
  end

  def test_should_not_return_the_descendants
    assert_equal(Hierarchy.descendants(Book), [])
  end

  def test_should_not_be_a_loop
    assert_equal(Hierarchy.loop?(Book), false)
  end

  # when a Person have Words through Books
  class Word < ActiveRecord::Base
  end

  class Person < ActiveRecord::Base
    has_many :words, through: :book, autosave: false
  end

  class Book < ActiveRecord::Base
    has_many :words
  end

  def test_should_not_return_the_through_association
    assert_equal(Hierarchy.associations(Person), [])
  end

  def test_should_not_return_the_descendants_2
    assert_equal(Hierarchy.descendants(Person), [])
  end

  def test_should_not_be_a_loop_2
    assert_equal(Hierarchy.loop?(Person), false)
  end
end
