class CreateTestTables < ActiveRecord::Migration[5.2]
  def up
    unless table_exists?(:a_dummies)
      create_table :a_dummies do |t|
        t.string :attr1
      end
    end

    unless table_exists?(:b_dummies)
      create_table :b_dummies do |t|
        t.string :attr1
      end
    end

    unless table_exists?(:c_dummies)
      create_table :c_dummies do |t|
        t.string :attr1
      end
    end

    unless table_exists?(:model_with_associations)
      create_table :model_with_associations do |t|
        t.string :attr1
        t.references :a_dummies, index: true, foreign_key: true
        t.references :b_dummies, index: true, foreign_key: true
      end

      create_join_table :model_with_associations, :c_dummies
    end
  end
end

CreateTestTables.suppress_messages do
  CreateTestTables.migrate(:up)
end
