# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)

# This file defines the Parametric module that lets you define parametric
# objects that you can edit.

require 'sketchup.rb'

#=============================================================================
module CommunityExtensions::Shapes

  # Abstract class which should be inherited by implementing class.
  class Parametric

    # TODO(thomthom): The arguments for this class needs documenting. It looks
    # like they are overloaded. But how many different mutations are there?
    # @param [Hash] data
    # @param [Geom::Transformation] transformation
    #
    # Initialize a newly created instance of the object
    def initialize(*args)

      data = args[0]

      data = self.prompt("Create") if not data
      return if not data

      if data.kind_of?(Sketchup::Entity)
        # Entity already exist - this instance is for editing it.
        @entity = data
      else
        # Entity doesn't exist, this instance creates it.

        # TODO(thomthom): Why does it silently fail?
        return if !validate_parameters(data)

        model = Sketchup.active_model
        model.start_operation(short_class_name(), true)
        self.create_entity(model)

        container = self.get_container
        if container.nil?
          model.abort_operation
          # TODO(thomthom): Why does it silently fail?
          return
        end

        self.create_entities(data, container)
        self.set_attributes(data)

        transformation = args[1]
        if transformation.kind_of?(Geom::Transformation)
          # TODO(thomthom): No error if the type is incorrect?
          @entity.transformation = transformation
        end

        if @entity.kind_of?(Sketchup::ComponentDefinition)
          model.place_component(@entity, false)
        end

        model.commit_operation
      end
    end

    # Generate a human friendly name of the class, omitting the ancestors.
    def short_class_name
      self.class.name.split("::").last
    end

    # Create a new parametric Entity.  The default implementation creates
    # a ComponentDefinition.  Derived classes can over-ride this method to create a
    # Group or ComponentInstance instead.
    def create_entity(model)
      @entity = model.definitions.add(short_class_name())
    end

    # Get the container in which to add new Entities.
    # This method should not need to be over-ridden by derived classes
    def get_container
      case @entity
      when Sketchup::Group
        container = @entity.entities
      when Sketchup::ComponentInstance
        container = @entity.definition.entities
      when Sketchup::ComponentDefinition
        container = @entity.entities
      else
        container = nil
      end
      container
    end

    # Get the attribute dictionary
    def Parametric.attribute_holder(entity)
      case entity
      when Sketchup::Group
        return entity
      when Sketchup::ComponentInstance
        return entity.definition
      when Sketchup::ComponentDefinition
        return entity
      end
      nil
    end

    def attribute_dictionary(create_if_needed = false)
      entity = Parametric.attribute_holder(@entity)
      # TODO(thomthom): The attribute name is not very descriptive and risk
      # clashes. Alas, this cannot be changed now as it would break old models.
      (entity) ? entity.attribute_dictionary("skpp", create_if_needed) : nil
    end

    # Get the parameter data from an entity
    def parameters
      return nil if @entity.nil?

      attributes = self.attribute_dictionary
      return nil if attributes.nil?

      data = {}
      attributes.each do |key, value|
        if key != "class"
          data[key] = value
        end
      end
      data
    end

    # Show a dialog and get the values from the user
    # TODO: The data variable is a Hash of values to get from the user.
    # Because it is a Hash, the order is not specified.  I really need some way
    # for the derived classes to control the order that the parameters are
    # displayed to the user.
    def prompt(operation)
      # get the parameters
      if( @entity )
        data = self.parameters
      else
        data = self.default_parameters
      end
      if data.nil?
        puts "No parameters attached to the entity"
        return nil
      end
      title = "#{operation} #{short_class_name()}"
      keys = []
      prompts = []
      values = []
      data.each do |key, value|
        if key != "class"
          keys << key
          prompts << self.translate_key(key)
          values << value
        end
      end
      results = inputbox( prompts, values, title )
      return nil if not results

      # Store the results back into data
      # results will be an Array with one value for each prompt
      results.each_index { |i| data[keys[i]] = results[i] }

      data
    end

    # Attach attributes to the object
    def set_attributes(data)

      # Get the AttributeDictionary - create it if needed
      attribs = attribute_dictionary(true)

      # Set the class name
      attribs["class"] = self.class.name

      # now set the data values
      data.each { |key, value| attribs[key] = value }

      attribs
    end

    def entity
      @entity
    end

    # Edit the parametric object.  This will prompt for the new values
    # and then regenerate the geometry.
    def edit
      if @entity.nil?
        puts "There is no Entity to Edit"
        return false
      end

      data = self.prompt("Edit")
      return false if not data

      # Make sure that valid values were entered.
      if !self.validate_parameters(data)
        return false
      end

      # Now clear the old definition and regenerate the entities.
      container = self.get_container
      model = @entity.model
      model.start_operation("Edit #{short_class_name()}")

      container.clear!
      self.create_entities(data, container)
      self.set_attributes(data)

      model.commit_operation

      @entity
    end

    #-----------------------------------------------------------------------------
    # Class methods for editing parametric objects

    # Determine the class of a parametric entity
    def Parametric.get_class(ent)
      attrib_holder = Parametric.attribute_holder(ent)
      return nil if not attrib_holder
      attrib_holder.get_attribute("skpp", "class")
    end

    # Determine if an Entity is a parametric object
    def Parametric.parametric?(ent)
      klass = Parametric.get_class(ent)
      return false if not klass

      # Make sure that we can actually create an instance of this class.
      # TODO(thomthom): This should be cleaned up. Shouldn't be need to use
      # eval. And it should probably raise an error.
      begin
        new_method = eval("#{klass}.method :new")
      rescue
        # If we couldn't find the new method, it probably means that
        # the code for this kind of parametric object wasn't loaded
        puts "Could not find implementation of #{klass}"
        return false
      end

      # return the class name
      klass
    end

    def Parametric.selection_parametric?
      selection = Sketchup.active_model.selection
      false if selection.count != 1
      Parametric.parametric?(selection.first)
    end

    def Parametric.edit(ent)
      if !Parametric.parametric?(ent)
        UI.beep
        # TODO(thomthom): Error in the console? Either this should display a
        # warning to the user, or the inheriting class should do so. All these
        # `puts` calls should be avoided - they are only useful to a developer.
        puts "#{ent} is not a parametric Entity"
        return false
      end

      # Get the class of the parametric object
      klass = Parametric.get_class(ent)

      # Create a new parametric object of that class.
      # TODO: Avoid eval - convert string to constants and use that to create
      # the instance.
      new_method = eval "#{klass}.method :new"
      obj = new_method.call ent
      if not obj
        puts "Could not create the parametric object for #{klass}"
        return false
      end

      # Now edit the object
      obj.edit
    end

    # Edit the current selection
    def Parametric.edit_selection
      if !Parametric.selection_parametric?
        UI.beep
        puts "The selected Entity is not parametric"
        return false
      end

      Parametric.edit(Sketchup.active_model.selection.first)
    end

    #-----------------------------------------------------------------------------
    # The following methods should be implemented by derived classes.  Some of them
    # are required, and some are only optional

    # create_entities is called to create the entities for the parametric object.
    # the parameters needed to create the object are passed in as a Hash.
    # This must be implemented by any class that includes Parametric
    def create_entities(data, container)
      raise NotImplementedError, "Must be implemented by derived class"
    end

    # Get the default parameters for the object.
    def default_parameters
      raise NotImplementedError, "Must be implemented by derived class"
    end

    # Check that valid parameters were entered
    # return true if the parameters are OK or false if they are not
    def validate_parameters(data)
      true
    end

    # This allows the object to translate the keys used to store the parameters
    # into different prompts to display in the UI.  If not implemented, the
    # parameter keys will be used for the prompts
    def translate_key(key)
      key
    end

  end # class Parametric

  #=============================================================================
  # Add a context menu handler that will add a menu choice to a context menu
  # for editing parametric objects
  if (not $parametric_loaded)
    $parametric_loaded = true

    UI.add_context_menu_handler do |menu|
      klass_name = Parametric.selection_parametric?
      if klass_name
        short_klass_name = klass_name.split("::").last
        menu.add_separator
        menu.add_item("Edit #{short_klass_name}") { Parametric.edit_selection }
      end
    end
  end

end # module CommunityExtensions::Shapes
