# Common Dust.js Helpers

## About

`common-dustjs-helpers` is an [npm](https://npmjs.org/) module that offers a small library of helper functions for the [Dust.js](http://akdubya.github.io/dustjs/) web-templating framework (and the [LinkedIn fork of Dust.js](https://github.com/linkedin/dustjs)).  This library is largely complementary to [LinkedIn's dustjs-helpers](https://github.com/linkedin/dustjs-helpers) library.

The philosophy behind `common-dustjs-helpers` is the same as that behind dust.js itself--namely that templates should contain presentation-level logic, free from side effects (and hence composable and capable of running in parallel).  In particular, you will not find helper functions that allow you to execute arbitrary JavaScript.

NOTE: This repository follows the [git flow](https://github.com/nvie/gitflow) branching model.  The latest stable (released) version of the code should be found in the `master` branch.  (Individual releases will be tagged in that branch.) The latest unstable (un-released) version of the code should be found in the `develop` branch.

## Installing

`common-dustjs-helpers` is packaged as an npm module under the name [common-dustjs-helpers](https://npmjs.org/package/common-dustjs-helpers).  To install the library, run:

    npm install common-dustjs-helpers

or add something like:

    "common-dustjs-helpers": "latest"

to the `dependencies` section of your `package.json` file.

## Using

To register the common helper functions with your Dust.js instance, require the module and then invoke the `exportTo` method.  For example:

    var dust = require("dustjs-linked"); // or just "dustjs"
    require("common-dustjs-helpers").exportTo(dust);

You can then use the Dust.js instance (`dust`) as you normally would.

If you'd like to register the helper methods but not the filter, use `exportHelpersTo`.  If you'd like to register the filter(s) but not the helper methods, use `exportFiltersTo`.

Note that `exportTo`, `exportHelpersTo` and `exportFiltersTo` are also available as `export_to`, `export_helpers_to` and `export_filters_to`.

## The Helpers

[@count](#count) | [@deorphan](#deorphan) | [@downcase](#downcase) | [@elements](#elements) | [@even](#even) | [@filter](#filter) | [@first](#first) | [@idx](#idx) | [@if](#if) | [@index](#index) | [@last](#last) | [@odd](#odd) | [@random](#random) | [@regexp](#regexp) | [@repeat](#repeat) | [@sep](#sep) | [@substring](#substring) | [@switch](#switch) | [@titlecase](#titlecase) | [@trim](#trim) | [@unless](#unless) | [@upcase](#upcase)

### @count

Emits the size (length) of an array, map or similar container.

**Parameters:**

 * `of`, `in` - reference to context variable to count

**Example:**
> Context:
>
> ```json
> { "foo": [1,2,3,4,5] }
> ```
>
> Template:
>
> ```dustjs
> The array has {@count of=foo/} elements.
> ```
>
> Output:
>
> ```
> The array has 5 elements.
> ```

**Another Example:**

>Context:
>
>```json
>{ "bar": { "a":1, "b":2, "c":3 } }
>```
>
>Template:
>
>```dustjs
>The map has {@count of=bar/} keys.
>```
>
>Output:
>
>```
>The map has 3 keys.
>```

### @deorphan

Replaces whitespace between the last two "words" of the body with `&nbsp;`

**Parameters:**

_none_

**Example:**

> Template:
>
> ```dustjs
> {@deorphan}The last word won't be left dangling.{/deorphan}.
> ```
>
> Output:
>
> ```html
> The last word won't be left&nbsp;dangling.
> ```

### @downcase

Converts body text to lower case.

**Parameters:**

_none_

**Example:**

> Context:
>
>```json
>{ "name":"World" }
>```
>
> Template:
>
> ```dustjs
> {@downcase}Hello {name}.{/downcase}.
> ```
>
> Output:
>
> ```
> hello world.
> ```

### @elements

Iterates over the key-value pairs in a map, exposing `$key`, `$value` and `$idx` context variables inside the loop.

When the specified map is empty or undefined, the `{:else}` block (if any) will be executed.

**Parameters:**

 * `of`, `in` - reference to context variable to iterate over
 * `idx`, `index` - optional alternative name for the context variable that will contain the zero-based index of the element inside the loop; defaults to `$idx`
 * `key` - optional alternative name for the context variable that will contain the key while inside the loop; defaults to `$key`.
 * `value` - optional alternative name for the context variable that will contain the value while inside the loop; defaults to `$value`.
 * `sort` - determines order by which the list of pairs will be iterated over.  Note that numeric values will be sorted as numbers.
   * when `false` (the default) no sort will be applied.
   * when `true` the pairs will be sorted by key.
   * when a blank string (`""`), the pairs will be sorted by value.
   * when a non-blank string other than `true` or `false` is used, the value part of each pair is assumed to be a map, and pairs will be sorted the specified attribute of the value-map.
 * `dir` - if sorting, set `dir` equal to `d`, `dec` `dsc`, `desc`, or  `descending` to reverse the order of the sort.

**Example:**

> Context:
>
> ```json
> {
>   "themap": {
>     "Y":2,
>     "Z":1,
>     "X":3
>   }
> }
> ```
>
> Template:
>
> ```dustjs
> Unsorted:
>
> {@elements of=themap}{$idx}.{$key}={$value}; {/@elements}
>
> By key:
>
> {@elements of=themap sort="true"}{$idx}.{$key}={$value}; {/@elements}
>
> By value:
>
> {@elements of=themap sort=""}{$idx}.{$key}={$value}; {/@elements}
> ```
>
> Output:
>
> ```
> Unsorted
>
> 0.Y=2; 1.Z=1; 2.X=3;
>
> By key:
>
> 0.X=3; 1.Y=2; 2.Z=1;
>
> By value:
>
> 0.Z=1; 1.Y=2; 2.X=3;
> ```


Note that sequence-based helper tags (`@even`, `@odd`, `@first`, `@last`, `@index`, `@idx`, `@sep`, etc.) work within the `@elements` helper in the same way that they do within the built-in `{#foo}{/foo}` array-iterating blocks.  The same statement should be true for any dust helper function that relies on the (standard) `stack.index` and `stack.of` properties of the dust context object.


### @even

Executes the body for even-indexed elements of a list, the `{:else}` block for others.

**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "list":["A","B","C","D","E"] }
> ```
>
> Template:
> ```dustjs
>  {#list}
>   * {@even}{.} is even.{:else}{.} is odd.{/even}
>  {/list}
> ```
>
> Output:
>
> ```
>  * A is even.
>  * B is odd.
>  * C is even.
>  * D is odd.
>  * E is even.
> ```


### `@filter`

Dust.js includes several "filters" that convert the content of a context variable before emitting it.  For example, the snippet:

```dustjs
{foo|uc}
```

will escape the value of the context variable `foo` using JavaScript's `encodeURIComponent` function.

The `@filter` helper makes it possible to apply a filter to arbitrary text (not just the value of a variable).

For example, the snippet:

    {@filter type="uc"}{foo}{/filter}

is equivalent to `{foo|uc}`, and:

    {@filter type="uc"}Some text before. {foo} Some text after.{/filter}

will apply the filter to *all* of the text within the body of the `@filter` tag, not just the value of `foo`.


**Parameters:**

 * `type` - the filter type (in the base dustjs implementation, this includes `h`, `s`, `js`, `u`, `uc`, but any registered filter value can be applied).

**Example:**

> Context:
>
> ```json
> { "name":"<em>World</em>" }
> ```
>
> Template:
> ```dustjs
> {@filter type="h"}<blink>Hello {name}!</blink>{/filter}
> ```
>
> Output:
>
> ```
> &lt;blink&gt;Hello &lt;em&gt;World&lt;/em&gt;!&lt;/blink&gt;.
> ```


### @first

Executes the body for first element in a list or enumeration, the `{:else}` block for others.

**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "list":["A","B","C","D","E"] }
> ```
>
> Template:
> ```dustjs
>  {#list}
>   * {@first}{.} is first.{:else}{.} is not first.{/first}
>  {/list}
> ```
>
> Output:
>
> ```
>  * A is first.
>  * B is not first.
>  * C is not first.
>  * D is not first.
>  * E is not first.
> ```


### @idx

This helper restores the functionality of the `{@idx}` helper in the original dust.js.  (This helper was subsequently removed in linkedin-dustjs.)

Quoting [the original dust.js documentation](http://akdubya.github.io/dustjs/):

> The idx tag passes the numerical index of the current element to the enclosed block.


**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "names": [ "Moe", "Larry", "Curly" ] }
> ```
>
> Template:
>
> ```dustjs
> {#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}
> ```
>
> Output:
>
> ```
> Moe0, Larry1, Curly2
> ```

Note that this helper will *only* be added if an `@idx` helper does not already exist.  If `@idx` is found in Dust's list of helper functions it will be left alone.

Also see the [`@sep`](#sep) and [`@index`](#index) helpers.


### @if

This helper conditionally executes the tag body (or an `{:else}` block, if any) based on a several types of predicate.

#### @if value=true/false

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

#### `@if value=foo is=bar`

The `is` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `is` (a context variable or string, possibly including dust markup).  If the values are equal (`===`) the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

#### `@if value=foo isnt=bar`

The `isnt` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `is` (a context variable or string, possibly including dust markup).  If the values are NOT equal (`!==`) the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

#### `@if value=foo isnt=bar`

The `isnt` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `is` (a context variable or string, possibly including dust markup).  If the values are NOT equal (`!==`) the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

#### `@if value=foo above=bar`

The `above` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `above` (a context variable or string, possibly including dust markup) using the `>` operator.  If `value > above` the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

#### `@if value=foo below=bar`

The `below` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of `below` (a context variable or string, possibly including dust markup) using the `<` operator.  If `value < below` the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.

#### `@if value=foo matches=bar`

The `matches` parameter will compare the value of `value` (a context variable or string, possibly including dust markup) to that of regular expression specified in `matches` (a context variable or string, possibly including dust markup).  If matched, the body will be evaluated, otherwise the `{:else}` block (if any) will be evaluated.


### @index

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


### @last

Executes the body for last element in a list or enumeration, the `{:else}` block for others.

**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "list":["A","B","C","D","E"] }
> ```
>
> Template:
> ```dustjs
>  {#list}
>   * {@last}Finally, {.} is last.{:else}{.} is not last.{/last}
>  {/list}
> ```
>
> Output:
>
> ```
>  * A is not last.
>  * B is not last.
>  * C is not last.
>  * D is not last.
>  * Finally, E is last.
> ```


### @odd

Executes the body for odd-indexed elements in a list or enumeration, the `{:else}` block for others.

**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "list":["A","B","C","D","E"] }
> ```
>
> Template:
> ```dustjs
>  {#list}
>   * {@odd}{.} is odd.{:else}{.} is even.{/odd}
>  {/list}
> ```
>
> Output:
>
> ```
>  * A is even.
>  * B is odd.
>  * C is even.
>  * D is odd.
>  * E is even.
> ```


#### @random

The `@random` helper emits a random integer in the specified range.

For example, the Dust.js code:

    {@random min="1" max="100"}Your number is {.}.{/random}

might generate:

    You number is 67.

(Or more generally, the value `67` will be any integer between `1` and `100`, inclusive, with a pseudo-random distribution.)

The `random` helper accepts three parameters:

 * `min` - the minimum value to generate (defaults to `0`)
 * `max` - the minimum value to generate (defaults to `1`)
 * `set` - when specified, the random value will be assigned to a context variable of the given name.

### @regexp

The `@regexp` helper can be used to extract the part of a string that matches a given regular expression.

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

### @repeat

The `@repeat` helper will execute its body `times` times (as if a list of `times` bodies were passed to a section block).

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

Also note that sequence-based helper tags (`@even`, `@odd`, `@first`, `@last`, `@index`, `@idx`, `@sep`, etc.) work within the `@repeat` helper in the same way that they do within the built-in `{#foo}{/foo}` array-iterating blocks.  The same statement should be true for any dust helper function that relies on the (standard) `stack.index` and `stack.of` properties of the dust context object.


### @sep

This helper restores the functionality of the `{@sep}` helper in the original dust.js.  (This helper was subsequently removed in later linkedin-dustjs releases.)

Quoting the original dust.js documentation:

> The sep tag prints the enclosed block for every value except for the last. [...]

    {#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}

The template above might output something like:

    Moe0, Larry1, Curly2

Note that this helper will only be added if the `@sep` helper does not already exist.  If `@sep` is already found it will be left alone.

Also see the `@idx` helper.


### @substring

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




### @switch

Implements a "switch" or "case" statement, executing one of several alternatives based some value.

The value to switch on is specified in the parameter `on`, which can be a dust context variable, a literal string, or a literal string containing dust context variables.

The body to execute is determined by comparing the value of `on` to the name of each block.  Empty strings, `null` and `undefined` values trigger the primary body block (the unlabeled one). Non-empty values trigger the block with the corresponding name (e.g. the `{:foo}` block will be evaluated when the value of `on` resolved to `foo`).  When no block matches the value of `on`, the `{:else}` block, if any, is executed.

**Parameters:**

 * `on` - the value to switch on.

**Example:**

> Context:
>
> ```json
> { "val":"xyzzy" }
> ```
>
> Template:
> ```dustjs
>  {@switch on=val}
>   {:foo}The value was foo.
>   {:bar}The value was bar.
>   {:xyzzy}The value was xyzzy.
>   {:else}The value was something else.
>  {/switch}
> ```
>
> Output:
>
> ```
> The value was xyzzy.
> ```

**Hints:**

Sometimes you need to work-around the limitations of the strings that dustjs will accept within the `{:block}` tag by modifying the value you are swithcing on.

For example, dustjs will not allow a numeric block label such as `{:3}`, so you must add a prefix to both the value and block labels:

```dustjs
{@switch on="num{val}"}
{:num1}The number was one.
{:num2}The number was two.
{:num3}The number was three.
{/switch}
```

### @titlecase

Converts the tag body text to title-case, upcasing the first letter of every "word".

**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "book":"a christmas carol" }
> ```
>
> Template:
> ```dustjs
> Charles Dickens wrote "{@titlecase}{book}{/titlecase}".
> ```
>
> Output:
>
> ```
> Charles Dickens wrote "A Christmas Carol".
> ```



### @trim

The `@trim` helper removes leading and trailing whitespace from its body. Any Dust.js tags within the body will be evaluated as they normally would.

For example, given the context:

    { foo: '  example  ' }

The Dust.js snippet:

    This is an {@trim}{~n}{~s}{foo} {/trim}.

will resolve to:

    This is an example.



### @unless

The `@unless` helper is identical to the `@if` helper with the logic cases reversed.  That is, `@unless` will execute the `{:else}` block (if any) when the condition evaluates to `true` and the body block otherwise.

See the [`@if`](#if) helper for more details.


### @upcase

Converts body text to upper case.

**Parameters:**

_none_

**Example:**

> Context:
>
> ```json
> { "name":"World" }
> ```
>
> Template:
>
> ```dustjs
> {@upcase}Hello {name}.{/upcase}.
> ```
>
> Output:
>
> ```
> HELLO WORLD.
> ```


## The Filters

 * **{|json}** - escapes content for use *within* a JSON string (unlike the built-in `{|js}` which filters text *to* a JSON string or object.)  (Note that generally you'll want to use something like `{foo|json|s}` to prevent Dust's standard entity-encoding, etc. from occurring.)
