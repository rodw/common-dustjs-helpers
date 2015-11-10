# Common Dust.js Helpers

## About

`common-dustjs-helpers` is an [npm](https://npmjs.org/) module that offers a small library of helper functions for the [Dust.js](http://akdubya.github.io/dustjs/) web-templating framework (and the [LinkedIn fork of Dust.js](https://github.com/linkedin/dustjs)).  This library is largely complementary to [LinkedIn's dustjs-helpers](https://github.com/linkedin/dustjs-helpers) library.

The philosophy behind `common-dustjs-helpers` is the same as that behind dust.js itself--namely that templates should contain presentation-level logic, free from side effects (and hence composable and capable of running in parellel).  In particular, you will not find helper functions that allow you to execute arbitrary JavaScript.

NOTE: This repository follows the [git flow](https://github.com/nvie/gitflow) branching model.  The latest stable (released) version of the code should be found in the `master` branch.  (Individual releases will be tagged in that branch.) The latest unstable (un-released) version of the code should be found in the `develop` branch.  

## Installing

`common-dustjs-helpers` is packaged as an npm module under the name [common-dustjs-helpers](https://npmjs.org/package/common-dustjs-helpers).  To install the library, run:

    npm install -g common-dustjs-helpers

(omit the `-g` flag to install the module in the local working directory rather than "globally") or add something like:

    "common-dustjs-helpers": "latest"

to the `dependencies` section of your `package.json` file.

## Using

To register the common helper functions with your Dust.js instance, require the module and then invoke the `export_helpers_to` method.  For example:


    var helpers = new require("common-dustjs-helpers").CommonDustjsHelpers;
    var dust = require("dustjs"); // or "dustjs-linkedin"
    helpers.export_to(dust);

and then use the Dust.js instance (`dust`) as you normally would.

## The Helpers

 * **@count** - emits the size of an array or similiar container (e.g., `{@count of=foo/}`).
 
 * **@deorphan** - replaces whitespace between the last two "words" of the body to `&nbsp;` (e.g., `{@deorphan}Foo bar.{/deorphan}` becomes `Foo&nbsp;bar.`).
 
 * **@downcase** - converts text to lower case (e.g., `{@downcase}Foo{/downcase}`).
 
 * **@even** - executes only for even-valued (zero-based) indexes (e.g., `{#foo}{@even}{.} is even.{:else}{.} is odd.{/even}{/foo}`).

 * **@filter** - applies a strandard dust `|x` filter to the tag body (e.g., `{@filter type="uc"}Foo {bar} xyzzy.{/filter}`).

 * **@first** - executes only for the first element in a list (e.g., `{#foo}{@first}{.} is first.{:else}{.} is not first.{/first}{/foo}`).

 * **@idx** - restores the original dust.js `idx` helper (e.g., `{#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}`)

 * **@if** - conditionally executes the body (e.g., `{@if value=foo is="Bar"}Foo === "Bar"{:else}Foo !== "Bar"{/if}`).

 * **@index** - yields the one-based index of the current element (e.g., `{#foo}{.} is index {@index/}`).

 * **@last** - executes only for the last element in a list (e.g., `{#foo}{@last}{.} is last.{:else}{.} is not last.{/last}{/foo}`).

 * **@odd** - executes only for odd-valued (zero-based) indexes (e.g., `{#foo}{@odd}{.} is odd.{:else}{.} is even.{/odd}{/foo}`)

 * **@repeat** - repeat N times (e.g., `{@repeat times="3"}Well{@sep}, {/sep}{/repeat}`).
 
 * **@sep** - restores the original dust.js `sep` helper (e.g., `{#names}{.}{@idx}{.}{/idx}{@sep}, {/sep}{/names}`)

 * **@titlecase** - converts text to title case (e.g., `{@titlecase}Foo{/titlecase}`)
 
 * **@unless** - conditionally executes the body (e.g., `{@unless value=foo is="Bar"}Foo !== "Bar"{:else}Foo === "Bar"{/unless}`).
 
 * **@upcase** - converts text to upper case (e.g., `{@upcase}Foo{/upcase}`)

See [helpers.md](https://github.com/rodw/common-dustjs-helpers/blob/master/docs/helpers.md) for detailed documentation.

## The Filters

 * **{|json}** - escapes content for use *within* a JSON string (unlike the built-in `{|js}` which filters text *to* a JSON string or object.)  (Note that generally you'll want to use something like `{foo|json|s}` to prevent Dust's standard entity-encoding, etc. from occurring.)
