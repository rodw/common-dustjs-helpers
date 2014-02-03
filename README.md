# Common Dust.js Helpers

## About

`common-dustjs-helpers` is an [npm](https://npmjs.org/) module that offers a small library of helper functions for the [Dust.js](http://akdubya.github.io/dustjs/) web-templating framework (and the [LinkedIn fork of Dust.js](https://github.com/linkedin/dustjs)).  This library is largely complementary to [LinkedIn's dustjs-helpers](https://github.com/linkedin/dustjs-helpers) library.

## Installing

`common-dustjs-helpers` is packaged as an npm module under the name [common-dustjs-helpers](https://npmjs.org/package/common-dustjs-helpers).  To install the library, run:

    npm install -g common-dustjs-helpers

(omit the `-g` flag to install the module in the local working directory rather than "globally") or add something like:

    "common-dustjs-helpers": "latest"

to the `dependencies` section of your `package.json` file.

## Using

To register the common helper functions with your Dust.js instance, require the module and then invoke the `export_helpers_to` method.  For example:


    var helpers = new require("common-dustjs-helpers").CommonDustjsHelpers();
    var dust = require("dustjs"); // or "dustjs-linkedin"
    helpers.export_helpers_to(dust);

and then use the Dust.js instance (`dust`) as you normally would.

## The Helpers

### `@count`

The "count" helper emits the size (length) of the list (array) in the context variable specified by the `of` parameter.

For example, given the context:

    { foo: [ 1, 'a', 'xyzzy' ] }

The Dust.js snippet:

    {@count of=foo/}

will resolve to:

    3

when evaluated.

### `@downcase`

The "downcase" helper will convert the tag body to lower case before emitting it.  Any Dust.js tags within the body will be evaluated as they normally would.

For example, given the context:

    { foo: 'Hello World!' }

The Dust.js snippet:

    {@downcase}The message is "{foo}".{/downcase}

will resolve to:

    the message is "hello world!".

when evaluated.

Also see the `@upcase` and `@titlecase` helpers.

### `@even`

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

### `@filter`

Dust.js includes several "filters" that convert the content of a context variable before emitting it.  For example, the snippet:

    {foo|uc}

will escape the value of the context variable `foo` using JavaScript's `encodeURIComponent` function.

The "filter" helper makes it possible to apply a filter to arbitrary text (not just the value of a variable).

For example, the snippet:

    {@filter type="uc"}{foo}{/filter}

is equivalent to `{foo|uc}`, and:

    {@filter type="uc"}Some text before. {foo} Some text after.{/filter}

will apply the filter to *all* of the text within the body of the `@filter` tag, not just the value of `foo`.

### `@first`

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

### `@last`

The "last" helper will execute its body if the current element has an odd-valued (zero-based) index, and its `else` body (if any) otherwise.

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

### `@repeat`

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

### `@upcase`

The "upcase" helper will convert the tag body to upper case before emitting it.  Any Dust.js tags within the body will be evaluated as they normally would.

For example, given the context:

    { foo: 'Hello World!' }

The Dust.js snippet:

    {@upcase}The message is "{foo}".{/upcase}

will resolve to:

    THE MESSAGE IS "HELLO WORLD!".

when evaluated.

Also see the `@downcase` and `@titlecase` helpers.

### `@titlecase`

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

## Other Methods
