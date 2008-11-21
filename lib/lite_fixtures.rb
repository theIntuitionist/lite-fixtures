require 'active_record/fixtures' 
require 'erb'

class Fixtures

  def parse_yaml_string(fixture_content)    
    out = {}
    #TODO: accept empty fixtures (just fixture names, where all data comes from pattern)
    yaml = YAML.load(erb_render(fixture_content))
    yaml.collect{ |label, data| out.merge!(enlighten({label => data})) } if yaml
    out
  end
  
  def enlighten(fixture)
    label = fixture.keys.first
    data = fixture[label]
    
    if pattern?(label)
      propigate_pattern(label, enlighten(data))
    elsif group?(fixture)
      fixture.inject({}) do |memo, pair| 
        key, value = pair
        out = enlighten(propagate_grouping({key => value}))
        memo.merge(out)
      end
    else
      fixture
    end
  end
  
  def pattern?(label)
    !!( label =~ /\(/ )
  end
  
  def propigate_pattern(pattern, fixtures)
    out = {}
    fixtures.each{ |label, data| out[label] = apply_pattern(pattern, label).merge(data) }
    out
  end

  def apply_pattern(pattern, fixture_name)
    # get keys from pattern
    keys = pattern.scan(/\(([^\).]+)\)/).flatten
  
    # get values from fixtures name
    regexp = pattern
    keys.each{ |key| regexp = regexp.gsub(key, '.+') }
    values = fixture_name.match(Regexp.new(regexp)).captures.collect{ |value| value.gsub(/-/, ' ') }
  
    # compose hash
    out = {}
    keys.each_with_index{ |key, i| out[key] = values[i] }

    out
  end

  def group?(hash)
    hash.values.first.values.collect(&:class).any?{ |type| type == Hash }
  end

  def propagate_grouping(hash)
    group = hash.values.first 
    to_propagate = {}
    output = {}
  
    group.each{ |key, value| to_propagate[key] = value unless value.is_a? Hash }
    group.each{ |key, value| output[key] = value.merge(to_propagate) if value.is_a? Hash }
    output
  end

end