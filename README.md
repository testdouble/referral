# Referral 🔍

Referral is a CLI to help you undertake complex analyses and refactorings of
Ruby codebases. It finds, filters, and sorts the definitions & references of
most types of Ruby identifiers (e.g. classes, methods, and variables) throughout
your code.

Think of `referral` as a toolkit for tracking down references in your code for
any number of purposes, offering a boatload of command-line options to
enable you to efficiently accomplish things like:

* Size up a codebase by gathering basic statistics and spotting usage hotspots
* Build a to-do list to help you manage a large or complex refactor
* Quickly make a list of every call to a deprecated method, rather than wait for
  warnings at runtime
* Get a sense for how many callers would be impacted if you were to delete a method
* Before renaming a module, verify there aren't already any other modules with
  the new name
* Verify that you removed every reference to a deleted class before you merge
* Identify dead code, like method definitions that aren't invoked anywhere
* Catch references that haven't been updated since a change that affected them
  (according to `git-blame`)

Because Referral is powered by the introspection made possible by Ruby 2.6's
[RubyVM::AbstractSyntaxTree](https://ruby-doc.org/core-2.6.3/RubyVM/AbstractSyntaxTree.html)
API, it must be run with Ruby 2.6 or later. Nevertheless, it can often analyze
code _listings_ designed to run on older Rubies.

## Install

From the command line:

```
$ gem install referral
```

Or in your `Gemfile`

```ruby
gem "referral", require: false, group: :development
```

## How to use Referral

### Basic usage

At its most basic, you can just run `referral` and it'll scan `**/*.rb` from the
current working directory and print every reference it finds:

```
$ referral
app/channels/application_cable/channel.rb:1:0: module  ApplicationCable
app/channels/application_cable/channel.rb:2:2: class ApplicationCable Channel
app/channels/application_cable/channel.rb:2:18: constant ApplicationCable::Channel ActionCable::Channel::Base
# … and then another 2400 lines (which you can easily count with `referral | wc -l`)
```

By default, Referral will sort entries by file, line, and column. Default output
is broken into 4 columns: `location`, `type`, `scope`, and `name`.

If you'd like to scan a subset of files, you can pass a final argument with file
paths and directories. For example, if you only wanted to search code in the
top-level of `app/lib` you could run `referral app/lib/*.rb`. Or, if you wanted
to include subdirectories, `referral app/lib`.

Everything above can be custom-tailored to your purposes, so let's work through
some example recipes to teach you Referral's various features below. (Or, feel
free to skip to the [full list of
options](https://github.com/testdouble/referral#options)).

### Recipe: build a refactoring to-do spreadsheet

When I'm undergoing a large refactor, I like to start by grepping around for all
the obvious definitions and references that might be affected. Suppose I'm going
to make major changes to my `User` class. I might use Referral's `--exact-name`
filter like this:

```
referral --exact-name User,user,@user,@current_user
```

[**Fun fact:** if I'd have wanted to match on partial names, I could have used the looser
`--name`, or for fully-qualified names (e.g. `API::User`), the stricter
`--full-name` option.]

Next, I usually find it easiest to work through a large refactor file-by-file,
but in certain cases where I'm looking for a specific type of reference, it
makes more sense to sort by the fully-qualified scope, which can be done with
`--sort scope`:

```
referral --exact-name User,user,@user,@current_user --sort scope
```

The above will sort results by their fully-qualified names (e.g. `A::B#c`),
rather than their filenames.

Of course, if we want a checklist, the default output could be made a lot nicer
for export to a spreadsheet app like [Numbers](https://www.apple.com/numbers/).
Here's how you might invoke `referral` to save a tab-separated-values (TSV)
file:

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

And you'll be greeted by a spreadsheet. And hey, why not throw a checkbox column
on there while you're at it:

<img width="1272" alt="Screen Shot 2019-06-27 at 1 27 42 PM" src="https://user-images.githubusercontent.com/79303/60287234-64560a00-98df-11e9-9fed-46c68fdaac58.png">

> It is important to note that Numbers, like earlier versions of Excel, uses an unsigned Integer for row numbering that limits the number of shown rows to ~65,000. On larger codebases, referral may create more references than this. LibreOffice and newer versions of Excel do not have this limitation on viewing.

### Recipe: detect references you forgot to update

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

[**Warning:** running `git-blame` on each file is, of course, a bit slow. Running
this command on the [KameSame](https://www.kamesame.com/) codebase took 3 seconds of
wall-time, compared to 0.7 seconds by default.]

And it gets better! Since we're already running `blame`, why not sort every line
by its most and least recent commit time? You can! To list the
least-recently-changed references first, add the option `--sort
least_recent_commit`:

```
referral --sort least_recent_commit --column file,line,git_sha,git_author,git_commit_at,full_name
```

In my case, I see that my least-recently-updated Ruby reference is:

```
app/channels/application_cable/channel.rb 1  searls@gmail.com 2017-08-20T14:59:35Z ApplicationCable
```

The inclusion of `git-blame` fields and sorting can be a powerful tool to
spot-check a large refactor before deciding to merge it in.

### Recipe: search for a regex pattern and print the source

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

In my results, I learned that as recently as June 6th, I wrote a very
long method definition:

```
app/lib/presents_review_result.rb:60:2: 2019-06-02T02:38:01Z   def item_result(study_card_identifier, user, answer, item, learning, judgment, reward)
```

`find` couldn't have told me that (I don't think)!

### Recipe:  Find calls that have more than 1 argument

[Recently I was upgrading the i18n gem](http://blog.testdouble.com/posts/2019-10-15-lets-hash-this-out/) and came across some bugs introduced by [this change](https://github.com/ruby-i18n/i18n/commit/5eeaad7fb35f9a30f654e3bdeb6933daa7fd421d#diff-14d9864ac07456d554843dc2a3b174a4L179). To fix the issue, I started looking at all the places `I18n.t` was called from:

```
referral --type call --exact-name I18n.t -c location,source
```

Unfortunately, this produces 250+ false positives because the predominant usage was to pass a single argument to `t`. Only calls with more than 1 argument are affected by this change. `--pattern` doesn't work very well in this codebase, because calls to `t` with multiple arguments are more likely to be multiline.

```
referral --type call --exact-name I18n.t --arity 2+ -c location,source,arity
```

This produced 27 results I could quickly skim through.


## Options

Referral provides a lot of options. The help output of `referral --help` will
print out the available options and their defaults:

```
Usage: referral [options] files
    -v, --version                    Prints the version
    -h, --help                       Prints this help
    -n, --name [NAME]                Partial or complete name(s) to filter
        --exact-name [NAME]          Exact name(s) to filter
        --full-name [NAME]           Exact, fully-qualified name(s) to filter
        --scope [SCOPE]              Scope(s) in which to filter (e.g. Hastack#hide)
    -p, --pattern [PATTERN]          Regex pattern to filter
    -t, --type [TYPES]               Include only certain types. See Referral::TOKEN_TYPES.
        --arity [ARITY]              Number of arguments to a method call.  (e.g. 2+)
        --include-unnamed            Include reference without identifiers (default: false)
    -s, --sort {file,scope}          (default: file). See Referral::SORT_FUNCTIONS
        --print-headers              Print header names (default: false)
    -c, --columns [COL1,COL2,COL3]   (default: location,type,scope,name). See Referral::COLUMN_FUNCTIONS
    -d, --delimiter [DELIM]          String separating columns (default: ' ')
```

A few things to note:

* Each of `--name`, `--exact-name`, `--full-name`, `--scope`, `--type`, and `--columns`
  accept comma-separated arrays (e.g. `--name foo,bar,baz`)

* `--arity` accepts a number with an optional `+` or `-`.
  *  `--arity 0`  Match calls with 0 arguments
  *  `--arity 1+` Match calls with 1 or more arguments
  *  `--arity 1-` Match calls with 1 or fewer arguments

* You can browse available sort functions [in
  Referral::SORT_FUNCTIONS](/lib/referral/sorts_tokens.rb) for use with
  `--sort`. Each key is the name to be specified on the command line. (If you're
  feeling adventurous, we've left the hash unfrozen so you can define your own
  custom sorts dynamically, but YMMV.)

* Just like sort functions, you can find the available column types [in
  Referral::COLUMN_FUNCTIONS](/lib/referral/prints_results.rb) when passing a
  comma-separated list to `--column`. (This hash has
  also been left mutable for you, dear user.)

* The types of AST nodes that Referral supports can be found [in
  Referral::TOKEN_TYPES](/lib/referral/token_types.rb) when filtering to
  certain definition & reference types with `--type`

* Note that the columns `git_sha`, `git_author`, `git_commit_at` and the sort
  functions `most_recent_commit` and `least_recent_commit` will slow things down
  a bit, by invoking `git-blame` for each file included in the filtered
  results

* The `source` column and `--pattern` options will read each file in
  the result set twice: once when parsing the AST, and again when printing
  results

## Running with Ruby version managers

Referral requires Ruby version >= 2.6, but your codebase may be running on something
older.  You have a few options for using `referral`.  You could 1) change your project's
ruby while you run `referral` and then change it back, but this seems cumbersome and
likely to cause annoyance.  There are better ways.

## Run from outside your project's working directory

If you `cd ..` from your project's working directory (assuming in that context
you are running Ruby 2.6.x), you can run `referral` commands on your codebase by passing
the path to that codebase to referral:

```
$ referral MyAwesomeProject/
```

This works for many of `referrals` features, but isn't ideal when it comes to git;
columns like `git_sha`, `git_author` or `git_commit_at` will show empty results.

## Running with `rbenv`

If you're using `rbenv`, you _could_ temporarily switch your project's ruby to 2.6.x,
but you'd have to remember to switch it back again before running any of the code in
the project.  To instantaneously switch to 2.6 and then back again (after the `referral`
command finishes), do this (from your `MyAwsomeProject` directory):

```
$ RBENV_VERSION=2.6.3 referral
```

## Running with RVM

The corresponding way to do this with `rvm` would be:

```
$ rvm 2.6.3 do referral
```

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
