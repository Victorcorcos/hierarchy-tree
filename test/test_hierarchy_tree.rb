require 'minitest/autorun'
require 'hierarchy_tree'
require 'active_record'
require 'active_support/core_ext/object/inclusion.rb'

class TestHierarchyTree < Minitest::Test
  def simulate(klass)
    Object.send(:remove_const, klass) if defined? klass.contantize
    Object.const_set(klass, Class.new(ActiveRecord::Base))
  end

  # 1) when a Person have Words through Books
  def test_associations_1
    simulate('Person')
    simulate('Book')
    simulate('Word')
    Person.class_eval { has_many :words, through: :book, autosave: false }
    Book.class_eval { has_many :words }

    assert_equal(Hierarchy.associations(Person), [])
  end

  def test_descendants_1
    simulate('Person')
    simulate('Book')
    simulate('Word')
    Person.class_eval { has_many :words, through: :book, autosave: false }
    Book.class_eval { has_many :words }

    assert_equal(Hierarchy.descendants(Person), [])
  end

  def test_loop_1
    simulate('Person')
    simulate('Book')
    simulate('Word')
    Person.class_eval { has_many :words, through: :book, autosave: false }
    Book.class_eval { has_many :words }

    assert_equal(Hierarchy.loop?(Book), false)
  end

  # 2) when the Book has one child
  def test_associations_2
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_one :page }

    assert_equal(Hierarchy.associations(Book), [:page])
  end

  def test_descendants_2
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_one :page }

    assert_equal(Hierarchy.descendants(Book), %w[Page])
  end

  def test_loop_2
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_one :page }

    assert_equal(Hierarchy.loop?(Book), false)
  end

  # 3) when the Book has children
  def test_associations_3
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_many :pages }

    assert_equal(Hierarchy.associations(Book), [:pages])
  end

  def test_descendants_3
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_many :pages }

    assert_equal(Hierarchy.descendants(Book), %w[Page])
  end

  def test_loop_3
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_many :pages }

    assert_equal(Hierarchy.loop?(Book), false)
  end

  # 4) when the Book has a multiple level hierarchy
  def test_associations_4
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')
    Book.class_eval { has_many :pages }
    Page.class_eval { has_many :lines }
    Line.class_eval { has_many :words }
    Word.class_eval { has_many :letters }

    assert_equal(Hierarchy.associations(Book), [{ pages: [{ lines: [{ words: [:letters] }] }] }])
  end

  def test_descendants_4
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')
    Book.class_eval { has_many :pages }
    Page.class_eval { has_many :lines }
    Line.class_eval { has_many :words }
    Word.class_eval { has_many :letters }

    assert_equal(Hierarchy.descendants(Book), %w[Page Line Word Letter])
  end

  def test_loop_4
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')
    Book.class_eval { has_many :pages }
    Page.class_eval { has_many :lines }
    Line.class_eval { has_many :words }
    Word.class_eval { has_many :letters }

    assert_equal(Hierarchy.loop?(Book), false)
  end

  # 5) when the Book has a complex multiple level hierarchy
  def test_associations_5
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')

    Book.class_eval do
      has_many :pages
      has_many :lines
      has_many :words
      has_many :letters
    end

    Page.class_eval do
      has_many :lines
      has_many :words
      has_many :letters
    end

    Line.class_eval do
      has_many :words
      has_many :letters
    end

    Word.class_eval do
      has_many :letters
    end

    letters = :letters
    words = { words: [letters] }
    lines = { lines: [words, letters] }
    pages = { pages: [lines, words, letters] }
    associations = [pages, lines, words, letters]

    assert_equal(Hierarchy.associations(Book), associations)
  end

  def test_descendants_5
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')

    Book.class_eval do
      has_many :pages
      has_many :lines
      has_many :words
      has_many :letters
    end

    Page.class_eval do
      has_many :lines
      has_many :words
      has_many :letters
    end

    Line.class_eval do
      has_many :words
      has_many :letters
    end

    Word.class_eval do
      has_many :letters
    end

    assert_equal(Hierarchy.descendants(Book), %w[Page Line Word Letter])
  end

  def test_loop_5
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')

    Book.class_eval do
      has_many :pages
      has_many :lines
      has_many :words
      has_many :letters
    end

    Page.class_eval do
      has_many :lines
      has_many :words
      has_many :letters
    end

    Line.class_eval do
      has_many :words
      has_many :letters
    end

    Word.class_eval do
      has_many :letters
    end

    assert_equal(Hierarchy.loop?(Book), false)
  end

  # 6) when the God has Person that has Person (hierarchy with self-loop)
  def test_associations_6_god
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.associations(God), [{ people: [:people] }])
  end

  def test_descendants_6_god
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.descendants(God), %w[Person])
  end

  def test_loop_6_god
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.loop?(God), false)
  end

  def test_associations_6_person
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.associations(Person), [:people])
  end

  def test_descendants_6_person
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.descendants(Person), %w[Person])
  end

  def test_loop_6_person
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.loop?(Person), false)
  end

  # 7) when the Wife has Husband that has Wife (hierarchy with cycle)
  def test_associations_7
    simulate('Wife')
    simulate('Husband')
    Wife.class_eval { has_one :husband }
    Husband.class_eval { has_one :wife }

    assert_equal(Hierarchy.associations(Wife), [{ husband: [:wife] }])
    assert_equal(Hierarchy.associations(Husband), [{ wife: [:husband] }])
  end

  def test_descendants_7
    simulate('Wife')
    simulate('Husband')
    Wife.class_eval { has_one :husband }
    Husband.class_eval { has_one :wife }

    assert_equal(Hierarchy.descendants(Wife), %w[Husband Wife])
    assert_equal(Hierarchy.descendants(Husband), %w[Wife Husband])
  end

  def test_loop_7
    simulate('Wife')
    simulate('Husband')
    Wife.class_eval { has_one :husband }
    Husband.class_eval { has_one :wife }

    assert_equal(Hierarchy.loop?(Wife), false)
    assert_equal(Hierarchy.loop?(Husband), false)
  end
end
