DependsOnFooInfo = provider()

def fail_build(ctx, error_msg, id):
    out = ctx.actions.declare_file(
        ctx.label.name + "_" + id,
    )
    ctx.actions.run_shell(
        outputs = [out],
        arguments = [out.path],
        command = 'echo "{error_msg}" > $1; >2& echo "ERROR {target}: {error_msg}"; exit 1'.format(
            target = str(ctx.label),
            error_msg = error_msg,
        ),
    )
    return [
        OutputGroupInfo(
            _validation = depset(direct = [out]),
        ),
    ]

def _validate_test_size_impl(target, ctx):
    if not (
        any([
            DependsOnFooInfo in dep
            for dep in getattr(ctx.rule.attr, "deps", [])
        ]) or
        str(ctx.label) == ctx.attr._watched_dep
    ):
        return []  # nothing to do

    return (
        [
            DependsOnFooInfo(),
        ] + (
            fail_build(ctx, "Test size too small", "wrong_size.txt") if (
                ctx.rule.kind == "cc_test" and
                not getattr(ctx.rule.attr, "size") in ["large", "enormous"]
            ) else []
        )
    )

validate_test_size = aspect(
    implementation = _validate_test_size_impl,
    attrs = {
        "_watched_dep": attr.string(
            default = "@@//aspects:foo",
        ),
    },
    attr_aspects = ["deps"],
)
