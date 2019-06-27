# referral

Referral is a CLI toolkit for helping you undertake complex analysis and
refactoring of Ruby codebases. It finds, filters, and sorts the definitions & references of most of the
identifiers (e.g. classes, methods, and variables) throughout your code.

Think of `referral` as a toolkit for tracking down references to the code that
you want to change, offering a number of command-line options to quickly enable
you to do things like:

* Size up a codebase by gathering basic statistics and spotting usage hotspots
* Build a to-do list to help you manage a large or complex refactor
* Get a sense for how many callers would be impacted if you deleted a method
* Before renaming a module, verify there aren't any already other modules with
  the new name
* Verify that you removed every reference to a deleted class before you merge
* Identify dead code, like method definitions that aren't invoked anywhere
* Catch references that haven't been updated since a change that affected them
  (via `git-blame`)
* Rather than wait for warnings at runtime, quickly make a list of every call to
  deprecated methods

Because Referral is powered by the introspection made possible by Ruby 2.6's
[RubyVM::AbstractSyntaxTree](https://ruby-doc.org/core-2.6.3/RubyVM/AbstractSyntaxTree.html)
API, it requires Ruby 2.6, but can often analyze codebases that target older
Rubies.

## Install

From the command line:

```
$ gem install referral
```

Or in your `Gemfile`

```ruby
gem "referral", require: false, group: :development
```

## Usage

### Basic usage

At its most basic, you can just run `referral` and it'll scan `**/*.rb` from the
current working directory and print everything:

```
$ referral
app/channels/application_cable/channel.rb:1:0: module  ApplicationCable
app/channels/application_cable/channel.rb:2:2: class ApplicationCable Channel
app/channels/application_cable/channel.rb:2:18: constant ApplicationCable::Channel ActionCable::Channel::Base
# … and then another 2400 lines (which you can easily count with `referral | wc -l`)
```

By default, Referral will sort entries by file, line, and column. Default output
is broken into 4 columns: `location`, `type`, `scope`, and `name`.

Everything above can be custom-tailored to your purposes, so let's work through
some examples below.

### Build a refactoring to-do spreadsheet

When I'm undergoing a large refactor, I like to start by grepping around for all
the obvious definitions and references that might be affected. Suppose I'm
going to make major changes to my `User` class, I might search with the
`--exact-name` filter like this:

```
referral --exact-name User,user,@user,@current_user
```

[Fun fact: if I'd have wanted to match on partial names, I could have used the looser
`--name`, or for fully-qualified names (e.g. `API::User`), the stricter
`--full-name` option.]

Next, I usually find it easiest to work through a large refactor file-by-file,
but in certain cases where I'm looking for a specific type of reference, it
makes more sense to sort by the fully-qualified scope, which can be done with
`--sort scope`:

```
referral --exact-name User,user,@user,@current_user --sort scope
```

Of course, if we want a checklist, the default output could be made a lot nicer
for export to a spreadsheet app like [Numbers](https://www.apple.com/numbers/).

Here's what that might look like:

```
referral --exact-name User,user,@user,@current_user --sort scope --print-headers --delimiter "\t" > user_refs.tsv
```

Where `--print-headers` prints an initial row of the selected column names, and `--delimiter
"\t"` separates each field by a tab (making it easier to ingest for a
spreadsheet app like Excel or Numbers), before being redirected to the file
`user_refs.tsv`.

Now, to open it in Numbers, I'd run:

```
open -a Numbers user_refs.tsv
```

And be immediately greeted by a spreadsheet. Heck, why not throw a checkbox on
there while we're at it:

<img width="1272" alt="Screen Shot 2019-06-27 at 1 27 42 PM" src="https://user-images.githubusercontent.com/79303/60287234-64560a00-98df-11e9-9fed-46c68fdaac58.png">

### Detect references you forgot to update

When working in a large codebase, it can be really tough to figure out if you
remembered to update every reference to a class or method across thousands of
files, so Referral ships with the ability to get some basic information from
`git-blame`, like this:

```
referral --column file,line,git_sha,git_author,git_commit_at,full_name
```

By setting `--column` to a comma-separated array that includes the above,
Referral will print results that look like these:

```
test/lib/splits_furigana_test.rb 56 634edc04 searls@gmail.com 2017-09-04T13:34:09Z SplitsFuriganaTest#test_nasty_edge_cases.assert_equal
test/lib/splits_furigana_test.rb 56 634edc04 searls@gmail.com 2017-09-04T13:34:09Z h
test/lib/splits_furigana_test.rb 56 634edc04 searls@gmail.com 2017-09-04T13:34:09Z @subject.call
```

[Warning: running `git-blame` on each file is, of course, a bit slow. Running
this command on the [KameSame](https://kamesame.com) codebase took 3 seconds of
wall-time, compared to 0.7 seconds by default.]

And it gets better! Since we're already running blame, why not sort every line
by its most and least recent commit time?!

You can see your least-recently updated references first by adding `--sort
least_recent_commit`, which does just what it says on the tin:

```
referral --column file,line,git_sha,git_author,git_commit_at,full_name --sort least_recent_commit
```

And I'll see that my least-recently-updated Ruby reference is:

```
app/channels/application_cable/channel.rb 1  searls@gmail.com 2017-08-20T14:59:35Z ApplicationCable
```

The inclusion of `git-blame` fields and sorting can be a powerful tool to
spot-check a large refactor before deciding to merge it in.

### Search for a regex pattern and print the source

Once in a while, I'll want to scan line-by-line in a codebase for lines that
match a given pattern, and in those cases, the `--pattern` option and `source`
column can be a big help.

Suppose I'm trying to size up a codebase by looking for how many methods appear
to have a lot of arguments. While _definitely imperfect and regex cannot parse
context-free grammars_, I can get a rough gist by searching for any lines that
have 4 or more commas on them:

```
referral --pattern "/^([^,]*,){4,}[^,]*$/" -c location,source
```

Which would yield results like this one:

```
app/lib/card.rb:22:2:   def self.from_everything(id:, lesson_type:, item:, assignment:, meaning:)
```

Naturally, other programs like `find` could do this just as well, but the added
ability to see & sort by when these lines were last updated in git might be
interesting. Additionally, suppose you only wanted to find method _definitions_
with a lot of (apparent) arguments? You could filter the matches down with
`--type instance_method,class_method`, too, like this:

```
referral --pattern "/^([^,]*,){4,}[^,]*$/" -c location,git_commit_at,source -s most_recent_commit --type instance_method,class_method
```

And I can see that as recently as June 6th, I apparently wrote a very long
method definition. `find` can't do that (I think)!

```
app/lib/presents_review_result.rb:60:2: 2019-06-02T02:38:01Z   def item_result(study_card_identifier, user, answer, item, learning, judgment, reward)
```

## Options

The help output of `referral --help` will print out the available options and
defaults:

```
Usage: referral [options] files
    -v, --version                    Prints the version
    -h, --help                       Prints this help
    -n, --name [NAME]                Partial or complete name(s) to filter
        --exact-name [NAME]          Exact name(s) to filter
        --full-name [NAME]           Exact, fully-qualified name(s) to filter
    -p, --pattern [PATTERN]          Regex pattern to filter
    -t, --type [TYPES]              Include only certain types. See Referral::TOKEN_TYPES.
        --include-unnamed            Include reference without identifiers (default: false)
    -s, --sort {file,scope}          (default: file). See Referral::SORT_FUNCTIONS
        --print-headers              Print header names (default: false)
    -c, --columns [COL1,COL2,COL3]   (default: location,type,scope,name). See Referral::COLUMN_FUNCTIONS
    -d, --delimiter [DELIM]          String separating columns (default: ' ')
```

A few things to note:

* Each of `--name`, `--exact-name`, `--full-name`, `--type`, and `--columns`
  accept comma-separated arrays (e.g. `-n foo,bar,baz`)

* You can browse available sort functions [in
  Refferral::SORT_FUNCTIONS](/lib/referral/sorts_tokens.rb) for use with
  `--sort`. Each key is the name to be specified on the command line. (If you're
  feeling adventurous, we've left the hash unfrozen so you can define your own
  custom sorts dynamically, but YMMV.)

* Just like sort functions, you can find the available column types [in
  Refferral::COLUMN_FUNCTIONS](/lib/referral/prints_results.rb) when passing a
  comma-separated list to `--column`. (This hash has
  also been left mutable for you, dear user.)

* The types of AST nodes that Referral supports can be found [in
  Refferral::TOKEN_TYPES](/lib/referral/token_types.rb) when filtering to
  certain `--type`

* Note that the columns `git_sha`, `git_author`, `git_commit_at` and the sort
  functions `most_recent_commit` and `least_recent_commit` will incur a
  `git-blame` invocation for each file counted among the filtered results

* Note that the `source` column and `--pattern` options will read each file in
  the result set twice: once when parsing the AST, and again when printing
  results

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
