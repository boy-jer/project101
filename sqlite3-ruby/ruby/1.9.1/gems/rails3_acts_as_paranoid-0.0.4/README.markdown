# ActsAsParanoid

A simple plugin which hides records instead of deleting them, being able to recover them.

## Credits

This plugin was inspired by [acts_as_paranoid](http://github.com/technoweenie/acts_as_paranoid) and [acts_as_active](http://github.com/fernandoluizao/acts_as_active).

While porting it to Rails 3, I decided to apply the ideas behind those plugins to an unified solution while removing a **lot** of the complexity found in them. I eventually ended up writing a new plugin from scratch.

## Usage

You can enable ActsAsParanoid like this:

    class Paranoiac < ActiveRecord::Base
      acts_as_paranoid
    end

### Options

You can also specify the name of the column to store it's *deletion* and the type of data it holds:

-   :column => 'deleted_at'
-   :type => 'time'

The values shown are the defaults. While *column* can be anything (as long as it exists in your database), *type* is restricted to "boolean" or "time".

### Filtering

If a record is deleted by ActsAsParanoid, it won't be retrieved when accessing the database. So, `Paranoiac.all` will **not** include the deleted_records. if you want to access them, you have 2 choices:

    Paranoiac.only_deleted # retrieves the deleted records
    Paranoiac.with_deleted # retrieves all records, deleted or not

### Real deletion

In order to really delete a record, just use:

    paranoiac.destroy!
    Paranoiac.delete_all!(conditions)

You can also definitively delete a record by calling `destroy` or `delete_all` on it twice. If a record was already deleted (hidden by ActsAsParanoid) and you delete it again, it will be removed from the database. Take this example:

    Paranoiac.first.destroy # does NOT delete the first record, just hides it
    Paranoiac.only_deleted.destroy # deletes the first record from the database

### Recovery

Recovery is easy. Just invoke `recover` on it, like this:

    Paranoiac.only_deleted.where("name = ?", "not dead yet").first.recover
    
All associations marked as `:dependent => :destroy` are also recursively recovered. If you would like to disable this behavior, you can call `recover` with the `recursive` option:

    Paranoiac.only_deleted.where("name = ?", "not dead yet").first.recover(:recursive => false)

If you would like to change the default behavior for a model, you can use the `recover_dependent_associations` option

    class Paranoiac < ActiveRecord::Base
        acts_as_paranoid :recover_dependent_associations => false
    end

By default when using timestamp fields to mark deletion, dependent records will be recovered if they were deleted within 5 seconds of the object upon which they depend.  This restores the objects to the state before the recursive deletion without restoring other objects that were deleted earlier.  This window can be changed with the `dependent_recovery_window` option

    class Paranoiac < ActiveRecord::Base
        acts_as_paranoid
        has_many :paranoids, :dependent => :destroy
    end

    class Paranoid < ActiveRecord::Base
        belongs_to :paranoic

        # Paranoid objects will be recovered alongside Paranoic objects 
        # if they were deleted within 1 minute of the Paranoic object
        acts_as_paranoid :dependent_recovery_window => 1.minute
    end

or in the recover statement

    Paranoiac.only_deleted.where("name = ?", "not dead yet").first.recover(:recovery_window => 30.seconds)

### Validation
ActiveRecord's built-in uniqueness validation does not account for records deleted by ActsAsParanoid. If you want to check for uniqueness among non-deleted records only, use the macro `validates_as_paranoid` in your model. Then, instead of using `validates_uniqueness_of`, use `validates_uniqueness_of_without_deleted`. This will keep deleted records from counting against the uniqueness check.

    class Paranoiac < ActiveRecord::Base
      acts_as_paranoid
      validates_as_paranoid
      validates_uniqueness_of_without_deleted :name
    end
  
    Paranoiac.create(:name => 'foo').destroy
    Paranoiac.new(:name => 'foo').valid? #=> true
    
## Caveats

Watch out for these caveats:

-   You cannot use default\_scope in your model. It is possible to work around this caveat, but it's not pretty. Have a look at [this article](http://joshuaclayton.github.com/code/default_scope/activerecord/is_paranoid/multiple-default-scopes.html) if you really need to have your own default scope.
-   You cannot use scopes named `with_deleted` and `only_deleted`

## Acknowledgements

* To [cheerfulstoic](https://github.com/cheerfulstoic) for adding recursive recovery
* To [Jonathan Vaught](https://github.com/gravelpup) for adding paranoid validations

Copyright © 2010 Gonçalo Silva, released under the MIT license
