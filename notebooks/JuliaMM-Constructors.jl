### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 64a64a5a-8583-11eb-13d8-8d1457d4b117
using Pkg

# ╔═╡ d8984d92-7e8e-11eb-0d68-255375344426
begin
using  MixedModels
import PlutoUI: TableOfContents
import FreqTables: freqtable
import DataFrames: DataFrame
import DisplayAs: Text
import StatsBase: StatisticalModel
import StatsModels: term, describe
import BenchmarkTools: @benchmark, @benchmarkable
end

# ╔═╡ d9911824-857c-11eb-2cc0-db48cedbff76
TableOfContents()

# ╔═╡ 6ab41af8-8583-11eb-3bcc-3fc03804e84f
Pkg.status()

# ╔═╡ 69180010-7e53-11eb-1afb-4b7d6609ca97
md"""
### Modules Used
"""

# ╔═╡ 535aacb2-7e64-11eb-3781-7911423c8734
md"""
# Model Constructers
"""

# ╔═╡ 6cf58296-7e64-11eb-354f-b31e0fedf5ac
md"""
The `LinearMixedModel` type represents a linear mixed-effects model.
Typically it is constructed from a `Formula` and an appropriate `Table` type, usually a `DataFrame`.
"""

# ╔═╡ 42399604-7e17-11eb-019f-a3612db180c9
# @doc MixedModel

# ╔═╡ 4c6921b0-7e17-11eb-0c3b-4fd483bf4024
# @doc LinearMixedModel

# ╔═╡ 5fd7dc9e-7e64-11eb-0e42-7b28e4c890f2
md"""
## Examples of linear mixed-effects model fits
"""

# ╔═╡ ae61fd9c-7e64-11eb-20e5-839180dd1243
md"""
For illustration, several data sets from the *lme4* package for *R* are made available in `.arrow` format in this package. Often, for convenience, we will convert these to `DataFrame`s.
"""

# ╔═╡ db678696-7e70-11eb-1489-f56c4f344bb4
# Resource("https://arrow.apache.org/img/simd.png") # Arrow data format

# ╔═╡ ddd14974-7963-11eb-0b4f-5bd61b00331e
# MixedModels.datasets()

# ╔═╡ 94381cdc-7e6f-11eb-1334-035df5150bf3
dyestuff = MixedModels.dataset(:dyestuff) |> DataFrame;

# ╔═╡ 3c0bb720-7e93-11eb-214d-994cdc42b9b0
# freqtable(dyestuff, :batch).array

# ╔═╡ ac77b92a-7e64-11eb-067d-715baea6c450
md"""
### The `@formula` language in Julia
"""

# ╔═╡ d9c8be96-7e6f-11eb-0b19-13e583f75e19
md"""
MixedModels.jl builds on the the *Julia* formula language provided by [StatsModels.jl](https://juliastats.org/StatsModels.jl/stable/formula/), which is similar to the formula language in *R* and is also based on the notation from Wilkinson and Rogers ([1973](https://dx.doi.org/10.2307/2346786)). There are two ways to construct a formula in Julia.  The first way is to enclose the formula expression in the `@formula` macro:
"""

# ╔═╡ 7fbd4cf8-7e17-11eb-2bdc-e77bca0ad0a9
# @doc @formula

# ╔═╡ ee42621e-7e6f-11eb-355c-1d224de62501
md"""
The second way is to combine `Term`s with operators like `+`, `&`, `~`, and others at "run time".  This is especially useful if you wish to create a formula from a list a variable names.  For instance, the following are equivalent:
"""

# ╔═╡ f32ae4e0-7e6f-11eb-101a-1da76dc0dc30
# @formula(y ~ 1 + a + b + a & b) == (term(:y) ~ term(1) + term(:a) + term(:b) + term(:a) & term(:b))

# ╔═╡ 4c66fdb4-7e70-11eb-1dac-b7e36bbaef38
md"""
MixedModels.jl provides additional formula syntax for representing *random-effects terms*.  Most importantly, `|` separates random effects and their grouping factors (as in the formula extension used by the *R* package [`lme4`](https://cran.r-project.org/web/packages/lme4/index.html).  Much like with the base formula language, `|` can be used within the `@formula` macro and to construct a formula programmatically:
"""

# ╔═╡ 54eef27a-7e70-11eb-2c8a-3fbcb1266b6e
# @formula(y ~ 1 + a + b + (1 + a + b | g))

# ╔═╡ 5d748ffe-7e70-11eb-01f3-23c6d14045b0
# begin
# 	terms = sum(term(t) for t in [1, :a, :b])
# 	group = term(:g)
# 	response = term(:y)
# 	response ~ terms + (terms | group)
# end

# ╔═╡ 2346e6ee-7e73-11eb-0c7e-19636e41fbac
md"""
### Models with simple, scalar random effects
"""

# ╔═╡ ccbe52a2-7e70-11eb-390f-4d0e695df7da
md"""
A basic model with simple, scalar random effects for the levels of `batch` (the batch of an intermediate product, in this case) is declared and fit as
"""

# ╔═╡ 2bbf68ce-7ffd-11eb-3d64-118573933a5d
# fm = @formula(yield ~ 1 + (1 | batch))

# ╔═╡ 35fa8d28-7ffd-11eb-0e5e-c183a5e43c69
# fm1 = fit(LinearMixedModel, fm, dyestuff)

# ╔═╡ 3f31f56e-7ffd-11eb-28be-65f9011e3690
# Text(fm1)

# ╔═╡ 67be7b40-7e71-11eb-2e0a-a589b720015c
md"""
(If you are new to Julia you may find that this first fit takes an unexpectedly long time, due to Just-In-Time (JIT) compilation of the code. The subsequent calls to such functions are much faster.)
"""

# ╔═╡ 1bd8caec-7e93-11eb-2244-bf6118c02892
# dyestuff2 = MixedModels.dataset(:dyestuff2)

# ╔═╡ 6cec57d6-7e71-11eb-350b-4f3de1b7f968
# @benchmark fit(MixedModel, $fm, $dyestuff2)

# ╔═╡ 0236fabc-7e72-11eb-02eb-41ae0dbae760
md"""
By default, the model is fit by maximum likelihood. To use the `REML` criterion instead, add the optional named argument `REML=true` to the call to `fit`
"""

# ╔═╡ 064fdf6a-7e72-11eb-1f18-2706287ba102
# begin
# fm1reml = fit(MixedModel, fm, dyestuff, REML=true)
# # Text(fm1reml)
# end

