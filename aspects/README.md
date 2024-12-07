# Aspects

This package shows how to use aspects to validate certain properties.
It shows how to enforce a certain test size if a cc_test target depends
on a specific target.

Try this out by building all targets in the package with

```shell
bazel build //aspects/... --aspects=//aspects/rules:validate_test_size.bzl%validate_test_size
```

The target `test_without_size` will fail to build since it depends
on `//aspects:foo`, but has not set the size to `large` or `enormous`.

Features used in this example:

* [Aspects](https://bazel.build/extending/aspects)
* [Validation actions](https://bazel.build/extending/rules#validation_actions)

## Implementation

Every target that depends on '//aspects:foo' will provide the
`DependsOnFooInfo` provider. On every `cc_test` target, this
provider is checked on every `deps`. If present, the `size` attribute
is verified. If not set appropriately, a failing validation action is
created. That is an action with an output returned as the 'magic'
output group `_validation`. This is always built, no matter if
requested on the command line.


