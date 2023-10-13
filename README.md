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

Hierarchy.associations(YourClass) # Array of hashes of relations → Representing the hierarchy symbolized relations
Hierarchy.classes_list(YourClass) # Array of classes → Just a list of descendant classes, without representing the relations
Hierarchy.classes(YourClass)      # Array of hashes of classes → Representing the hierarchy of relations as stringified classes instead of symbolized relations
```

## Example

* Imagine you have the following classes with their relations...

```rb
class Book < ActiveRecord::Base
  has_many :pages
  has_many :lines
  has_many :words
  has_many :letters
end

class Page < ActiveRecord::Base
  belongs_to :book
  has_many :lines
  has_many :words
  has_many :letters
end

class Line < ActiveRecord::Base
  belongs_to :page
  has_many :words
  has_many :letters
end

class Word < ActiveRecord::Base
  belongs_to :line
  has_many :letters
end

class Letter < ActiveRecord::Base
  belongs_to :word
end
```

* Then, you can run the following commands (Please, don't forget to `require 'hierarchy_tree'`)

```rb
Hierarchy.descendants(Book)
# ["Page", "Line", "Word", "Letter"]

Hierarchy.associations(Book)
# [{:pages=>[{:lines=>[{:words=>[:letters]}, :letters]}, {:words=>[:letters]}, :letters]}, {:lines=>[{:words=>[:letters]}, :letters]}, {:words=>[:letters]}, :letters]
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

## Contact

* [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/)

---

*This repository is maintained and developed by [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/). For inquiries, partnerships, or support, don't hesitate to get in touch.
