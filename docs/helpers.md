# Common Dust.js Helpers: The Helpers

## `@count`

The "count" helper emits the size (length) of the list (array) in the context variable specified by the `of` parameter.

For example, given the context:

    { foo: [ 1, 'a', 'xyzzy' ] }

The Dust.js snippet:

    {@count of=foo/}

will resolve to:

    3

when evaluated.

## `@downcase`

The "downcase" helper will convert the tag body to lower case before emitting it.  Any Dust.js tags within the body will be evaluated as they normally would.

For example, given the context:

    { foo: 'Hello World!' }

The Dust.js snippet:

    {@downcase}The message is "{foo}".{/downcase}

will resolve to:

    the message is "hello world!".

when evaluated.

Also see the `@upcase` and `@titlecase` helpers.

## `@even`

The "even" helper will execute its body if the current element has an even-valued (zero-based) index, and its `else` body (if any) otherwise.

For example, given the context:

    { mylist: [0,1,2,3,4] }

The Dust.js snippet:

    {#mylist}
      {@even}
        {.} is even.{~n}
      {:else}
        {.} is not even.{~n}
      {/even}
    {/mylist}

will resolve to:

    0 is even.
    1 is not even.
    2 is even.
    3 is not even.
    4 is even.

when evaluated.

Also see the `@odd`, `@first` and  `@last` helpers.

## `@filter`

Dust.js includes several "filters" that convert the content of a context variable before emitting it.  For example, the snippet:

    {foo|uc}

will escape the value of the context variable `foo` using JavaScript's `encodeURIComponent` function.

The "filter" helper makes it possible to apply a filter to arbitrary text (not just the value of a variable).

For example, the snippet:

    {@filter type="uc"}{foo}{/filter}

is equivalent to `{foo|uc}`, and:

    {@filter type="uc"}Some text before. {foo} Some text after.{/filter}

will apply the filter to *all* of the text within the body of the `@filter` tag, not just the value of `foo`.

## `@first`

The "first" helper will execute its body if the current element is the first element of a list, and its `else` body (if any) otherwise.

For example, given the context:

    { mylist: [1,2,3,4,5] }

The Dust.js snippet:

    {#mylist}
      {@first}
        {.} is the first value.{~n}
      {:else}
        {.} is not the first value.{~n}
      {/first}
    {/mylist}

will resolve to:

    1 is the first value.
    2 is not the first value.
    3 is not the first value.
    4 is not the first value.
    5 is not the first value.

when evaluated.

Also see the `@last`, `@even` and  `@odd` helpers.

## `@idx`

This helper restores the functionality of the `{@idx}` helper in the original dust.js.  (This helper was subsequently removed in later linkedin-dustjs releases.)

Quoting the original dust.js documentation: The idx tag passes the numerical index of the current element to the enclosed block.

    {#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}

The template above might output something like:

    Moe0, Larry1, Curly2

Note that this helper will only be added if the `@idx` helper does not already exist.  If `@idx` is already found it will be left alone.

Also see the `@sep` helper.

## `@if`

This helper conditionally executes the tag body (or an `{:else}` block, if any) based on a several types of predicate.


### `@if value=true/false`

When the `value` parameter is used by itself, the `@if` helper will execute the body if the specified value is (or evaluates to):

 * the boolean `true`
 * a positive, non-zero numeric value
 * a string starting with `T` or `Y` (case-insensitive)
 * the string `on` (case-insensitive)
 * a non-empty array or object (map).
 
For example:

    {@if value=foo}YES{:else}NO{/if}
    
will emit `YES` for the following contexts:

  * `{foo:true}`
  * `{foo:"true"}`
  * `{foo:"Y"}`
  * `{foo:1}`
  * `{foo:"1"}`
  * `{foo:2}`
  * `{foo:0.1}`
  * `{foo:"on"}`
  * `{foo:function() { return true; }}`
  * `{foo:[1,2]}`
  * `{foo:{bar:"xyzzy"}}`
  
and `NO` for the following contexts:

  * `{foo:false}`
  * `{foo:"false"}`
  * `{foo:"N"}`
  * `{foo:0}`
  * `{foo:"0"}`
  * `{foo:-2}`
  * `{foo:-0.1}`
  * `{foo:"off"}`
  * `{foo:function() { return false; }}`
  * `{foo:[]}`
  * `{foo:{}}`
  * `{foo:null}`
  * `{bar:"anything"}`

### `@if value=foo is=bar`

The `is` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `is` (a context variable or string, possibly including dust markup).  If the values are equal (`===`) the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

### `@if value=foo isnt=bar`

The `isnt` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `is` (a context variable or string, possibly including dust markup).  If the values are NOT equal (`!==`) the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

### `@if value=foo isnt=bar`

The `isnt` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `is` (a context variable or string, possibly including dust markup).  If the values are NOT equal (`!==`) the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

### `@if value=foo above=bar`

The `above` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `above` (a context variable or string, possibly including dust markup) using the `>` operator.  If `value > above` the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

### `@if value=foo below=bar`

The `below` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `below` (a context variable or string, possibly including dust markup) using the `<` operator.  If `value < below` the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

### `@if value=foo matches=bar`

The `matches` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of regular expression specified in `matches` (a context variable or string, possibly including dust markup).  If matched, teh body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.
  
## `@last`

The "last" helper will execute its body if the current element is the last element of a list, and its `else` body (if any) otherwise.

For example, given the context:

    { mylist: [1,2,3,4,5] }

The Dust.js snippet:

    {#mylist}
      {@last}
        {.} is the last value.{~n}
      {:else}
        {.} is not the last value.{~n}
      {/last}
    {/mylist}

will resolve to:

    1 is not the last value.
    2 is not the last value.
    3 is not the last value.
    4 is not the last value.
    5 is the last value.

when evaluated.

Also see the `@last`, `@even` and  `@odd` helpers.

## `@odd`

The "odd" helper will execute its body if the current element has an odd-valued (zero-based) index, and its `else` body (if any) otherwise.

For example, given the context:

    { mylist: [0,1,2,3,4] }

The Dust.js snippet:

    {#mylist}
      {@odd}
        {.} is odd.{~n}
      {:else}
        {.} is not odd.{~n}
      {/odd}
    {/mylist}

will resolve to:

    0 is not odd.
    1 is odd.
    2 is not odd.
    3 is odd.
    4 is not odd.

when evaluated.

Also see the `@even`, `@first` and  `@last` helpers.

## `@repeat`

The "repeat" helper will execute its body `times` times (as if a list of `times` bodies were passed to a section block.

For example the Dust.js snippet:

    {@repeat times="3"}
       Well{@sep}, {/sep}
    {/repeat}

will resolve to:

    Well, Well, Well

when evaluated.

Each time the zero-based numeric index is passed as the `{.}` context.  E.g., the Dust.js snippet:

    {@repeat times="4"}
       {.}
       {@sep}, {/sep}
    {/repeat}

will resolve to:

    0,1,2,3

Note that the `times` parameter can be a context variable or literal numeric string.

## `@sep`

This helper restores the functionality of the `{@sep}` helper in the original dust.js.  (This helper was subsequently removed in later linkedin-dustjs releases.)

Quoting the original dust.js documentation: The sep tag prints the enclosed block for every value except for the last. [...]

    {#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}

The template above might output something like:

    Moe0, Larry1, Curly2

Note that this helper will only be added if the `@sep` helper does not already exist.  If `@sep` is already found it will be left alone.

Also see the `@idx` helper.

## `@titlecase`

The "titlecase" helper will convert the tag body to "title case" before emitting it.  Any Dust.js tags within the body will be evaluated as they normally would.

Currently, `@titlecase` will convert the first letter of every whitespace or dash-delimited word to upper case.  Other characters will not be modified.

For example, given the context:

    { foo: 'hello WORLD!' }

The Dust.js snippet:

    {@titlecase}The message is "{foo}".{/titlecase}

will resolve to:

    The Message Is "Hello WORLD!".

when evaluated.

***NOTE*** The precise rules by which `@titlecase` modifies the case of the input text is subject to change in future releases. Eventually we'll settle on a specific contract, but we're not ready to do that yet.

Also see the `@upcase` and `@downcase` helpers.

## `@unless`

The `@unless` helper is identical to the `@if` helper with the logic cases reversed.  That is, @unless will execute the `{:else}` block (if any) when the condition evaluates to `true` and the body block otherwise.

See the `@if` helper for more details.

## `@upcase`

The "upcase" helper will convert the tag body to upper case before emitting it.  Any Dust.js tags within the body will be evaluated as they normally would.

For example, given the context:

    { foo: 'Hello World!' }

The Dust.js snippet:

    {@upcase}The message is "{foo}".{/upcase}

will resolve to:

    THE MESSAGE IS "HELLO WORLD!".

when evaluated.

Also see the `@downcase` and `@titlecase` helpers.
