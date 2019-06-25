# referral

Find, filter, and sort your codes' references to Ruby identifiers like classes,
modules, constants, and methods. Powered by Ruby 2.6's
[RubyVM::AbstractSyntaxTree](https://ruby-doc.org/core-2.6.3/RubyVM/AbstractSyntaxTree.html)
API.


## stick it in a spreadsheet

```
referral -d "\t" test/fixture/a/* > foo.tsv && open -a Numbers foo.tsv
```

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
