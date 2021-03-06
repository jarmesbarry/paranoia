module HandleParanoiaDestroyedInBelongsToAssociation
  def handle_dependency
    return unless load_target

    case options[:dependent]
    when :destroy
      target.destroy
      if defined? target.deleted?
        raise ActiveRecord::Rollback unless target.deleted?
      else
        raise ActiveRecord::Rollback unless target.destroyed?
      end
    else
      target.send(options[:dependent])
    end
  end
end

module HandleParanoiaDestroyedInHasOneAssociation
  def delete(method = options[:dependent])
    if load_target
      case method
      when :delete
        target.delete
      when :destroy
        target.destroyed_by_association = reflection
        target.destroy
        if defined? target.deleted?
          throw(:abort) unless target.deleted?
        else
          throw(:abort) unless target.destroyed?
        end
      when :nullify
        target.update_columns(reflection.foreign_key => nil) if target.persisted?
      end
    end
  end
end

ActiveRecord::Associations::BelongsToAssociation.prepend HandleParanoiaDestroyedInBelongsToAssociation
ActiveRecord::Associations::HasOneAssociation.prepend HandleParanoiaDestroyedInHasOneAssociation
