path                = require 'path'
fs                  = require 'fs'
HOMEDIR             = path.join __dirname, '..'
DOCROOT             = path.join HOMEDIR, 'test', 'test-data'
IS_INSTRUMENTED     = fs.existsSync(path.join(HOMEDIR,'lib-cov'))
LIB_DIR             = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
CommonDustjsHelpers = require(path.join(LIB_DIR,'common-dustjs-helpers')).CommonDustjsHelpers
#---------------------------------------------------------------------
should     = require 'should'
dust       = require('dustjs-linkedin')
(new CommonDustjsHelpers()).export_to(dust)


class DustTestSuite
  constructor: (suitename,testdata) ->
    @suitename = suitename
    unless Array.isArray(testdata)
      a = []
      for name,map of testdata
        map.name = name.replace(/\"/g,"''")
        a.push map
      @testdata = a
    else
      @testdata = testdata

  run_tests_on: (dust)->
    describe @suitename, =>
      for test in @testdata
        @run_one_test test, dust

  run_one_test: (input, dust)->
    it input.name, (done)->
      dust.loadSource dust.compile( input.source, input.name)
      dust.render input.name, input.context, (err,out)=>
        should.not.exist err, "Did not expect an error when processing template \"#{input.name}\". Found: #{err}"
        if input.expected.test?
          (input.expected.test out).should.be.ok
        else
          out.should.equal input.expected, "Template \"#{input.name}\" failed to generate expected value. Found:\n#{out}"
        done()

new DustTestSuite("DustTestSuite", {
  'can render plain text':{
    source:   'Hello World!',
    context:  {},
    expected: 'Hello World!'
  },
  'can render simple variable substitution':{
    source:   'Hello {name}!',
    context:  { name:"World"},
    expected: 'Hello World!'
  }
}).run_tests_on dust

new DustTestSuite("|json filter", {
  'can escape for JSON':{
    source:   '{foo|json|s}',
    context:  {foo:'A string with\n\t"FUNKY CHARACTERS".'},
    expected: "A string with\\n\\t\\\"FUNKY CHARACTERS\\\"."
  }
}).run_tests_on dust

for i in [0...10]

  new DustTestSuite("@random helper", {
    "can generate random values 0/1 ##{i+1}":{
      source:   '{@random}Value={.}{/random}'
      context:  {}
      expected: /^Value=(0|1)$/
    }
  }).run_tests_on dust

  new DustTestSuite("@random helper", {
    "can generate random values between 10 and 20 ##{i+1}":{
      source:   '{@random min="10" max="20" set="val"/}Value={val}{@random min="0" max="9" set="val2"/};Value={val2}'
      context:  {}
      expected: /^Value=((10)|(11)|(12)|(13)|(14)|(15)|(16)|(17)|(18)|(19)|(20));Value=(0|1|2|3|4|5|6|7|8|9)$/
    }
  }).run_tests_on dust

  new DustTestSuite("@random helper", {
    "can generate random values between 1 and 5 with @if ##{i+1}":{
      source:   '{@random min="1" max="5"}{@if value="{.}" is="1"}A{:else}{@if value="{.}" is="2"}B{:else}{@if value="{.}" is="3"}C{:else}{@if value="{.}" is="4"}D{:else}{@if value="{.}" is="5"}E{:else}XXXX{/if}{/if}{/if}{/if}{/if}{/random}'
      context:  {}
      expected: /^(A|B|C|D|E)$/
    }
  }).run_tests_on dust

new DustTestSuite("@trim helper", {
  'can trim leading and trailing spaces':{
    source:   'BEFORE {@trim} within the helper {/trim} AFTER.'
    context:  {}
    expected:  'BEFORE within the helper AFTER.'
  }
}).run_tests_on dust

new DustTestSuite("@trim helper", {
  'can trim leading and trailing spaces within values':{
    source:   'BEFORE {@trim}{text} {/trim} AFTER.'
    context:  { text:" within the helper "},
    expected:  'BEFORE within the helper AFTER.'
  }
}).run_tests_on dust

new DustTestSuite("@substring helper", {
  'can extract substrings from parameter (with from and to)':{
    source:   'BEFORE {@substring of="The quick brown fox jumped." from="4" to="8"/} AFTER.'
    context:  {}
    expected: 'BEFORE quic AFTER.'
  },
  'can extract substrings from parameter (with from, no to)':{
    source:   'BEFORE {@substring of="The quick brown fox jumped." from="7"/} AFTER.'
    context:  {}
    expected: 'BEFORE ck brown fox jumped. AFTER.'
  },
  'can extract substrings from parameter (no from, with to)':{
    source:   'BEFORE {@substring of="The quick brown fox jumped." to="17"/} AFTER.'
    context:  {}
    expected: 'BEFORE The quick brown f AFTER.'
  },
  'can extract substrings from parameter (negative from, negative to)':{
    source:   'BEFORE {@substring of="The quick brown fox jumped." from="-10" to="-3"/} AFTER.'
    context:  {}
    expected: 'BEFORE ox jump AFTER.'
  },
  'can extract substrings from parameter (negative from, no to)':{
    source:   'BEFORE {@substring of="The quick brown fox jumped." from="-11"/} AFTER.'
    context:  {}
    expected: 'BEFORE fox jumped. AFTER.'
  },
  'can extract substrings from parameter (no from, negative to)':{
    source:   'BEFORE {@substring of="The quick brown fox jumped." to="-10"/} AFTER.'
    context:  {}
    expected: 'BEFORE The quick brown f AFTER.'
  },
  'can extract substrings from parameter with variable (with from and to)':{
    source:   'BEFORE {@substring of="The {adj} {animal} jumped." from="4" to="8"/} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE quic AFTER.'
  },
  #
  'can extract substrings from body (with from and to)':{
    source:   'BEFORE {@substring from="4" to="8"}The quick brown fox jumped.{/substring} AFTER.'
    context:  {}
    expected: 'BEFORE quic AFTER.'
  },
  'can extract substrings from body (with from, no to)':{
    source:   'BEFORE {@substring from="7"}The quick brown fox jumped.{/substring} AFTER.'
    context:  {}
    expected: 'BEFORE ck brown fox jumped. AFTER.'
  },
  'can extract substrings from body (no from, with to)':{
    source:   'BEFORE {@substring to="17"}The quick brown fox jumped.{/substring} AFTER.'
    context:  {}
    expected: 'BEFORE The quick brown f AFTER.'
  },
  'can extract substrings from body (negative from, negative to)':{
    source:   'BEFORE {@substring from="-10" to="-3"}The quick brown fox jumped.{/substring} AFTER.'
    context:  {}
    expected: 'BEFORE ox jump AFTER.'
  },
  'can extract substrings from body (negative from, no to)':{
    source:   'BEFORE {@substring from="-11"}The quick brown fox jumped.{/substring} AFTER.'
    context:  {}
    expected: 'BEFORE fox jumped. AFTER.'
  },
  'can extract substrings from body (no from, negative to)':{
    source:   'BEFORE {@substring to="-10"}The quick brown fox jumped.{/substring} AFTER.'
    context:  {}
    expected: 'BEFORE The quick brown f AFTER.'
  },
  #
  'can extract substrings from body containing variable (with from and to)':{
    source:   'BEFORE {@substring from="4" to="8"}The {adj} {animal} jumped.{/substring} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE quic AFTER.'
  },
  'can extract substrings from body containing variable (with from, no to)':{
    source:   'BEFORE {@substring from="7"}The {adj} {animal} jumped.{/substring} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE ck brown fox jumped. AFTER.'
  },
  'can extract substrings from body containing variable (no from, with to)':{
    source:   'BEFORE {@substring to="17"}The {adj} {animal} jumped.{/substring} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE The quick brown f AFTER.'
  },
  'can extract substrings from body containing variable (negative from, negative to)':{
    source:   'BEFORE {@substring from="-10" to="-3"}The {adj} {animal} jumped.{/substring} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE ox jump AFTER.'
  },
  'can extract substrings from body containing variable (negative from, no to)':{
    source:   'BEFORE {@substring from="-11"}The {adj} {animal} jumped.{/substring} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE fox jumped. AFTER.'
  },
  'can extract substrings from body containing variable (no from, negative to)':{
    source:   'BEFORE {@substring to="-10"}The {adj} {animal} jumped.{/substring} AFTER.'
    context:  {animal:"fox",adj:"quick brown"}
    expected: 'BEFORE The quick brown f AFTER.'
  }
}).run_tests_on dust

new DustTestSuite("@trim helper", {
  'can trim leading and trailing newlines and tabs within values':{
    source:   "BEFORE {@trim}\t\n{text}\n\t{/trim} AFTER."
    context:  { text:"\n\twithin the helper\t "},
    expected:  'BEFORE within the helper AFTER.'
  }
}).run_tests_on dust

new DustTestSuite("@index helper", {
  'yields a one-based index value ({@index/} case)':{
    source:   '{#foo}{.} is index number {@index/}{@sep}; {/sep}{/foo}.',
    context:  {foo:['A','B','C','D']},
    expected: "A is index number 1; B is index number 2; C is index number 3; D is index number 4."
  }
  'yields a one-based index value ({@index}{.}{/index} case)':{
    source:   '{#foo}{.} is {@index}index number {.}{/index}{@sep}; {/sep}{/foo}.',
    context:  {foo:['A','B','C','D']},
    expected: "A is index number 1; B is index number 2; C is index number 3; D is index number 4."
  }
  'does nothing outside of a list ({@index}{.}{/index} case)':{
    source:   '{@index}index number {.}{/index}',
    context:  {foo:['A','B','C','D']},
    expected: "index number "
  }
  'does nothing outside of a list ({@index/} case)':{
    source:   'index number {@index/}',
    context:  {foo:['A','B','C','D']},
    expected: "index number "
  }
}).run_tests_on dust

new DustTestSuite("@regexp helper", {
  'multiple matches/global':{
    source:   '{@regexp string="{links}" pattern="(https://[^\s\n]+)" flags="g"}{#$}{.}{~n}{/$}{:else}The regexp did not match anything.{/regexp}',
    context:  {links:"Some text. https://foo.bar.com/\nhttp://foo.bar.com/\nhttps://foo.bar.com/path\n"},
    expected: "https://foo.bar.com/\nhttps://foo.bar.com/path\n"
  }
  'no matches/global':{
    source:   '{@regexp string="{links}" pattern="(https://[^\s\n]+)" flags="g"}{#$}{.}{~n}{/$}{:else}The regexp did not match anything.{/regexp}',
    context:  {links:"Some text. http://foo.bar.com/\nhttp://foo.bar.com/\nhttp://foo.bar.com/path\n"},
    expected: "The regexp did not match anything."
  }
  'basic':{
    source:   '{@regexp string="https://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^(https://[^\.]+\.atlassian\.net\/)"}{$[1]}{key}{/regexp}',
    context:  {key:'ALFA-4'},
    expected: "https://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'dust var in string':{
    source:   '{@regexp string="https://{host}.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^(https://[^\.]+\.atlassian\.net\/)"}{$[1]}{key}{/regexp}',
    context:  {key:'ALFA-4',host:"acmewidgetcorp"},
    expected: "https://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'dust var as string':{
    source:   '{@regexp string=url pattern="^(https://[^\.]+\.atlassian\.net\/)"}{$[1]}{key}{/regexp}',
    context:  {key:'ALFA-4',url:"https://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002"},
    expected: "https://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'dust var in pattern':{
    source:   '{@regexp string="https://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^({protocol}://[^\.]+\.atlassian\.net\/)"}{$[1]}{key}{/regexp}',
    context:  {key:'ALFA-4',protocol:'https'},
    expected: "https://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'dust var as pattern':{
    source:   '{@regexp string="https://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern=pat}{$[1]}{key}{/regexp}',
    context:  {key:'ALFA-4',pat:"^(https://[^\.]+\.atlassian\.net\/)"},
    expected: "https://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'no match':{
    source:   '{@regexp string="xyzzy" pattern="^(https://[^\.]+\.atlassian\.net\/)"}{$[1]}{key}{:else}NO MATCH!{/regexp}',
    context:  {key:'ALFA-4'},
    expected: "NO MATCH!"
  }
  'rename match var':{
    source:   '{@regexp string="https://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^(https://[^\.]+\.atlassian\.net\/)" var="M"}{$M[1]}{key}{/regexp}',
    context:  {key:'ALFA-4'},
    expected: "https://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'with flags':{
    source:   '{@regexp string="hTTps://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^(HTTPS://[^\.]+\.ATLASSIAN\.NET\/)" var="M" flags="i"}{$M[1]}{key}{/regexp}',
    context:  {key:'ALFA-4'},
    expected: "hTTps://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'dust var in flags':{
    source:   '{@regexp string="hTTps://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^(HTTPS://[^\.]+\.ATLASSIAN\.NET\/)" var="M" flags="{f}"}{$M[1]}{key}{/regexp}',
    context:  {key:'ALFA-4',f:"i"},
    expected: "hTTps://acmewidgetcorp.atlassian.net/ALFA-4"
  }
  'dust var as flags':{
    source:   '{@regexp string="hTTps://acmewidgetcorp.atlassian.net/rest/api/2/issue/10003/comment/10002" pattern="^(HTTPS://[^\.]+\.ATLASSIAN\.NET\/)" var="M" flags=f}{$M[1]}{key}{/regexp}',
    context:  {key:'ALFA-4',f:"i"},
    expected: "hTTps://acmewidgetcorp.atlassian.net/ALFA-4"
  }
}).run_tests_on dust

new DustTestSuite("@deorphan helper", {
  'can add &nbsp; between the last two words in the body (single line)':{
    source:"{@deorphan}The quick brown fox {verb} over the lazy dogs.{/deorphan}"
    context:  {verb:'jumped'},
    expected: "The quick brown fox jumped over the lazy&nbsp;dogs."
  },
  'can add &nbsp; between the last two words in the body (multi-space)':{
    source:"{@deorphan}The quick brown fox {verb} over the lazy      dogs.{/deorphan}"
    context:  {verb:'jumped'},
    expected: "The quick brown fox jumped over the lazy&nbsp;dogs."
  },
  'can add &nbsp; between the last two words in the body (trailing-space)':{
    source:"{@deorphan}The quick brown fox {verb} over the lazy dogs.   {/deorphan}"
    context:  {verb:'jumped'},
    expected: "The quick brown fox jumped over the lazy&nbsp;dogs.   "
  },
  'can add &nbsp; between the last two words in the body (multi-line)':{
    source:"{@deorphan}The quick{~n}brown{~n}fox {verb} over the lazy dogs.{~n}{/deorphan}"
    context:  {verb:'jumped'},
    expected: "The quick\nbrown\nfox jumped over the lazy&nbsp;dogs.\n"
  }
  'can add &nbsp; between the last two words in the body (multi-line, multi-space)':{
    source:"{@deorphan}The\tquick{~n}brown{~n}fox {verb} over the lazy {~n}\tdogs.{~n}{/deorphan}"
    context:  {verb:'jumped'},
    expected: "The\tquick\nbrown\nfox jumped over the lazy&nbsp;dogs.\n"
  }
}).run_tests_on dust

new DustTestSuite("@filter helper", {
  '@filter type=uc':{
    source:   'before|{@filter type="uc"}Foo Bar{/filter}|after',
    context:  {},
    expected: 'before|Foo%20Bar|after'
  }
}).run_tests_on dust

new DustTestSuite("@if helper",{
  '@if value=true':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: true },
    expected: 'before|YES|after'
  }
  '@if value=1':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: 1 },
    expected: 'before|YES|after'
  }
  '@if value=T':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: "T" },
    expected: 'before|YES|after'
  }
  '@if value=Y':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: "Y" },
    expected: 'before|YES|after'
  }
  '@if value=0':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: 0 },
    expected: 'before|NO|after'
  }
  '@if value=2':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: 2 },
    expected: 'before|YES|after'
  }
  '@if value=\"0\"':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: "0" },
    expected: 'before|NO|after'
  }
  '@if value=null':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: null },
    expected: 'before|NO|after'
  }
  '@if value=[]':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: [] },
    expected: 'before|NO|after'
  }
  '@if value={}':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: {} },
    expected: 'before|NO|after'
  }
  '@if value=[1]':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: [1] },
    expected: 'before|YES|after'
  }
  '@if value={bar:1}':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: {bar:1} },
    expected: 'before|YES|after'
  }
  '@if value=undefined':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { },
    expected: 'before|NO|after'
  }
  '@if value=N':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x:"N" },
    expected: 'before|NO|after'
  }
  '@if value=No':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x:"No" },
    expected: 'before|NO|after'
  }
  '@if value=F':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x:"F" },
    expected: 'before|NO|after'
  }
  '@if value=false':{
    source:   'before|{@if value=x}YES{:else}NO{/if}|after',
    context:  { x: false },
    expected: 'before|NO|after'
  }
  '@if value="true"':{
    source:   'before|{@if value="true"}YES{:else}NO{/if}|after',
    context:  {  },
    expected: 'before|YES|after'
  }
  '@if value="false"':{
    source:   'before|{@if value="false"}YES{:else}NO{/if}|after',
    expected: 'before|NO|after'
  }
  '@if value=X matches="Y" (true case)':{
    source:   'before|{@if value=x matches="oo"}YES{:else}NO{/if}|after',
    context:  { x: "foo" },
    expected: 'before|YES|after'
  }
  '@if value=X matches="Y" (false case)':{
    source:   'before|{@if value=x matches="^oo"}YES{:else}NO{/if}|after',
    context:  { x: "foo" },
    expected: 'before|NO|after'
  }
  '@if value=X is="Y" (true case)':{
    source:   'before|{@if value=x is="foo"}YES{:else}NO{/if}|after',
    context:  { x: "foo" },
    expected: 'before|YES|after'
  }
  '@if value=X is=Y (true case)':{
    source:   'before|{@if value=x is=y}YES{:else}NO{/if}|after',
    context:  { x: "foo", y:"foo" },
    expected: 'before|YES|after'
  }
  '@if value=X is=Y (true case)':{
    source:   'before|{@if value=x is=x}YES{:else}NO{/if}|after',
    context:  { x: "foo" },
    expected: 'before|YES|after'
  }
  '@if count-of=X is=Y (true case)':{
    source:   'before|{@if count-of=x is=y}YES{:else}NO{/if}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|YES|after'
  }
  '@if count-of=X isnt=Y (true case)':{
    source:   'before|{@if count-of=x isnt=y}YES{:else}NO{/if}|after',
    context:  { x: [1,2,3], y:2 },
    expected: 'before|YES|after'
  }
  '@if count-of=X isnt=Y (false case)':{
    source:   'before|{@if count-of=x isnt=y}NOT Y{:else}Y{/if}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|Y|after'
  }
  '@if count_of=X above=Y (true case)':{
    source:   'before|{@if count_of=x above=y}YES{:else}NO{/if}|after',
    context:  { x: [1,2,3], y:2 },
    expected: 'before|YES|after'
  }
  '@if count_of=X above="Y" (true case)':{
    source:   'before|{@if count_of=x above="2"}YES{:else}NO{/if}|after',
    context:  { x: [1,2,3], y:2 },
    expected: 'before|YES|after'
  }
  '@if count_of=X above=Y (false case)':{
    source:   'before|{@if count_of=x above=y}YES{:else}NO{/if}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|NO|after'
  }
  '@if count_of=X above="Y" (false case)':{
    source:   'before|{@if count_of=x above="3"}YES{:else}NO{/if}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|NO|after'
  }
}).run_tests_on dust

