class CommonDustjsHelpers
  @dust = null

  export_to: (dust)=>
    @export_helpers_to(dust)
    @export_filters_to(dust)

  export_helpers_to: (dust)=>
    dust.helpers = @get_helpers(dust.helpers)
    CommonDustjsHelpers.dust = dust

  export_filters_to: (dust)=>
    dust.filters = @get_filters(dust.filters)
    CommonDustjsHelpers.dust = dust

  # Render the given `context` using the dust script in the given `template_body`,
  # invoking `callback(err,output)` when done.
  render_template:(template_body, context, callback)->
    CommonDustjsHelpers.dust.renderSource template_body, context, callback

  get_helpers: (helpers)=>
    helpers ?= {}
    helpers['count']     = @count_helper
    helpers['deorphan']  = @deorphan_helper
    helpers['downcase']  = @downcase_helper
    helpers['elements']  = @elements_helper
    helpers['even']      = @even_helper
    helpers['filter']    = @filter_helper
    helpers['first']     = @first_helper
    helpers['idx']       = @classic_idx unless helpers['idx']? # restore default {@idx} if not found
    helpers['if']        = @if_helper
    helpers['index']     = @index_helper
    helpers['last']      = @last_helper
    helpers['odd']       = @odd_helper
    helpers['random']    = @random_helper
    helpers['regexp']    = @regexp_helper
    helpers['repeat']    = @repeat_helper
    helpers['sep']       = @classic_sep unless helpers['sep']? # restore default {@sep} if not found
    helpers['substring'] = @substring_helper
    helpers['titlecase'] = helpers['Titlecase'] = @titlecase_helper
    helpers['trim']      = @trim_helper
    helpers['unless']    = @unless_helper
    helpers['upcase']    = helpers['UPCASE']= @upcase_helper
    return helpers

  get_filters: (filters)=>
    filters ?= {}
    filters['json'] = @json_filter
    return filters

  # FILTER IMPLEMENTATIONS
  #############################################################################

  json_filter: (value)->
    if typeof value in ['number','boolean']
      return "#{value}"
    else if typeof value is 'string'
      json = JSON.stringify(value)
      json = json.substring(1,json.length-1)
      return json
    else if value?
      return JSON.stringify(value)
    else
      return value

  # HELPER IMPLEMENTATIONS
  #############################################################################

  count_helper: (chunk,context,bodies,params)=>
    value = @_eval_dust_string(params.of,chunk,context)
    if value?.length?
      chunk.write(value.length)
    return chunk

  deorphan_helper:(chunk,context,bodies,params)=>
    return chunk.capture bodies.block, context, (data,chunk)=>
      data = @_eval_dust_string(data,chunk,context)
      match = data.match /^((.|\s)+[^\s]{1})\s+([^\s]+\s*)$/
      if match? and match[1]? and match[2]?
        data = "#{match[1]}&nbsp;#{match[3]}"
      chunk.write(data)
      chunk.end()

  downcase_helper: (chunk,context,bodies,params)=>
    return chunk.capture bodies.block, context, (data,chunk) ->
      chunk.write(data.toLowerCase())
      chunk.end()

  elements_helper: (chunk,context,bodies,params)=>
    obj = null
    if params?['of']?
      obj_name = @_eval_dust_string(params['of'], chunk, context)
      obj = context.get(obj_name)
    index_name = "$idx"
    if params?['idx']? or params?['index']?
      index_name = @_eval_dust_string(params['idx'] ? params['index'], chunk, context)
    key_name = "$key"
    if params?['key']?
      key_name = @_eval_dust_string(params['key'], chunk, context)
    value_name = "$value"
    if params?['value']?
      value_name = @_eval_dust_string(params['value'], chunk, context)
    sort = null
    if params?['sort']?
      sort = @_eval_dust_string(params['sort'], chunk, context)
      if /^(t(rue)?$)/i.test sort
        sort = true
      else if /^(f(alse)?$)/i.test sort
        sort = null
    if sort?
      fold = null
      if params?['fold']?
        fold = @_eval_dust_string(params['fold'], chunk, context)
        if /^(t(rue)?$)/i.test fold
          fold = true
        else
          fold = false
    if obj?
      index = 0
      pairs = []
      for k,v of obj
        pair = {key:k, value:v}
        if typeof sort is 'string'
          pair.sortkey = v?[sort] ? k
        pairs.push pair
      if sort?
        if sort is true
          comparator = @_attribute_comparator("key",fold)
        else if typeof sort is 'string'
          comparator = @_attribute_comparator("sortkey",fold)
        pairs = pairs.sort(comparator)
      for p in pairs
        ctx = {}
        ctx[index_name] = index
        ctx[key_name] = p.key
        ctx[value_name] = p.value
        context = context.push(ctx)
        context.stack.index = index
        context.stack.of = pairs.length
        chunk = bodies.block(chunk, context)
        index++
    return chunk

  # @even helper - evaluates the body iff the index of the current element is even (for zebra striping, for example)
  even_helper: (chunk,context,bodies,params)=>
    if context?.stack?.index?
      c = (context.stack.index % 2 is 0)
      return @_render_if_else(c, chunk, context, bodies, params)
    return chunk

  filter_helper: (chunk,context,bodies,params)=>
    filter_type = @_eval_dust_string(params.type,chunk,context) if params?.type?
    return chunk.capture bodies.block, context, (data,chunk)->
      if filter_type?
        data = CommonDustjsHelpers.dust.filters[filter_type](data)
      chunk.write(data)
      chunk.end()

  # @first helper - evaluates the body iff the current element is the first in the list
  first_helper: (chunk,context,bodies,params)=>
    if context?.stack?.index?
      c = (context.stack.index is 0)
      return @_render_if_else(c, chunk, context, bodies, params)
    return chunk

  classic_idx: (chunk, context, bodies)->
    return bodies.block(chunk, context.push(context.stack.index))

  # {@if value=X matches=Y}
  if_helper: (chunk,context,bodies,params)=>
    execute_body = @_inner_if_helper(chunk,context,bodies,params)
    return @_render_if_else(execute_body,chunk,context,bodies,params)

  index_helper: (chunk, context, bodies, params)->
    if context?.stack?.index?
      index = 1 + context.stack.index
    else
      index = null
    if bodies?.block?
      return bodies.block(chunk, context.push(index))
    else
      chunk.write index
      return chunk

  # @last helper - evaluates the body iff the current element is the last in the list
  last_helper: (chunk,context,bodies,params)=>
    if context?.stack?.index?
      c = (context.stack.index is (context.stack.of - 1))
      return @_render_if_else(c, chunk, context, bodies, params)
    return chunk

  # @odd helper - evaluates the body iff the index of the current element is odd (for zebra striping, for example)
  odd_helper: (chunk,context,bodies,params)=>
    if context?.stack?.index?
      c = (context.stack.index % 2 is 1)
      return @_render_if_else(c, chunk, context, bodies, params)
    return chunk

  random_helper: (chunk,context,bodies,params)=>
    if params?
      if params.m? or params.min? or params.from?
        min = @_to_int(@_eval_dust_string((params.m ? params.min ? params.from), chunk, context))
      if params.M? or params.max? or params.to?
        max = @_to_int(@_eval_dust_string((params.M ? params.max ? params.to), chunk, context))
      if params.v? or params.var? or params.val? or params.set? or params.s?
        ctxvar = @_eval_dust_string((params.v ? params.var ? params.val ? params.set ? params.s), chunk, context)
    min ?= 0
    max ?= 1
    if min > max
      [min,max] = [max,min]
    if max - min is 0
      v = 0
    else
      v = Math.round(Math.random()*(max-min))+min
    if ctxvar?
      context.stack.head?[ctxvar] = v
    if bodies?.block?
      return bodies.block(chunk, context.push(v))
    else
      return chunk

  regexp_helper:(chunk,context,bodies,params)=>
    if params?.string?
      string = @_eval_dust_string(params.string,chunk,context)
    if params?.pattern?
      pattern = @_eval_dust_string(params.pattern,chunk,context)
    if params?.flags?
      flags = @_eval_dust_string(params.flags,chunk,context)
    if params?.var?
      match = @_eval_dust_string(params.var,chunk,context)
    unless match?
      match = ""
    match = "$#{match}"
    unless string? and pattern?
      return @_render_if_else false, chunk, context, bodies, params
    else
      pattern = new RegExp(pattern,flags)
      ctx = {}
      ctx[match] = string.match pattern
      return @_render_if_else ctx[match]?, chunk, context.push(ctx), bodies, params

  repeat_helper: (chunk,context,bodies,params)=>
    times = parseInt(@_eval_dust_string(params.times,chunk,context))
    if times? and not isNaN(times)
      context.stack.head?['$len'] = times
      for i in [0...times]
        context.stack.head?['$idx'] = i
        chunk = bodies.block(chunk, context.push(i, i, times))
      context.stack.head?['$idx'] = undefined
      context.stack.head?['$len'] = undefined
    return chunk

  classic_sep:(chunk, context, bodies)->
    if (context.stack.index is (context.stack.of - 1))
      return chunk
    return bodies.block(chunk, context)

  substring_helper: (chunk,context,bodies,params)=>
    if params?
      if params["of"]? or params.string? or params.str? or params.value? or params.val?
        str = @_eval_dust_string (params["of"] ? params.string ? params.str ? params.value ? params.val), chunk, context
      if params.from? and @_to_int(params.from)?
        from_index = @_to_int(params.from)
      if params.to? and @_to_int(params.to)?
        to_index = @_to_int(params.to)
    if str?
      chunk.write(@_get_substring(str,from_index,to_index))
      return chunk
    else
      return chunk.capture bodies.block, context, (data,chunk)=>
        chunk.write(@_get_substring(data,from_index,to_index))
        chunk.end()

  titlecase_helper: (chunk,context,bodies,params)=>
    return chunk.capture bodies.block, context, (data,chunk) ->
      chunk.write( data.replace(/([^\W_]+[^\s-]*) */g, ((txt)->txt.charAt(0).toUpperCase()+txt.substr(1))) )
      chunk.end()

  trim_helper: (chunk,context,bodies,params)=>
    return chunk.capture bodies.block, context, (data,chunk)->
      chunk.write(data.trim())
      chunk.end()

  # {@unless value=X matches=Y}
  unless_helper: (chunk,context,bodies,params)=>
    execute_body = @_inner_if_helper(chunk,context,bodies,params)
    execute_body = not execute_body
    return @_render_if_else(execute_body,chunk,context,bodies,params)

  upcase_helper: (chunk,context,bodies,params)=>
    return chunk.capture bodies.block, context, (data,chunk) ->
      chunk.write(data.toUpperCase())
      chunk.end()

  # INTERNAL UTILITY METHODS
  #############################################################################


  _eval_dust_string: ( str, chunk, context )->
    if typeof str is "function"
      if str.length is 0
        str = str()
      else
        buf = ''
        (chunk.tap (data) ->
          buf += data; return '').render( str, context ).untap()
        str = buf
    return str

  # if `val` is a simple integer, return it as an integer, otherwise return null
  _to_int: (val)=>
    if /^-?[0-9]+/.test val
      return parseInt(val)
    else
      return null


  # renders bodies.block iff b is true, bodies.else otherwise
  _render_if_else:(b, chunk, context, bodies, params)->
    if b is true
      chunk = chunk.render(bodies.block,context) if bodies.block?
    else
      chunk = chunk.render(bodies.else,context) if bodies.else?
    return chunk


  #coffeelint:disable=cyclomatic_complexity
  _inner_if_helper: (chunk,context,bodies,params)=>
    execute_body = false
    if params?
      if params.test?
        value = @_eval_dust_string(params.test,chunk,context)
      for c in [ 'count', 'count_of', 'count-of', 'countof' ]
        if params[c]?
          countof = @_eval_dust_string(params[c],chunk,context)
          if countof?.length?
            value = countof.length
      value ?= @_eval_dust_string(params.value,chunk,context)
      if value?
        if "#{value}" is "#{parseFloat(value)}"
          value = parseFloat(value)
        if params.matches?
          matches = @_eval_dust_string(params.matches,chunk,context)
          re = new RegExp(matches)
          execute_body = re.test(value)
        else if params['is']?
          isval = @_eval_dust_string(params['is'],chunk,context)
          if typeof value is 'number' and (not isNaN(parseFloat(isval)))
            isval = parseFloat(isval)
          execute_body = value is isval
        else if params['isnt']?
          isntval = @_eval_dust_string(params['isnt'],chunk,context)
          if typeof value is 'number' and (not isNaN(parseFloat(isntval)))
            isntval = parseFloat(isntval)
          execute_body = value isnt isntval
        else if params.above?
          above = @_eval_dust_string(params.above,chunk,context)
          if typeof value is 'number' and (not isNaN(parseFloat(above)))
            above = parseFloat(above)
          execute_body = value > above
        else if params.below?
          below = @_eval_dust_string(params.below,chunk,context)
          if typeof value is 'number' and (not isNaN(parseFloat(below)))
            below = parseFloat(below)
          execute_body = value < below
        else
          if typeof value is 'boolean'
            execute_body = value
          else if typeof value is 'number'
            execute_body = value > 0
          else if typeof value is 'string'
            if /^(T|Y|(ON))/i.test value
              execute_body = true
            else if /^-?[0-9]+(\.[0-9]+)?$/.test value and parseInt(value) > 0
              execute_body = true
            else
              execute_body = false
          else if Array.isArray(value) and value.length > 0
            execute_body = true
          else if value? and typeof value is "object" and (Object.keys(value).length > 0)
            execute_body = true
          else
            execute_body = false
    return execute_body
  #coffeelint:enable=cyclomatic_complexity

  _get_substring:(str, from_index, to_index)=>
    substring = null
    if from_index? and from_index < 0
      from_index = str.length + from_index
    if to_index? and to_index < 0
      to_index = str.length + to_index
    if from_index? and to_index? and from_index > to_index
      [from_index,to_index] = [to_index,from_index]
    if from_index? and not to_index?
      substring = str.substring(from_index)
    else if to_index? and not from_index?
      substring = str.substring(0,to_index)
    else if from_index? and to_index?
      substring = str.substring(from_index,to_index)
    else
      substring = str
    return substring

  # generates a comparator that compares two objects based on one of their attributes
  # when `fold` is `true`, `a` will sort _before_ `B`
  _attribute_comparator:(attr,fold=false)=>
    (A,B)=>
      a = A?[attr]
      b = B?[attr]
      return @_compare(a,b,fold)

  _compare:(a,b,fold=false)=>
    if a? and b?
      A = a
      B = b
      if fold?
        A = a.toUpperCase?() ? a
        B = b.toUpperCase?() ? b
      if A.localeCompare? and a.localeCompare?
        val = A.localeCompare(B)
        if val is 0 # if upper case version is tie, use lower case version
          return a.localeCompare(b)
        else
          return val
      else
        return (if a > b then 1 else (if a < b then -1 else 0))
    else if a? and not b?
      return 1
    else if b? and not a?
      return -1
    else
      return 0

# EXPORTS
###############################################################################

exports = exports ? this
exports.CommonDustjsHelpers = CommonDustjsHelpers
