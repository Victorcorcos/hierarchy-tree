<p align="center">
  <img src="https://i.imgur.com/gQlXIBG.png" alt="Hierarchy Tree Logo" width="200" height="200"/>
</p>

<p align="center">
A repository dedicated to a ruby gem that shows the whole hierarchy and the associations related to a desired class.
</p>

## Why it is necessary?

Currently, **Rails** doesn't have an easy way to discover the relations among a bunch of ActiveRecord classes.

For example, if...
1. `Person` has_many books
2. `Book` has_many pages
3. `Page` has_many words
4. `Word` has_many letters

We need to search inside each one of these files to discover the relations among them. Therefore, we don't have a way to display an overview of all of these relations singlehandedly to help you understand the whole ecosystem of relationships of the model classes.

With the `hierarchy-tree` gem, it is possible to see this hierarchy ecosystem overview of the classes with ease! :smile:

## Instalation

Add `hierarchy-tree` to your Gemfile.

```rb
gem 'hierarchy-tree'
```

## Usage

1. Just require the `hierarchy_tree` library and use it! (You can test this on `rails console`)

```rb
require 'hierarchy_tree'

# Array of hashes of relations → Representing the hierarchy symbolized relations
Hierarchy.associations(YourClass)

# Array of hashes of classes → Representing the hierarchy of relations as stringified classes instead of symbolized relations
Hierarchy.classes(YourClass)

# Array of classes → Just a list of descendant classes, without representing the relations
Hierarchy.classes_list(YourClass)

# Output the classes from leaves to root by using topological sorting
Hierarchy.bottom_up_classes(YourClass)

# Array of relations → Representing all the possible paths starting from the ChildClass until it reaches AncestorClass
Hierarchy.ancestors(from: ChildClass, to: AncestorClass)

# Hash of relations → Representing the ancestors hierarchy starting from the ChildClass until it reaches AncestorClass searching by Depth First Search
Hierarchy.ancestors_dfs(from: ChildClass, to: AncestorClass)

# Hash of relations → Representing the ancestors hierarchy starting from the ChildClass until it reaches AncestorClass searching by Breadth First Search
Hierarchy.ancestors_bfs(from: ChildClass, to: AncestorClass)

# Same as above, but returning an array of classes
Hierarchy.ancestors_bfs(from: ChildClass, to: AncestorClass, classify: true)
```

## Example

* Imagine you have the following classes with their relations...

```rb
class Book < ActiveRecord::Base
  has_many :pages
  has_many :words
end

class Page < ActiveRecord::Base
  belongs_to :book
  has_many :lines
  has_many :words
end

class Line < ActiveRecord::Base
  belongs_to :page
  has_many :words
end

class Word < ActiveRecord::Base
  belongs_to :line
  belongs_to :page
  belongs_to :book
  has_many :letters
end

class Letter < ActiveRecord::Base
  belongs_to :word
end
```

* Then, you can run the following commands (Please, don't forget to `require 'hierarchy_tree'`)

```rb
Hierarchy.associations(Book)
# [{:pages=>[{:lines=>[{:words=>[:letters]}]}, {:words=>[:letters]}]}, {:words=>[:letters]}]

Hierarchy.classes(Book)
# [{:pages=>[{:lines=>[{:words=>[:letters]}]}, {:words=>[:letters]}]}, {:words=>[:letters]}]

Hierarchy.classes_list(Book)
# ["Page", "Line", "Word", "Letter"]

Hierarchy.bottom_up_classes(Book)
# ["Letter", "Word", "Line", "Page", "Book"]

Hierarchy.ancestors(from: Letter, to: Book)
# [{:word=>:book}, {:word=>{:page=>:book}}, {:word=>{:line=>{:page=>:book}}}]

Hierarchy.ancestors_dfs(from: Letter, to: Book)
# {:word=>{:line=>{:page=>:book}}}

Hierarchy.ancestors_bfs(from: Letter, to: Book)
# {:word=>:book}
```

* A nice way to display the associations is through the *YAML* format [without aliases](https://stackoverflow.com/questions/3981128/ruby-yaml-write-without-aliases/3990318)

```rb
puts YAML.load(Hierarchy.associations(Book).to_json).to_yaml
```

The result is...

```yml
--- # Book
- pages:
  - lines:
    - words:
      - letters
    - letters
  - words:
    - letters
  - letters
- lines:
  - words:
    - letters
  - letters
- words:
  - letters
- letters
```

## Polymorphic Relations 👨‍👩‍👧‍👦

In case there are polymorphic relations in your database and you want to discover the ancestors path(s) between these classes including the polymorphic relations, you need to explicitly setup the `belongs_to` association to each class the polymorphic relation is associated.

So, if you have a polymorphic relation like this one for example:

```rb
class Request
end

class Scope
end

class Progress
end

class Inspection < ActiveRecord::Base
  belongs_to :inspected, polymorphic: true, optional: true
  # inspected_type = "Request" or "Scope" or "Progress"
end
```

You need to explicitly add the `belongs_to` associations related with these models, following the instructions of [**this answer**](https://stackoverflow.com/a/16124295/7644846).

```rb
class Inspection < ActiveRecord::Base
  belongs_to :request, -> { where(inspections: { inspected_type: 'Request' }) },
             foreign_key: 'inspected_id', optional: true, inverse_of: :inspections
  belongs_to :scope, -> { where(inspections: { inspected_type: 'Scope' }) },
             foreign_key: 'inspected_id', optional: true, inverse_of: :inspections
  belongs_to :progress, -> { where(inspections: { inspected_type: 'Progress' }) },
             foreign_key: 'inspected_id', optional: true, inverse_of: :inspections
end
```

By this manner, the `hierarchy-tree` gem will consider the polymorphic relations inside the paths discovery. 🚀


## Contact

* [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/)

---

*This repository is maintained and developed by [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/). For inquiries, partnerships, or support, don't hesitate to get in touch.
