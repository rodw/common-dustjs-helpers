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

## `@deorphan`

The "deorphan" helper will modify a block of HTML text to avoid a line break between the last two words.

For example, given the context:

    { foo: 'Hello World!' }

The Dust.js snippet:

    {@deorphan}The message is "{foo}".{/deorphan}

will resolve to:

    The message is "Hello&nbsp;World!".

when evaluated.

Specifically, any sequence of whitespace characters between the last and next-to-last "word" (non-whitespace sequence) in the body will be replaced with the HTML entity for a non-breaking space (`&nbsp;`).

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

This helper restores the functionality of the `{@idx}` helper in the original dust.js.  (This helper was subsequently removed in linkedin-dustjs..)

Quoting [the original dust.js documentation](http://akdubya.github.io/dustjs/):

> The idx tag passes the numerical index of the current element to the enclosed block.

    {#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}

The template above might output something like:

    Moe0, Larry1, Curly2

Note that this helper will *only* be added if an `@idx` helper does not already exist.  If `@idx` is found Dust's list of helpers it will be left alone.

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

The `matches` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of regular expression specified in `matches` (a context variable or string, possibly including dust markup).  If matched, the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

## `@index`

When looping over an array, this helper emits the one-based index of the current element.

For example, given the context:

    { mylist: ["A","B","C"] }

The Dust.js snippet:

    {#mylist}{.} is {@index/}.{@sep} {/sep}{/mylist}

yields:

    A is 1. B is 2. C is 3.

When a body is provided, `@index` sets the one-based index as the current context and evaluates the body as normal.

For example, the Dust.js snippet:

    {#mylist}{.} {@index}is {.}{/index}.{@sep} {/sep}{/mylist}

also yields:

    A is 1. B is 2. C is 3.

Note that `{@index}{/index}` yields nothing. Only the `{@index/}` syntax emits the index value without the `{.}` tag.

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

## `@random`

The "random" helper emits a random integer in the specified range.

For example, the Dust.js code:

    {@random min="1" max="100"}Your number is {.}.{/random}

might generate:

    You number is 67.

(Or more generally, the value `67` will be any integer between `1` and `100`, inclusive, with a pseudo-random distribution.)

The `random` helper accepts three parameters:

 * `min` - the minimum value to generate (defaults to `0`)
 * `max` - the minimum value to generate (defaults to `1`)
 * `set` - when specified, the random value will be assigned to a context variable of the given name.

## `@regexp`

The "regexp" helper can be used to extract the part of a string that matches a given regular expression.

For example, given the context:

    {
      "foo":"http://example.com/"
    }

the Dust.js snippet:

    {@regexp string="{foo}" pattern="^(HTTPS?:)\/\/" flags="i"}
      Protocol: {$[1]}
    {/regexp}

yields:

    Protocol: http

Similarly, given the context:

    {
      "foo":"The quick brown fox jumped over the lazy dogs."
    }

the Dust.js snippet:

    {@regexp string="{foo}" pattern="^(Th[^\s]+).*(j.mp.d).*(o.e.)"}
      First: {$[1]}
      Second: {$[2]}
      Third: {$[3]}
    {/regexp}

yields:

    First: The
    Second: jumped
    Third: over

The `regexp` helper accepts the following parameters:

 * `string` - the text that the regular expression will be matched against.  This may be a literal string or an expression containing one or more dust variables.

 * `pattern` - the regular expression that is used to perform the matching.  The contents of this parameter follow the regular JavaScript regular-expression syntax, save that the leading and trailing `/` characters are omitted.

 * `flags` - this optional parameter may contain any combination of the characters `i`, `g` and `m`.  They specify flags that modify the regular expression (ignore-case, global and multi-line, respectively), as would typically appear after the final `/` in a JavaScript regular expression literal.  (For example, the regular expression `/([aeiou])/ig` is equivalent to `pattern="([aeiou])" flags="ig"`.

 * `var` - this optional parameter specifies the context variable name used to access the numbered matches with the body of the `regexp` tag.  When omitted, the matching subexpressions will be accessed using the expression `{$[n]}` (where `n` is the index of the subexpression, as seen above).  When `var` is specified, the value of `var` is inserted between the `$` and `[`.  For example, given `var="foo"`, the first matching subexpression will be accessed via `{$foo[1]}`, the second via `{$foo[2]}` and so on.   (This is helpful as a way to disambiguate variables when `regexp` tags are nested.)

If the regular expression matches the specified string, the body of the `regexp` tag will be evaluated.  When the regular expression does not match the specified string, the `{:else}` block of the `regexp` tag (if any) will be executed.

If the "global" flag (`g`) is set, the tag pair `{#$}` `{/$}` (or `{#$<var>}` `{/$<var>}` when `var` is set) can be used to iterate over multiple matches.

For example, the Dust snippet:

    {@regexp string="The quick brown fox jumped."
             pattern="([aeiou])" flags="ig" var="M"}
      Vowels: {#$M}{.}{@sep}, {/sep}{/$M}
    {:else}
      No vowels found.
    {/regexp}

will evaluate to:

    Vowels: e, u, i, o, o, u, e

## `@repeat`

The "repeat" helper will execute its body `times` times (as if a list of `times` bodies were passed to a section block).

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

    0, 1, 2, 3

Note that the `times` parameter can be a context variable or literal numeric string.

## `@sep`

This helper restores the functionality of the `{@sep}` helper in the original dust.js.  (This helper was subsequently removed in later linkedin-dustjs releases.)

Quoting the original dust.js documentation:

> The sep tag prints the enclosed block for every value except for the last. [...]

    {#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}

The template above might output something like:

    Moe0, Larry1, Curly2

Note that this helper will only be added if the `@sep` helper does not already exist.  If `@sep` is already found it will be left alone.

Also see the `@idx` helper.

## `@substring`

The "substring" helper extracts a substring from the specified parameter or the tag body.

For example, given the context:

    {
      "foo":"The quick brown fox jumped over the lazy dogs."
    }

the Dust.js snippet:

    {@substring of="{foo}" from="4" to="15"/}

and the Dust.js snippet:

    {@substring from="4" to="15"}{foo}{/substring}

both yield:

    quick brown

The `substring` helper accepts the following parameters:

 * `of` - the string from which to take the substring. Any Dust.js tags within this value will be evaluated as they normally would.  When `of` is missing, the body of the `substring` tag is used.

 * `from` - the (zero-based) index of the first character of the string to include in the output.  This value must be an integer. When missing, defaults to `0`.  When negative, the characters are counted from the end of the string.  That is, a value of `from="-3"` is equivalent to `from="<string.length>-3"`.

 * `to` - the (zero-based) index one larger than the last character of the string to include in the output.  (That is, the substring will be the range of characters at position `i` where `from <= i < to`.) This value must be an integer. When missing, defaults to the length of the string.  When negative, the characters are counted from the end of the string.  That is, a value of `to="-3"` is equivalent to `to="<string.length>-3"`.


Note that `from` and `to` can contain Dust.js variables, which will be evaluated before the paremeter value is read.

If `from` and `to` are out of sequence (that is, `from > to`), they will be automatically swapped.

If `from` or `to` contains a non-integer value, it will be ignored (as if it was not set at all).

Here are a few more examples that illustrate the logic specified above:

    With "of", "from" and "to": |{@substring of="{foo}" from="0" to="5"/}|
    With "of" and "to": |{@substring of="{foo}" to="5"/}|
    With "of", "from" and "to": |{@substring of="{foo}" from="32" to="46"/}|
    With "of" and "from": |{@substring of="{foo}" from="32"/}|
    With negative "from": |{@substring of="{foo}" from="-14"/}|
    With negative "from" and "to": |{@substring of="{foo}" from="-14" to="-6"/}|
    With "of" and "to": |{@substring of="{foo}" to="7"/}|
    With "from" and "to": |{@substring from="0" to="5"}{foo}{/substring}|

yields:

    With "of", "from" and "to": |The q|
    With "of" and "to": |The q|
    With "of", "from" and "to": |the lazy dogs.|
    With "of" and "from": |the lazy dogs.|
    With negative "from": |the lazy dogs.|
    With negative "from" and "to": |the lazy|
    With "from" and "to": |The q|

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

## `@trim`

The "trim" helper removes leading and trailing whitespace from its body. Any Dust.js tags within the body will be evaluated as they normally would.

For example, given the context:

    { foo: '  example  ' }

The Dust.js snippet:

    This is an {@trim}{~n}{~s}{foo} {/trim}.

will resolve to:

    This is an example.


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
