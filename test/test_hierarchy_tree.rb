require 'minitest/autorun'
require 'hierarchy_tree'
require 'active_record'
require 'active_support/core_ext/object/inclusion.rb'
# require 'pry-byebug' # For debugging purposes

class TestHierarchyTree < Minitest::Test
  def simulate(klass)
    Object.send(:remove_const, klass) if Object.const_defined?(klass)
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

  def test_classes_1
    simulate('Person')
    simulate('Book')
    simulate('Word')
    Person.class_eval { has_many :words, through: :book, autosave: false }
    Book.class_eval { has_many :words }

    assert_equal(Hierarchy.classes(Person), [])
  end

  def test_classes_list_1
    simulate('Person')
    simulate('Book')
    simulate('Word')
    Person.class_eval { has_many :words, through: :book, autosave: false }
    Book.class_eval { has_many :words }

    assert_equal(Hierarchy.classes_list(Person), [])
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

  def test_classes_2
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_one :page }

    assert_equal(Hierarchy.classes(Book), ['Page'])
  end

  def test_classes_list_2
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_one :page }

    assert_equal(Hierarchy.classes_list(Book), %w[Page])
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

  def test_classes_3
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_many :pages }

    assert_equal(Hierarchy.classes(Book), ['Page'])
  end

  def test_classes_list_3
    simulate('Book')
    simulate('Page')
    Book.class_eval { has_many :pages }

    assert_equal(Hierarchy.classes_list(Book), %w[Page])
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

  def test_classes_4
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')
    Book.class_eval { has_many :pages }
    Page.class_eval { has_many :lines }
    Line.class_eval { has_many :words }
    Word.class_eval { has_many :letters }

    assert_equal(Hierarchy.classes(Book), [{'Page' => [{'Line' => [{'Word' => ['Letter']}]}]}])
  end

  def test_classes_list_4
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')
    Book.class_eval { has_many :pages }
    Page.class_eval { has_many :lines }
    Line.class_eval { has_many :words }
    Word.class_eval { has_many :letters }

    assert_equal(Hierarchy.classes_list(Book), %w[Page Line Word Letter])
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

  def test_classes_5
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

    letter = 'Letter'
    words = { 'Word' => [letter] }
    lines = { 'Line' => [words, letter] }
    pages = { 'Page' => [lines, words, letter] }
    classes = [pages, lines, words, letter]

    assert_equal(Hierarchy.classes(Book), classes)
  end

  def test_classes_list_5
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

    assert_equal(Hierarchy.classes_list(Book), %w[Page Line Word Letter])
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

  def test_classes_6_god
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.classes(God), [{'Person' => ['Person']}])
  end

  def test_classes_list_6_god
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.classes_list(God), %w[Person])
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

  def test_classes_6_person
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.classes(Person), ['Person'])
  end

  def test_classes_list_6_person
    simulate('God')
    simulate('Person')
    God.class_eval { has_many :people }
    Person.class_eval { has_many :people }

    assert_equal(Hierarchy.classes_list(Person), %w[Person])
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

  def test_classes_7
    simulate('Wife')
    simulate('Husband')
    Wife.class_eval { has_one :husband }
    Husband.class_eval { has_one :wife }

    assert_equal(Hierarchy.classes(Wife), [{'Husband' => ['Wife']}])
    assert_equal(Hierarchy.classes(Husband), [{'Wife' => ['Husband']}])
  end

  def test_classes_list_7
    simulate('Wife')
    simulate('Husband')
    Wife.class_eval { has_one :husband }
    Husband.class_eval { has_one :wife }

    assert_equal(Hierarchy.classes_list(Wife), %w[Husband Wife])
    assert_equal(Hierarchy.classes_list(Husband), %w[Wife Husband])
  end

  def test_loop_7
    simulate('Wife')
    simulate('Husband')
    Wife.class_eval { has_one :husband }
    Husband.class_eval { has_one :wife }

    assert_equal(Hierarchy.loop?(Wife), false)
    assert_equal(Hierarchy.loop?(Husband), false)
  end

  def setup_ancestors
    simulate('Child')
    simulate('Parent1')
    simulate('Parent2')
    simulate('Parent3')
    simulate('GrandParent4')
    simulate('GrandParent5')
    simulate('GrandParent6')
    simulate('God')
    simulate('Edimar')

    # Child ➙ Parent1 ➙ GrandParent4 ➙ God ─↘
    #       ↳ Parent2 ➙ GrandParent5 ───────➙ Edimar
    #       ↳ Parent3 ➙ GrandParent6 ↺ Child
    #               ∟───────────────────────➚
    Child.class_eval { belongs_to :parent1 }
    Child.class_eval { belongs_to :parent2 }
    Child.class_eval { belongs_to :parent3 }
    Parent1.class_eval { belongs_to :grand_parent4 }
    Parent2.class_eval { belongs_to :grand_parent5 }
    Parent3.class_eval { belongs_to :grand_parent6; belongs_to :edimar }
    GrandParent4.class_eval { belongs_to :god }
    GrandParent5.class_eval { belongs_to :edimar }
    GrandParent6.class_eval { belongs_to :child }
    God.class_eval { belongs_to :edimar }
  end

  def test_all_ancestors
    setup_ancestors

    assert_equal(Hierarchy.ancestors(from: Child, to: Parent1), [:parent1, {:parent3=>{:grand_parent6=>{:child=>:parent1}}}])
    assert_equal(Hierarchy.ancestors(from: Child, to: Parent2), [:parent2, {:parent3=>{:grand_parent6=>{:child=>:parent2}}}])
    assert_equal(Hierarchy.ancestors(from: Child, to: Parent3), [:parent3, {:parent3=>{:grand_parent6=>{:child=>:parent3}}}])
    assert_equal(Hierarchy.ancestors(from: Child, to: GrandParent4), [{:parent1=>:grand_parent4}, {:parent3=>{:grand_parent6=>{:child=>{:parent1=>:grand_parent4}}}}])
    assert_equal(Hierarchy.ancestors(from: Child, to: GrandParent5), [{:parent2=>:grand_parent5}, {:parent3=>{:grand_parent6=>{:child=>{:parent2=>:grand_parent5}}}}])
    assert_equal(Hierarchy.ancestors(from: Child, to: GrandParent6), [{:parent3=>:grand_parent6}])
    assert_equal(Hierarchy.ancestors(from: Child, to: God), [{:parent1=>{:grand_parent4=>:god}}, {:parent3=>{:grand_parent6=>{:child=>{:parent1=>{:grand_parent4=>:god}}}}}])

    # Multiple Paths
    paths = [
      {:parent3=>:edimar},
      {:parent2=>{:grand_parent5=>:edimar}},
      {:parent1=>{:grand_parent4=>{:god=>:edimar}}},
      {:parent3=>{:grand_parent6=>{:child=>{:parent2=>{:grand_parent5=>:edimar}}}}},
      {:parent3=>{:grand_parent6=>{:child=>{:parent1=>{:grand_parent4=>{:god=>:edimar}}}}}}
    ]
    assert_equal(Hierarchy.ancestors(from: Child, to: Edimar), paths)

    assert_equal(Hierarchy.ancestors(from: Edimar, to: Child), [])
    assert_equal(Hierarchy.ancestors(from: Child, to: Child), [])
  end

  def test_ancestors_dfs
    setup_ancestors

    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: Parent1), :parent1)
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: Parent2), :parent2)
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: Parent3), :parent3)
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: GrandParent4), { parent1: :grand_parent4 })
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: GrandParent5), { parent2: :grand_parent5 })
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: GrandParent6), { parent3: :grand_parent6 })
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: God), { parent1: { grand_parent4: :god } })

    # Deepest Path
    assert_equal(Hierarchy.ancestors_dfs(from: Child, to: Edimar), { parent1: { grand_parent4: { god: :edimar } } })

    assert_nil(Hierarchy.ancestors_dfs(from: Edimar, to: Child))
    assert_nil(Hierarchy.ancestors_dfs(from: Child, to: Child))
  end

  def test_ancestors_bfs
    setup_ancestors

    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: Parent1), :parent1)
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: Parent2), :parent2)
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: Parent3), :parent3)
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: GrandParent4), { parent1: :grand_parent4 })
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: GrandParent5), { parent2: :grand_parent5 })
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: GrandParent6), { parent3: :grand_parent6 })
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: God), { parent1: { grand_parent4: :god } })

    # Shortest Path
    assert_equal(Hierarchy.ancestors_bfs(from: Child, to: Edimar), { parent3: :edimar })

    assert_nil(Hierarchy.ancestors_bfs(from: Edimar, to: Child))
    assert_nil(Hierarchy.ancestors_bfs(from: Child, to: Child))
  end

  def test_readme_example
    simulate('Book')
    simulate('Page')
    simulate('Line')
    simulate('Word')
    simulate('Letter')

    Book.class_eval do
      has_many :pages
      has_many :words
    end

    Page.class_eval do
      belongs_to :book
      has_many :lines
      has_many :words
    end

    Line.class_eval do
      belongs_to :page
      has_many :words
    end

    Word.class_eval do
      belongs_to :line
      belongs_to :page
      belongs_to :book
      has_many :letters
    end

    Letter.class_eval do
      belongs_to :word
    end

    associations = [{:pages=>[{:lines=>[{:words=>[:letters]}]}, {:words=>[:letters]}]}, {:words=>[:letters]}]
    assert_equal(Hierarchy.associations(Book), associations)

    classes = [{"Page"=>[{"Line"=>[{"Word"=>["Letter"]}]}, {"Word"=>["Letter"]}]}, {"Word"=>["Letter"]}]
    assert_equal(Hierarchy.classes(Book), classes)

    classes_list = ["Page", "Line", "Word", "Letter"]
    assert_equal(Hierarchy.classes_list(Book), classes_list)

    ancestors = [{:word=>:book}, {:word=>{:page=>:book}}, {:word=>{:line=>{:page=>:book}}}]
    assert_equal(Hierarchy.ancestors(from: Letter, to: Book), ancestors)

    ancestors_dfs = {:word=>{:line=>{:page=>:book}}}
    assert_equal(Hierarchy.ancestors_dfs(from: Letter, to: Book), ancestors_dfs)

    ancestors_bfs = {:word=>:book}
    assert_equal(Hierarchy.ancestors_bfs(from: Letter, to: Book), ancestors_bfs)
  end
end