new DustTestSuite("@unless helper",{
  '@unless value=true':{
    source:   'before|{@unless value=x}YES{:else}NO{/unless}|after',
    context:  { x: true },
    expected: 'before|NO|after'
  }
  '@unless value=false':{
    source:   'before|{@unless value=x}YES{:else}NO{/unless}|after',
    context:  { x: false },
    expected: 'before|YES|after'
  }
  '@unless value="true"':{
    source:   'before|{@unless value="true"}YES{:else}NO{/unless}|after',
    context:  {  },
    expected: 'before|NO|after'
  }
  '@unless value="false"':{
    source:   'before|{@unless value="false"}YES{:else}NO{/unless}|after',
    expected: 'before|YES|after'
  }
  '@unless value=X matches="Y" (true case)':{
    source:   'before|{@unless value=x matches="oo"}YES{:else}NO{/unless}|after',
    context:  { x: "foo" },
    expected: 'before|NO|after'
  }

  '@unless value=X matches="Y" (false case)':{
    source:   'before|{@unless value=x matches="^oo"}YES{:else}NO{/unless}|after',
    context:  { x: "foo" },
    expected: 'before|YES|after'
  }
  '@unless value=X is="Y" (true case)':{
    source:   'before|{@unless value=x is="foo"}YES{:else}NO{/unless}|after',
    context:  { x: "foo" },
    expected: 'before|NO|after'
  }
  '@unless value=X is=Y (true case)':{
    source:   'before|{@unless value=x is=y}YES{:else}NO{/unless}|after',
    context:  { x: "foo", y:"foo" },
    expected: 'before|NO|after'
  }
  '@unless value=X is=Y (true case)':{
    source:   'before|{@unless value=x is=x}YES{:else}NO{/unless}|after',
    context:  { x: "foo" },
    expected: 'before|NO|after'
  }
  '@unless count-of=X is=Y (true case)':{
    source:   'before|{@unless count-of=x is=y}YES{:else}NO{/unless}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|NO|after'
  }
  '@unless count-of=X isnt=Y (true case)':{
    source:   'before|{@unless count-of=x isnt=y}YES{:else}NO{/unless}|after',
    context:  { x: [1,2,3], y:2 },
    expected: 'before|NO|after'
  }
  '@unless count-of=X isnt=Y (false case)':{
    source:   'before|{@unless count-of=x isnt=y}NOT Y{:else}Y{/unless}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|NOT Y|after'
  }
  '@unless count_of=X above=Y (true case)':{
    source:   'before|{@unless count_of=x above=y}YES{:else}NO{/unless}|after',
    context:  { x: [1,2,3], y:2 },
    expected: 'before|NO|after'
  }
  '@unless count_of=X above="Y" (true case)':{
    source:   'before|{@unless count_of=x above="2"}YES{:else}NO{/unless}|after',
    context:  { x: [1,2,3], y:2 },
    expected: 'before|NO|after'
  }
  '@unless count_of=X above=Y (false case)':{
    source:   'before|{@unless count_of=x above=y}YES{:else}NO{/unless}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|YES|after'
  }
  '@unless count_of=X above="Y" (false case)':{
    source:   'before|{@unless count_of=x above="3"}YES{:else}NO{/unless}|after',
    context:  { x: [1,2,3], y:3 },
    expected: 'before|YES|after'
  }
}).run_tests_on dust