# ╔═╡ 396514ec-7e72-11eb-1367-316a5dd6c351
md"""
### Float-point type in the model
The type of `fm1` $(typeof(fm1)) includes the floating point type used internally for the various matrices, vectors, etc. that represent the model.
At present, this will always be `Float64` because the parameter estimates are optimized using the [`NLopt` package](https://github.com/JuliaOpt/NLopt.jl) which calls compiled C code that only allows for optimization with respect to a `Float64` parameter vector.

So in theory other floating point types, such as `BigFloat` or `Float32`, can be used to define a model but in practice only `Float64` works at present.

> In theory, theory and practice are the same.  In practice, they aren't.  -- Anon
"""

# ╔═╡ 1bce190c-7ffc-11eb-1454-63f45dc02d37
md"""
### Simple, scalar random effects

"""

# ╔═╡ 8b2bf6ce-7e72-11eb-3db4-c3600353f30d
md"""

A simple, scalar random effects term in a mixed-effects model formula is of the form `(1|G)`.
All random effects terms end with `|G` where `G` is the *grouping factor* for the random effect.
The name or, more generally, the expression `G` should evaluate to a categorical array that has a distinct set of *levels*.
The random effects are associated with the levels of the grouping factor.

A *scalar* random effect is, as the name implies, one scalar value for each level of the grouping factor.
A *simple, scalar* random effects term is of the form, `(1|G)`.
It corresponds to a shift in the intercept for each level of the grouping factor.
"""

# ╔═╡ 42d2311e-7ffc-11eb-3621-2fc7582c23fc
md"""
### Models with vector-valued random effects

"""

# ╔═╡ fc6c3128-7e72-11eb-3a7c-1bd62a5c2f6e
md"""

The *sleepstudy* data are observations of reaction time, `reaction`, on several subjects, `subj`, after 0 to 9 days of sleep deprivation, `days`.
A model with random intercepts and random slopes for each subject, allowing for within-subject correlation of the slope and intercept, is fit as
"""

# ╔═╡ 1e7a64de-7e90-11eb-0070-ef1d983b24e7
# sleepstudy = MixedModels.dataset(:sleepstudy) |> DataFrame;

# ╔═╡ 9ae57d6c-7e8e-11eb-3a7e-db954a666006
# freqtable(sleepstudy, :subj, :days)

# ╔═╡ 06547e5c-7e73-11eb-1c2c-d748796fada7
# fm2 = fit(MixedModel, @formula(reaction ~ 1 + days + (1 + days|subj)), sleepstudy)

# ╔═╡ 611f7364-7e73-11eb-1a2d-d37d993dff62
md"""
### Models with multiple, scalar random-effects terms
"""

# ╔═╡ cc463a50-7b31-11eb-2038-bf7197b9fd5d
md"""
A model for the *Penicillin* data incorporates random effects for the plate, and for the sample.
As every sample is used on every plate these two factors are *crossed*.
"""

# ╔═╡ 113e8f52-7e90-11eb-3480-afac7386903f
# penicillin = MixedModels.dataset(:penicillin) |> DataFrame

# ╔═╡ 7d93b3b6-7e73-11eb-1fa9-ed6da66a7af2
# freqtable(penicillin, :sample, :plate)

# ╔═╡ 521bfd32-7e8d-11eb-3b73-9790cd6a7bb2
# fm3 = fit(MixedModel, @formula(diameter ~ 1 + (1|plate) + (1|sample)), penicillin)

# ╔═╡ aa2beea6-7b31-11eb-0119-c799285260a6
md"""
In contrast, the `cask` grouping factor is *nested* within the `batch` grouping factor in the *Pastes* data.
"""

# ╔═╡ 083847d8-7e90-11eb-3d6c-4d07414e8a54
# pastes = DataFrame(MixedModels.dataset(:pastes))

# ╔═╡ c099085e-7e8d-11eb-0a86-514802ea7686
# freqtable(pastes, :batch, :cask)

# ╔═╡ bc97f888-7e73-11eb-145b-7370b6193ee6
md"""
This can be expressed using the solidus (the "`/`" character) to separate grouping factors, read "`cask` nested within `batch`":
"""

# ╔═╡ 51d8ac80-7974-11eb-0e96-05669ad474e9
# fm4a = fit(MixedModel, @formula(strength ~ 1 + (1|batch/cask)), pastes)

# ╔═╡ 5ec332d0-7974-11eb-1b69-111abed4e6d7
md"""
If the levels of the inner grouping factor are unique across the levels of the outer grouping factor, then this nesting does not need to expressed explicitly in the model syntax. For example, defining `sample` to be the combination of `batch` and `cask`, yields a naming scheme where the nesting is apparent from the data even if not expressed in the formula. (That is, each level of `sample` occurs in conjunction with only one level of `batch`.) As such, this model is equivalent to the previous one.
"""

# ╔═╡ 308c7f06-7e90-11eb-23b7-f140569bc6ac
# pastes.sample = (string.(pastes.cask, "&",  pastes.batch))

# ╔═╡ 2b19cad8-7e8e-11eb-356b-916076c527b8
# freqtable(pastes, :sample, :cask)

# ╔═╡ d4dde662-7e73-11eb-2880-03e9ea3087e0
# fm4b = fit(MixedModel, @formula(strength ~ 1 + (1|sample) + (1|batch)), pastes)

# ╔═╡ ea8ac676-7e73-11eb-13fa-37075a67711c
md"""
In observational studies it is common to encounter *partially crossed* grouping factors.
For example, the *InstEval* data are course evaluations by students, `s`, of instructors, `d`.
Additional covariates include the academic department, `dept`, in which the course was given and `service`, whether or not it was a service course.
"""

# ╔═╡ f7e658aa-7e8f-11eb-29d2-65ff71902d7a
# insteval = MixedModels.dataset(:insteval) |> DataFrame;

# ╔═╡ 39397a9c-7e90-11eb-3356-af4478c359e9
# describe(insteval)

# ╔═╡ f39e6522-7e73-11eb-0dc1-f5ca3a5a0b5d
# fm5 = fit(MixedModel, @formula(y ~ 1 + service * dept + (1|s) + (1|d)), insteval)

# ╔═╡ c673808c-7b41-11eb-01bb-539963671d25
md"""
### Simplifying the random effect correlation structure
"""

