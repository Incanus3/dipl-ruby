require_relative 'condition'

class Rule
  attr_reader :fact_holder

  # rule's conditions need access to the fact holding object to know if they're
  # satisfied (this is usually Environment)
  def initialize(fact_holder,&block)
    raise 'Rule.new must get a block' unless block_given?
    @fact_holder = fact_holder
    block.call(self)
  end

  # @conditions is now array and this takes multiple ones, but in the future,
  # either single condition should be defined or agregation functions should be
  # used
  # - conditions should yield a condition builder object
  # - condition builder defines 'and', 'or' methods, which return
  #   AndCondition.new(conditions), OrCondition, etc.
  # - AndCondition will subclass CollectionAggregation, which stores list of
  #   conditions and aggregates their satisfaction values
  def conditions(*conds)
    if conds.empty?
      @conditions ||= []
    else
      @conditions = conds.map {|cond| Condition.new(fact_holder,cond)}
    end
  end

  def activations(&block)
    @activations = block
  end

  def fire(bindings)
    @activations.call(bindings)
  end

  def matches
    # get list of matches for each condition - these are variable substitutions
    # find combinations of substitutions (one for each condition) with
    # consistent variable bindings and compose them
    # FOR NOW, THIS ONLY CONCATENATES THE LISTS OF MATCHINGS FOR EACH CONDITION
    # SO THIS ONLY MAKES SENSE WITH ONE CONDITION
    #
    # each condition.matches returns list of hashes, so this is a 2d list - one
    # list of possible matches for each condition
    matches = conditions.map(&:matches)
    matches.reduce(:+)
  end
end