new DustTestSuite("@repeat helper",{
  '@repeat - simple':{
    source:   'before|{@repeat times="4"}X{/repeat}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|XXXX|after'
  }
  '@repeat - with section':{
    source:   'before|{@repeat times="4"}{#list}{.}{@sep},{/sep}{/list}{@sep};{/sep}{/repeat}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|one,two,three,four,five;one,two,three,four,five;one,two,three,four,five;one,two,three,four,five|after'
  }
  '@repeat - using {.}':{
    source:   'before|{@repeat times="4"}{.}{@sep},{/sep}{/repeat}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|0,1,2,3|after'
  }
  '@repeat - nested':{
    source:   'before|{@repeat times="4"}{.}:{@repeat times="3"}{.}{/repeat}{@sep};{/sep}{/repeat}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|0:012;1:012;2:012;3:012|after'
  }
}).run_tests_on dust

new DustTestSuite("@*case helpers",{
  '@upcase':{
    source:   'before|{@upcase}fOo foO-bar BAR{/upcase}|after',
    context:  { },
    expected: 'before|FOO FOO-BAR BAR|after'
  }
  '@UPCASE':{
    source:   'before|{@UPCASE}fOo foO-bar BAR{/UPCASE}|after',
    context:  { },
    expected: 'before|FOO FOO-BAR BAR|after'
  }
  '@downcase':{
    source:   'before|{@downcase}fOo foO-bar BAR{/downcase}|after',
    context:  { },
    expected: 'before|foo foo-bar bar|after'
  }
  '@titlecase':{
    source:   'before|{@titlecase}fOo foO-bar BAR{/titlecase}|after',
    context:  { },
    expected: 'before|FOo FoO-Bar BAR|after'
  }
  '@titlecase(@downcase)':{
    source:   'before|{@titlecase}{@downcase}fOo foO-bar BAR{/downcase}{/titlecase}|after',
    context:  { },
    expected: 'before|Foo Foo-Bar Bar|after'
  }
}).run_tests_on dust