# ╔═╡ 96af6916-7e74-11eb-2257-c7d8b593ca97
md"""
MixedModels.jl estimates not only the *variance* of the effects for each random effect level, but also the *correlation* between the random effects for different predictors.

So, for the model of the *sleepstudy* data above, one of the parameters that is estimated is the correlation between each subject's random intercept (i.e., their baseline reaction time) and slope (i.e., their particular change in reaction time per day of sleep deprivation).

In some cases, you may wish to simplify the random effects structure by removing these correlation parameters.

This often arises when there are many random effects you want to estimate (as is common in psychological experiments with many conditions and covariates), since the number of random effects parameters increases as the square of the number of predictors, making these models difficult to estimate from limited data.
"""

# ╔═╡ d24678b0-7b41-11eb-035d-0f1b1bddb8f3
# begin
# fm2zc1 = fit(MixedModel,
# 	@formula(reaction ~ 1 + days + zerocorr(1 + days|subj)), sleepstudy)
# Text(fm2zc1)
# end

# ╔═╡ bf26a1d4-7e74-11eb-2d27-854b65ede8fd
md"""
Alternatively, correlations between parameters can be removed by including them as separate random effects terms:
"""

# ╔═╡ 7edd9626-7b42-11eb-3206-992a5dbab4ab
# begin
# fm2zc2 = fit(MixedModel, 
# 	@formula(reaction ~ 1 + days + (1|subj) + (days|subj)), sleepstudy)
# Text(fm2zc2)
# end

# ╔═╡ ebca616e-7e74-11eb-313e-a52085549472
md"""
Finally, for predictors that are categorical, MixedModels.jl will estimate correlations between each level.
Notice the large number of correlation parameters if we treat `days` as a categorical variable by giving it contrasts:
"""

# ╔═╡ a7311952-7e91-11eb-2547-0dd95c8326ee
# contra = Dict(:days => DummyCoding())

# ╔═╡ 86deb76a-7b42-11eb-259a-45970009dd5c
# begin
# fm2zc3 = fit(MixedModel, 
# 	@formula(reaction ~ 1 + days + (1 + days|subj)), sleepstudy, contrasts = contra)
# Text(fm2zc3)
# end

# ╔═╡ fec293c0-7e74-11eb-31e3-d7fc8d885738
md"""
Separating the `1` and `days` random effects into separate terms removes the correlations between the intercept and the levels of `days`, but not between the levels themselves:
"""

# ╔═╡ a6753dc4-7b42-11eb-2b7f-2b5b3de28e45
# begin
# fm2zc4 = fit(MixedModel, 
# 	@formula(reaction ~ 1 + days + (1|subj) + (days|subj)), sleepstudy, contrasts = contra)
# Text(fm2zc4)
# end

# ╔═╡ a5b0b160-7e75-11eb-2818-a164714ef5c0
md"""
(Notice that the variance component for `days: 1` is estimated as zero, so the correlations for this component are undefined and expressed as `NaN`, not a number.)

An alternative is to force all the levels of `days` as indicators using `fulldummy` encoding.
"""

# ╔═╡ b3e3de80-7e75-11eb-2b54-3f173617d14b
# @doc fulldummy

# ╔═╡ ab3f87e2-7b42-11eb-308e-95aa681338a0
# begin
# fm2zc5 = fit(MixedModel, 
# 	@formula(reaction ~ 1 + days + (1 + fulldummy(days)|subj)), sleepstudy, contrasts = contra)
# Text(fm2zc5)
# end

# ╔═╡ 377740dc-7e78-11eb-390a-4f1556cba86c
md"""
This fit produces a better fit as measured by the objective (negative twice the log-likelihood is 1610.8) but at the expense of adding many more parameters to the model.
As a result, model comparison criteria such, as `AIC` and `BIC`, are inflated.

But using `zerocorr` on the individual terms does remove the correlations between the levels:
"""

# ╔═╡ 6abff318-7e90-11eb-1124-413f405c7398
# begin
# fm2zcfm = @formula(reaction ~ 1 + days + zerocorr(1 + days|subj))
# fm2zcfm = @formula(reaction ~ 1 + days + (1|subj) + zerocorr(days|subj))
# fm2zcfm = @formula(reaction ~ 1 + days + zerocorr(1 + fulldummy(days)|subj))
# fm2zc6 = fit(MixedModel, fm2zcfm, sleepstudy, contrasts = contr)
# Text(fm2zc6)
# end

# ╔═╡ 2b519f7c-7e92-11eb-3684-b72027369290
md"""
## Fitting generalized linear mixed models
"""

# ╔═╡ 56a66d60-7e92-11eb-340c-f93d4686b046
md"""
To create a GLMM representation the distribution family for the response, and possibly the link function, must be specified.
"""

# ╔═╡ 3e160db4-7e92-11eb-1478-1bd4513e7d77
# @doc GeneralizedLinearMixedModel

# ╔═╡ e6798412-7e93-11eb-0613-49ef92fb1d27
# verbagg = MixedModels.dataset(:verbagg)

# ╔═╡ eb39f748-7e93-11eb-127a-3dd5ad779385
# verbaggform = @formula(r2 ~ 1 + anger + gender + btype + situ + mode + (1|subj) + (1|item))

# ╔═╡ ef1db552-7e93-11eb-1ab9-bb43232047b2
# gm1 = fit(MixedModel, verbaggform, verbagg, Bernoulli())

# ╔═╡ bfe0cfe6-7e92-11eb-36cb-abccf56f0475
md"""
The canonical link, which is `LogitLink` for the `Bernoulli` distribution, is used if no explicit link is specified.

Note that, in keeping with convention in the [`GLM` package](https://github.com/JuliaStats/GLM.jl), the distribution family for a binary (i.e. 0/1) response is the `Bernoulli` distribution.
The `Binomial` distribution is only used when the response is the fraction of trials returning a positive, in which case the number of trials must be specified as the case weights.
"""

# ╔═╡ cdd68b0e-7e92-11eb-0aa9-39fd7916ad69
md"""
### Optional arguments to fit
"""

# ╔═╡ d373e7f0-7e92-11eb-147b-7d870ffa3473
md"""
An alternative approach is to create the `GeneralizedLinearMixedModel` object then call `fit!` on it.
The optional arguments `fast` and/or `nAGQ` can be passed to the optimization process via both `fit` and `fit!` (i.e these optimization settings are not used nor recognized when constructing the model).

As the name implies, `fast=true`, provides a faster but somewhat less accurate fit.
These fits may suffice for model comparisons.
"""

# ╔═╡ c3452b36-7e93-11eb-36fc-c19d1cfa6059
# gm1a = fit(MixedModel, verbaggform, verbagg, Bernoulli(), fast = true);

# ╔═╡ e0e4a956-7e92-11eb-3d12-1f19be9c7d33
# deviance(gm1a) - deviance(gm1)

# ╔═╡ b6a4caee-7e93-11eb-390e-1766d82ac861
# @benchmark fit(MixedModel, $verbaggform, $verbagg, Bernoulli())

# ╔═╡ 0cdb3b50-7e94-11eb-0fca-a9f8fdec0b9d
# @benchmark fit(MixedModel, $verbaggform, $verbagg, Bernoulli(), fast = true)

# ╔═╡ 36167304-7e94-11eb-158b-8bf1af346b78
md"""
The optional argument `nAGQ=k` causes evaluation of the deviance function to use a `k` point
adaptive Gauss-Hermite quadrature rule.
This method only applies to models with a single, simple, scalar random-effects term, such as
"""

# ╔═╡ 4971668e-7e94-11eb-2c42-45cdff449406
# begin
# contraception = MixedModels.dataset(:contra) |> DataFrame
# contraform = @formula(use ~ 1 + age + abs2(age) + livch + urban + (1|dist));
# bernoulli = Bernoulli()
# deviances = Dict{Symbol, Float64}()
# end;

# ╔═╡ 61a71956-7e94-11eb-24c8-c5f50d6b1277
# begin
# b1=@benchmarkable deviances[:default]   = 
#  deviance(fit(MixedModel,$contraform,$contraception,$bernoulli))
# b2=@benchmarkable deviances[:fast] = 
#  deviance(fit(MixedModel,$contraform,$contraception,$bernoulli,fast=true))
# b3=@benchmarkable deviances[:nAGQ] = 
#  deviance(fit(MixedModel,$contraform,$contraception,$bernoulli,nAGQ=9))
# b4=@benchmarkable deviances[:nAGQ_fast] = 
#  deviance(fit(MixedModel,$contraform,$contraception,$bernoulli,nAGQ=9,fast=true))
# [run(x) for x in [b1, b2, b3, b4]]
# end;

# ╔═╡ a19cbf16-7e94-11eb-1863-c1f02a354066
# sort(deviances)

# ╔═╡ f1412e0c-7e95-11eb-2b96-ddb14645c3af
md"""
# Extractor functions
"""

# ╔═╡ fb1ed1c4-7e95-11eb-213c-a33c76f24969
md"""
`LinearMixedModel` and `GeneralizedLinearMixedModel` are subtypes of `StatsBase.RegressionModel` which, in turn, is a subtype of `StatsBase.StatisticalModel`.
Many of the generic extractors defined in the `StatsBase` package have methods for these models.
"""

# ╔═╡ 00c07842-7e96-11eb-1cba-47c02b528f28
md"""
## Model-fit statistics
"""

# ╔═╡ 0934c3d4-7e96-11eb-357f-111fed8bfff0
md"""
The statistics describing the quality of the model fit include
"""

# ╔═╡ 1fb96cb8-7e96-11eb-2228-ddf25c32e4e1
# @doc loglikelihood(::StatisticalModel)

# ╔═╡ f42ef652-7e96-11eb-3982-8dda0f9fd50a
# loglikelihood(fm1)

# ╔═╡ 6d68f712-7e96-11eb-1e9f-f9c48e3a7545
# @doc aic

# ╔═╡ 10467020-7e97-11eb-114b-a12707745078
# aic(fm1)

# ╔═╡ 80b96608-7e96-11eb-3a25-5d63f2358874
# @doc bic

# ╔═╡ 16efb40e-7e97-11eb-08db-ddc386b0d4d0
# bic(fm1)

# ╔═╡ 84893858-7e96-11eb-22d1-77f8e7bbb30b
# @doc dof(::StatisticalModel)

# ╔═╡ 1b7caa6a-7e97-11eb-1331-bd8085e9b8ba
# dof(fm1)

# ╔═╡ 8c12f032-7e96-11eb-07c3-c75896e69c7d
# @doc nobs(::StatisticalModel)

# ╔═╡ 1f2e89c6-7e97-11eb-0982-173a3bb1f413
# nobs(fm1)

# ╔═╡ 49df9b6c-7e97-11eb-1e13-759613246c24
md"""
In general the [`deviance`](https://en.wikipedia.org/wiki/Deviance_(statistics)) of a statistical model fit is negative twice the log-likelihood adjusting for the saturated model.
"""

# ╔═╡ 4f62a336-7e97-11eb-205e-6b9f2ab93403
# @doc deviance(::StatisticalModel)

# ╔═╡ 5cbc6178-7e97-11eb-1691-bf1692268243
md"""
Because it is not clear what the saturated model corresponding to a particular `LinearMixedModel` should be, negative twice the log-likelihood is called the `objective`.
"""

# ╔═╡ 6b4ff766-7e97-11eb-3361-77dd3eea2729
# @doc objective

# ╔═╡ 76e93c6a-7e97-11eb-2c50-a739fed04e07
md"""
This value is also accessible as the `deviance` but the user should bear in mind that this doesn't have all the properties of a deviance which is corrected for the saturated model.
For example, it is not necessarily non-negative.
"""

# ╔═╡ d516fef8-7e97-11eb-3b2e-650519d15c5c
# objective(fm1)

# ╔═╡ e823ff82-7e97-11eb-2e65-976e8b2d2a2f
# deviance(fm1)

# ╔═╡ 12e2cfdc-7e98-11eb-1fe3-1318ca0cf090
md"""
The value optimized when fitting a `GeneralizedLinearMixedModel` is the Laplace approximation to the deviance or an adaptive Gauss-Hermite evaluation.
"""

# ╔═╡ 17513766-7e98-11eb-2e2b-8d2ac682c55f
# @doc MixedModels.deviance!

# ╔═╡ 23883dc4-7e98-11eb-1793-e7a7d7d35baa
# MixedModels.deviance!(gm1)

# ╔═╡ 5328ab6e-7e98-11eb-2e07-3b8407a84666
md"""
## Fixed-effects parameter estimates
"""

# ╔═╡ 618078c4-7e98-11eb-341f-4b27eb789940
md"""
The `coef` and `fixef` extractors both return the maximum likelihood estimates of the fixed-effects coefficients.
They differ in their behavior in the rank-deficient case.
The associated `coefnames` and `fixefnames` return the corresponding coefficient names.
"""

# ╔═╡ 28d9044a-7e99-11eb-22cf-6f2c8c2359a7
# @doc coef

# ╔═╡ 8043538a-7e98-11eb-3c7c-0363f0d2c340
# @doc coefnames