# @count
new DustTestSuite("@count helper",{
  '@count':{
    source:   'before|{@count of=list/}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|5|after'
  }
}).run_tests_on dust

# @first, @last, @even, @odd
new DustTestSuite("positional helpers",{
  '@first':{
    source:   'before|{#list}{@first}FIRST!{:else} {.} is not first.{/first}{/list}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|FIRST! two is not first. three is not first. four is not first. five is not first.|after'
  },
  '@last':{
    source:   'before|{#list}{@last}LAST!{:else}{.} is not last. {/last}{/list}|after',
    context:  { list: ['one','two','three','four','five'] },
    expected: 'before|one is not last. two is not last. three is not last. four is not last. LAST!|after'
  },
  '@odd':{
    source:   'before|{#list}{@odd}ODD! {:else}{.} is not odd. {/odd}{/list}|after',
    context:  { list: ['zero','one','two','three','four'] },
    expected: 'before|zero is not odd. ODD! two is not odd. ODD! four is not odd. |after'
  },
  '@even':{
    source:   'before|{#list}{@even}EVEN! {:else}{.} is not even. {/even}{/list}|after',
    context:  { list: ['zero','one','two','three','four'] },
    expected: 'before|EVEN! one is not even. EVEN! three is not even. EVEN! |after'
  },
}).run_tests_on dust