# ╔═╡ 85335084-7e98-11eb-1b34-cf346ec744da
# @doc fixef

# ╔═╡ 8a0e817a-7e98-11eb-215f-2bb105d3054f
# @doc fixefnames

# ╔═╡ ecd0dc48-7e98-11eb-0cd3-7706d49bef2b
# begin
# coef(fm1)
# coefnames(fm1)
# fixef(fm1)
# fixefnames(fm1)
# end

# ╔═╡ 44b8d99c-7e99-11eb-13a7-5308a1156cba
md"""
An alternative extractor for the fixed-effects coefficient is the `β` property.
Properties whose names are Greek letters usually have an alternative spelling, which is the name of the Greek letter.
"""

# ╔═╡ 54dac060-7e99-11eb-26f2-4bb423bea301
# fm1.β

# ╔═╡ 9a8b34dc-7e99-11eb-3ac7-79f8cca701bc
# fm1.beta

# ╔═╡ 9e3ac890-7e99-11eb-0bd9-673cf0b3f2f7
# gm1.β

# ╔═╡ a4936b66-7e99-11eb-23cd-e31545f0bb80
md"""
A full list of property names is returned by `propertynames`
"""

# ╔═╡ b1231052-7e99-11eb-1124-cb4129c9f701
# propertynames(fm1)

# ╔═╡ bae8f412-7e99-11eb-3708-cf76d5a7fc9e
# propertynames(gm1)

# ╔═╡ dad8293e-7e99-11eb-1580-29aa4c99298a
md"""
The variance-covariance matrix of the fixed-effects coefficients is returned by
"""

# ╔═╡ de3c54d8-7e99-11eb-31db-095b43f5b202
# @doc vcov

# ╔═╡ ecd3cc86-7e99-11eb-1d39-ad15931a9094
# vcov(fm2)

# ╔═╡ f63506f0-7e99-11eb-2472-95f30956fa89
# vcov(gm1)

# ╔═╡ 07285c00-7e9a-11eb-21bf-d7bc990e78a7
md"""
The standard errors are the square roots of the diagonal elements of the estimated variance-covariance matrix of the fixed-effects coefficient estimators.
"""

# ╔═╡ 14d9906c-7e9a-11eb-0ad7-f3c90508aec9
# @doc stderror

# ╔═╡ 1d50466e-7e9a-11eb-11e9-0f7d3ab780ac
# stderror(fm2)

# ╔═╡ 40a848d2-7e9a-11eb-148e-4b86549d2a58
# stderror(gm1)

# ╔═╡ 4f7e31fa-7e9a-11eb-116a-3f0df94604d3
md"""
Finally, the `coeftable` generic produces a table of coefficient estimates, their standard errors, and their ratio.
The *p-values* quoted here should be regarded as approximations.
"""

# ╔═╡ 5488bae4-7e9a-11eb-3484-9b1327633826
# @doc coeftable

# ╔═╡ 60c91c0c-7e9a-11eb-2c20-afc4d08faebb
# coeftable(fm2)

# ╔═╡ 706f2888-7e9a-11eb-0a7c-49f2656c9826
md"""
## Covariance parameter estimates
"""

# ╔═╡ 73f55446-7e9a-11eb-30a6-6dacdf0db673
md"""
The covariance parameters estimates, in the form shown in the model summary, are a `VarCorr` object.
"""

# ╔═╡ 95325faa-7e9a-11eb-0b27-df520ff8be64
# @doc VarCorr

# ╔═╡ a7f4d41a-7e9a-11eb-0436-f9095bd99fad
# VarCorr(fm2)

# ╔═╡ b100436e-7e9a-11eb-332a-2335eb869d3d
# VarCorr(gm1)

# ╔═╡ b67379e2-7e9a-11eb-19f6-a76ac2689b09
md"""
Individual components are returned by other extractors
"""

# ╔═╡ c2d3338a-7e9a-11eb-2ee2-6dbfc74a0ca2
# @doc varest

# ╔═╡ ce61e8ea-7e9a-11eb-08c4-69bd6879e9ac
# @doc sdest

# ╔═╡ d23629c2-7e9a-11eb-1fee-f313dfe2db71
# varest(fm2)

# ╔═╡ d8d23dac-7e9a-11eb-1f31-afba34bcb50f
# sdest(fm2)

# ╔═╡ e15d58ba-7e9a-11eb-0ff2-b7af75d80674
# fm2.σ

# ╔═╡ e8623362-7e9a-11eb-30e8-edaf59c9f3a7
md"""
## Conditional modes of the random effects
"""

# ╔═╡ f24ec138-7e9a-11eb-09f7-fddd95a8b898
md"""
The `ranef` extractor
"""

# ╔═╡ 3f8c5cbc-7e9b-11eb-3144-d7efaa786530
# @doc ranef

# ╔═╡ 4955163a-7e9b-11eb-3851-07b1813c7301
# ranef(fm1)

# ╔═╡ 5033a16c-7e9b-11eb-1ac6-532f50fbbc46
# fm1.b

# ╔═╡ 611fc0f8-7e9b-11eb-2fc6-f51dd19c1312
md"""
returns the *conditional modes* of the random effects given the observed data.
That is, these are the values that maximize the conditional density of the random effects given the observed data.
For a `LinearMixedModel` these are also the conditional mean values.

These are sometimes called the *best linear unbiased predictors* or [`BLUPs`](https://en.wikipedia.org/wiki/Best_linear_unbiased_prediction) but that name is not particularly meaningful.

At a superficial level these can be considered as the "estimates" of the random effects, with a bit of hand waving, but pursuing this analogy too far usually results in confusion.

To obtain tables associating the values of the conditional modes with the levels of the grouping factor, use
"""

# ╔═╡ 66e8d132-7e9b-11eb-0435-31d066e3191e
# @doc raneftables

# ╔═╡ 93b8235c-7e9b-11eb-1d99-b5c5120462ed
md"""
as in
"""

# ╔═╡ a22faba8-7e9b-11eb-35eb-2ddfbf2a7862
# DataFrame(only(raneftables(fm1)))

# ╔═╡ abb6adc0-7e9b-11eb-3641-ab33dbb81665
md"""
The corresponding conditional variances are returned by
"""

# ╔═╡ b615c6a2-7e9b-11eb-07f0-b9e8c45e79bf
# @doc condVar

# ╔═╡ be04b328-7e9b-11eb-21bb-299b2b46e470
# condVar(fm1)

# ╔═╡ c56b2188-7e9b-11eb-2aea-a32ed17096e8
md"""
## Case-wise diagnostics and residual degrees of freedom
"""

# ╔═╡ d3d6eaa4-7e9b-11eb-1777-c34147a26e06
md"""
The `leverage` values
"""

# ╔═╡ ddf14d86-7e9b-11eb-1793-8348609debd5
# @doc leverage

# ╔═╡ e6e3eac0-7e9b-11eb-261d-6d9da56726ad
# leverage(fm1)

# ╔═╡ ec093064-7e9b-11eb-2e99-43b023e066eb
md"""
are used in diagnostics for linear regression models to determine cases that exert a strong influence on their own predicted response.

The documentation refers to a "projection".
For a linear model without random effects the fitted values are obtained by orthogonal projection of the response onto the column span of the model matrix and the sum of the leverage values is the dimension of this column span.
That is, the sum of the leverage values is the rank of the model matrix and `n - sum(leverage(m))` is the degrees of freedom for residuals.
The sum of the leverage values is also the trace of the so-called "hat" matrix, `H`.
(The name "hat matrix" reflects the fact that $\hat{\mathbf{y}} = \mathbf{H} \mathbf{y}$.  That is, `H` puts a hat on `y`.)

For a linear mixed model the sum of the leverage values will be between `p`, the rank of the fixed-effects model matrix, and `p + q` where `q` is the total number of random effects.
This number does not represent a dimension (or "degrees of freedom") of a linear subspace of all possible fitted values because the projection is not an orthogonal projection.
Nevertheless, it is a reasonable measure of the effective degrees of freedom of the model and `n - sum(leverage(m))` can be considered the effective residual degrees of freedom.

For model `fm1` the dimensions are
"""

# ╔═╡ 37216e76-7ee8-11eb-1fc9-0feacc372d59
# @doc size(m::MixedModel)

# ╔═╡ ffbe97fc-7e9b-11eb-2d3d-934f1840a63a
# n, p, q, k = size(fm1)

# ╔═╡ 161e4998-7e9c-11eb-34c6-d931b3029d0f
md"""
which implies that the sum of the leverage values should be in the range [1, 7].
The actual value is
"""

# ╔═╡ 20c030da-7e9c-11eb-01d7-07848f42f30c
# sum(leverage(fm1))

# ╔═╡ 26626c3a-7e9c-11eb-0754-a1beac594c21
md"""
For model `fm2` the dimensions are
"""

# ╔═╡ 2e696bae-7e9c-11eb-3eaf-494176e1e2d2
# n, p, q, k = size(fm2)

# ╔═╡ 36f2ec96-7e9c-11eb-1451-d534f02796ff
md"""
providing a range of [2, 38] for the effective degrees of freedom for the model.
The observed value is
"""

# ╔═╡ 461f2376-7e9c-11eb-1e0a-d9ef9796a6f2
# sum(leverage(fm2))

# ╔═╡ 4bb22430-7e9c-11eb-25dc-91e6651a10d2
md"""
When a model converges to a singular covariance, such as
"""

# ╔═╡ 5ddbe72c-7e9c-11eb-25d8-ebc1b26e0480
# fm3 = fit(MixedModel, @formula(yield ~ 1+(1|batch)), MixedModels.dataset(:dyestuff2))

# ╔═╡ 6440803a-7e9c-11eb-370f-7f2a006e8843
# sum(leverage(fm3))

# ╔═╡ 75adfc46-7e9c-11eb-3909-d3456e8c9a62
md"""
Models for which the estimates of the variances of the random effects are large relative to the residual variance have effective degrees of freedom close to the upper bound.
"""

# ╔═╡ 7e17f666-7e9c-11eb-1fdc-d96096b03dd0
# fm4 = fit(MixedModel, @formula(diameter ~ 1+(1|plate)+(1|sample)), MixedModels.dataset(:penicillin));

# ╔═╡ bb709650-7e9c-11eb-30f3-c9e60d19fdc1
# sum(leverage(fm4))

# ╔═╡ f4634480-7e9c-11eb-2fce-9fe0415d2dd4
md"""
Also, a model fit by the REML criterion generally has larger estimates of the variance components and hence a larger effective degrees of freedom.
"""

# ╔═╡ 00974506-7e9d-11eb-1819-9119a23169f4
# fm4r = fit(MixedModel, @formula(diameter ~ 1+(1|plate)+(1|sample)), MixedModels.dataset(:penicillin), REML=true);

# ╔═╡ 03aa0508-7e9d-11eb-1764-bb96dabb2dc3
# sum(leverage(fm4r))

# ╔═╡ Cell order:
# ╠═d9911824-857c-11eb-2cc0-db48cedbff76
# ╠═64a64a5a-8583-11eb-13d8-8d1457d4b117
# ╠═6ab41af8-8583-11eb-3bcc-3fc03804e84f
# ╟─69180010-7e53-11eb-1afb-4b7d6609ca97
# ╠═d8984d92-7e8e-11eb-0d68-255375344426
# ╟─535aacb2-7e64-11eb-3781-7911423c8734
# ╟─6cf58296-7e64-11eb-354f-b31e0fedf5ac
# ╠═42399604-7e17-11eb-019f-a3612db180c9
# ╠═4c6921b0-7e17-11eb-0c3b-4fd483bf4024
# ╟─5fd7dc9e-7e64-11eb-0e42-7b28e4c890f2
# ╟─ae61fd9c-7e64-11eb-20e5-839180dd1243
# ╠═db678696-7e70-11eb-1489-f56c4f344bb4
# ╠═ddd14974-7963-11eb-0b4f-5bd61b00331e
# ╠═94381cdc-7e6f-11eb-1334-035df5150bf3
# ╠═3c0bb720-7e93-11eb-214d-994cdc42b9b0
# ╟─ac77b92a-7e64-11eb-067d-715baea6c450
# ╟─d9c8be96-7e6f-11eb-0b19-13e583f75e19
# ╠═7fbd4cf8-7e17-11eb-2bdc-e77bca0ad0a9
# ╟─ee42621e-7e6f-11eb-355c-1d224de62501
# ╠═f32ae4e0-7e6f-11eb-101a-1da76dc0dc30
# ╟─4c66fdb4-7e70-11eb-1dac-b7e36bbaef38
# ╠═54eef27a-7e70-11eb-2c8a-3fbcb1266b6e
# ╠═5d748ffe-7e70-11eb-01f3-23c6d14045b0
# ╟─2346e6ee-7e73-11eb-0c7e-19636e41fbac
# ╟─ccbe52a2-7e70-11eb-390f-4d0e695df7da
# ╠═2bbf68ce-7ffd-11eb-3d64-118573933a5d
# ╠═35fa8d28-7ffd-11eb-0e5e-c183a5e43c69
# ╠═3f31f56e-7ffd-11eb-28be-65f9011e3690
# ╟─67be7b40-7e71-11eb-2e0a-a589b720015c
# ╠═1bd8caec-7e93-11eb-2244-bf6118c02892
# ╠═6cec57d6-7e71-11eb-350b-4f3de1b7f968
# ╟─0236fabc-7e72-11eb-02eb-41ae0dbae760
# ╠═064fdf6a-7e72-11eb-1f18-2706287ba102
# ╠═396514ec-7e72-11eb-1367-316a5dd6c351
# ╟─1bce190c-7ffc-11eb-1454-63f45dc02d37
# ╟─8b2bf6ce-7e72-11eb-3db4-c3600353f30d
# ╟─42d2311e-7ffc-11eb-3621-2fc7582c23fc
# ╟─fc6c3128-7e72-11eb-3a7c-1bd62a5c2f6e
# ╠═1e7a64de-7e90-11eb-0070-ef1d983b24e7
# ╠═9ae57d6c-7e8e-11eb-3a7e-db954a666006
# ╠═06547e5c-7e73-11eb-1c2c-d748796fada7
# ╟─611f7364-7e73-11eb-1a2d-d37d993dff62
# ╟─cc463a50-7b31-11eb-2038-bf7197b9fd5d
# ╠═113e8f52-7e90-11eb-3480-afac7386903f
# ╠═7d93b3b6-7e73-11eb-1fa9-ed6da66a7af2
# ╠═521bfd32-7e8d-11eb-3b73-9790cd6a7bb2
# ╟─aa2beea6-7b31-11eb-0119-c799285260a6
# ╠═083847d8-7e90-11eb-3d6c-4d07414e8a54
# ╠═c099085e-7e8d-11eb-0a86-514802ea7686
# ╟─bc97f888-7e73-11eb-145b-7370b6193ee6
# ╠═51d8ac80-7974-11eb-0e96-05669ad474e9
# ╟─5ec332d0-7974-11eb-1b69-111abed4e6d7
# ╠═308c7f06-7e90-11eb-23b7-f140569bc6ac
# ╠═2b19cad8-7e8e-11eb-356b-916076c527b8
# ╠═d4dde662-7e73-11eb-2880-03e9ea3087e0
# ╟─ea8ac676-7e73-11eb-13fa-37075a67711c
# ╠═f7e658aa-7e8f-11eb-29d2-65ff71902d7a
# ╠═39397a9c-7e90-11eb-3356-af4478c359e9
# ╠═f39e6522-7e73-11eb-0dc1-f5ca3a5a0b5d
# ╟─c673808c-7b41-11eb-01bb-539963671d25
# ╟─96af6916-7e74-11eb-2257-c7d8b593ca97
# ╠═d24678b0-7b41-11eb-035d-0f1b1bddb8f3
# ╟─bf26a1d4-7e74-11eb-2d27-854b65ede8fd
# ╠═7edd9626-7b42-11eb-3206-992a5dbab4ab
# ╟─ebca616e-7e74-11eb-313e-a52085549472
# ╠═a7311952-7e91-11eb-2547-0dd95c8326ee
# ╠═86deb76a-7b42-11eb-259a-45970009dd5c
# ╟─fec293c0-7e74-11eb-31e3-d7fc8d885738
# ╠═a6753dc4-7b42-11eb-2b7f-2b5b3de28e45
# ╟─a5b0b160-7e75-11eb-2818-a164714ef5c0
# ╠═b3e3de80-7e75-11eb-2b54-3f173617d14b
# ╠═ab3f87e2-7b42-11eb-308e-95aa681338a0
# ╟─377740dc-7e78-11eb-390a-4f1556cba86c
# ╠═6abff318-7e90-11eb-1124-413f405c7398
# ╟─2b519f7c-7e92-11eb-3684-b72027369290
# ╟─56a66d60-7e92-11eb-340c-f93d4686b046
# ╠═3e160db4-7e92-11eb-1478-1bd4513e7d77
# ╠═e6798412-7e93-11eb-0613-49ef92fb1d27
# ╠═eb39f748-7e93-11eb-127a-3dd5ad779385
# ╠═ef1db552-7e93-11eb-1ab9-bb43232047b2
# ╟─bfe0cfe6-7e92-11eb-36cb-abccf56f0475
# ╟─cdd68b0e-7e92-11eb-0aa9-39fd7916ad69
# ╟─d373e7f0-7e92-11eb-147b-7d870ffa3473
# ╠═c3452b36-7e93-11eb-36fc-c19d1cfa6059
# ╠═e0e4a956-7e92-11eb-3d12-1f19be9c7d33
# ╠═b6a4caee-7e93-11eb-390e-1766d82ac861
# ╠═0cdb3b50-7e94-11eb-0fca-a9f8fdec0b9d
# ╟─36167304-7e94-11eb-158b-8bf1af346b78
# ╠═4971668e-7e94-11eb-2c42-45cdff449406
# ╠═61a71956-7e94-11eb-24c8-c5f50d6b1277
# ╠═a19cbf16-7e94-11eb-1863-c1f02a354066
# ╟─f1412e0c-7e95-11eb-2b96-ddb14645c3af
# ╟─fb1ed1c4-7e95-11eb-213c-a33c76f24969
# ╟─00c07842-7e96-11eb-1cba-47c02b528f28
# ╟─0934c3d4-7e96-11eb-357f-111fed8bfff0
# ╠═1fb96cb8-7e96-11eb-2228-ddf25c32e4e1
# ╠═f42ef652-7e96-11eb-3982-8dda0f9fd50a
# ╠═6d68f712-7e96-11eb-1e9f-f9c48e3a7545
# ╠═10467020-7e97-11eb-114b-a12707745078
# ╠═80b96608-7e96-11eb-3a25-5d63f2358874
# ╠═16efb40e-7e97-11eb-08db-ddc386b0d4d0
# ╠═84893858-7e96-11eb-22d1-77f8e7bbb30b
# ╠═1b7caa6a-7e97-11eb-1331-bd8085e9b8ba
# ╠═8c12f032-7e96-11eb-07c3-c75896e69c7d
# ╠═1f2e89c6-7e97-11eb-0982-173a3bb1f413
# ╟─49df9b6c-7e97-11eb-1e13-759613246c24
# ╠═4f62a336-7e97-11eb-205e-6b9f2ab93403
# ╟─5cbc6178-7e97-11eb-1691-bf1692268243
# ╠═6b4ff766-7e97-11eb-3361-77dd3eea2729
# ╟─76e93c6a-7e97-11eb-2c50-a739fed04e07
# ╠═d516fef8-7e97-11eb-3b2e-650519d15c5c
# ╠═e823ff82-7e97-11eb-2e65-976e8b2d2a2f
# ╟─12e2cfdc-7e98-11eb-1fe3-1318ca0cf090
# ╠═17513766-7e98-11eb-2e2b-8d2ac682c55f
# ╠═23883dc4-7e98-11eb-1793-e7a7d7d35baa
# ╟─5328ab6e-7e98-11eb-2e07-3b8407a84666
# ╟─618078c4-7e98-11eb-341f-4b27eb789940
# ╠═28d9044a-7e99-11eb-22cf-6f2c8c2359a7
# ╠═8043538a-7e98-11eb-3c7c-0363f0d2c340
# ╠═85335084-7e98-11eb-1b34-cf346ec744da
# ╠═8a0e817a-7e98-11eb-215f-2bb105d3054f
# ╠═ecd0dc48-7e98-11eb-0cd3-7706d49bef2b
# ╟─44b8d99c-7e99-11eb-13a7-5308a1156cba
# ╠═54dac060-7e99-11eb-26f2-4bb423bea301
# ╠═9a8b34dc-7e99-11eb-3ac7-79f8cca701bc
# ╠═9e3ac890-7e99-11eb-0bd9-673cf0b3f2f7
# ╟─a4936b66-7e99-11eb-23cd-e31545f0bb80
# ╠═b1231052-7e99-11eb-1124-cb4129c9f701
# ╠═bae8f412-7e99-11eb-3708-cf76d5a7fc9e
# ╟─dad8293e-7e99-11eb-1580-29aa4c99298a
# ╠═de3c54d8-7e99-11eb-31db-095b43f5b202
# ╠═ecd3cc86-7e99-11eb-1d39-ad15931a9094
# ╠═f63506f0-7e99-11eb-2472-95f30956fa89
# ╟─07285c00-7e9a-11eb-21bf-d7bc990e78a7
# ╠═14d9906c-7e9a-11eb-0ad7-f3c90508aec9
# ╠═1d50466e-7e9a-11eb-11e9-0f7d3ab780ac
# ╠═40a848d2-7e9a-11eb-148e-4b86549d2a58
# ╟─4f7e31fa-7e9a-11eb-116a-3f0df94604d3
# ╠═5488bae4-7e9a-11eb-3484-9b1327633826
# ╠═60c91c0c-7e9a-11eb-2c20-afc4d08faebb
# ╟─706f2888-7e9a-11eb-0a7c-49f2656c9826
# ╟─73f55446-7e9a-11eb-30a6-6dacdf0db673
# ╠═95325faa-7e9a-11eb-0b27-df520ff8be64
# ╠═a7f4d41a-7e9a-11eb-0436-f9095bd99fad
# ╠═b100436e-7e9a-11eb-332a-2335eb869d3d
# ╟─b67379e2-7e9a-11eb-19f6-a76ac2689b09
# ╠═c2d3338a-7e9a-11eb-2ee2-6dbfc74a0ca2
# ╠═ce61e8ea-7e9a-11eb-08c4-69bd6879e9ac
# ╠═d23629c2-7e9a-11eb-1fee-f313dfe2db71
# ╠═d8d23dac-7e9a-11eb-1f31-afba34bcb50f
# ╠═e15d58ba-7e9a-11eb-0ff2-b7af75d80674
# ╟─e8623362-7e9a-11eb-30e8-edaf59c9f3a7
# ╟─f24ec138-7e9a-11eb-09f7-fddd95a8b898
# ╠═3f8c5cbc-7e9b-11eb-3144-d7efaa786530
# ╠═4955163a-7e9b-11eb-3851-07b1813c7301
# ╠═5033a16c-7e9b-11eb-1ac6-532f50fbbc46
# ╟─611fc0f8-7e9b-11eb-2fc6-f51dd19c1312
# ╠═66e8d132-7e9b-11eb-0435-31d066e3191e
# ╟─93b8235c-7e9b-11eb-1d99-b5c5120462ed
# ╠═a22faba8-7e9b-11eb-35eb-2ddfbf2a7862
# ╟─abb6adc0-7e9b-11eb-3641-ab33dbb81665
# ╠═b615c6a2-7e9b-11eb-07f0-b9e8c45e79bf
# ╠═be04b328-7e9b-11eb-21bb-299b2b46e470
# ╟─c56b2188-7e9b-11eb-2aea-a32ed17096e8
# ╟─d3d6eaa4-7e9b-11eb-1777-c34147a26e06
# ╠═ddf14d86-7e9b-11eb-1793-8348609debd5
# ╠═e6e3eac0-7e9b-11eb-261d-6d9da56726ad
# ╟─ec093064-7e9b-11eb-2e99-43b023e066eb
# ╠═37216e76-7ee8-11eb-1fc9-0feacc372d59
# ╠═ffbe97fc-7e9b-11eb-2d3d-934f1840a63a
# ╟─161e4998-7e9c-11eb-34c6-d931b3029d0f
# ╠═20c030da-7e9c-11eb-01d7-07848f42f30c
# ╟─26626c3a-7e9c-11eb-0754-a1beac594c21
# ╠═2e696bae-7e9c-11eb-3eaf-494176e1e2d2
# ╟─36f2ec96-7e9c-11eb-1451-d534f02796ff
# ╠═461f2376-7e9c-11eb-1e0a-d9ef9796a6f2
# ╟─4bb22430-7e9c-11eb-25dc-91e6651a10d2
# ╠═5ddbe72c-7e9c-11eb-25d8-ebc1b26e0480
# ╠═6440803a-7e9c-11eb-370f-7f2a006e8843
# ╟─75adfc46-7e9c-11eb-3909-d3456e8c9a62
# ╠═7e17f666-7e9c-11eb-1fdc-d96096b03dd0
# ╠═bb709650-7e9c-11eb-30f3-c9e60d19fdc1
# ╟─f4634480-7e9c-11eb-2fce-9fe0415d2dd4
# ╠═00974506-7e9d-11eb-1819-9119a23169f4
# ╠═03aa0508-7e9d-11eb-1764-bb96dabb2dc3
