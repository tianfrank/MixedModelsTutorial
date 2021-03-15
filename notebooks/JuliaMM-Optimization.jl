### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ d4338852-7ee8-11eb-3875-b39a47953223
using PlutoUI

# ╔═╡ 21b9cb60-7eec-11eb-1509-c96fb86d8720
begin
	using MixedModels
	import FreqTables: freqtable
	import DataFrames: DataFrame
	import DisplayAs: Text
	import BenchmarkTools: @btime
end

# ╔═╡ affde242-7ee9-11eb-33a9-1f243834119f
TableOfContents()

# ╔═╡ b579ff12-7ee9-11eb-1530-475e52a04b26
md"""
# Details of the parameter estimation
"""

# ╔═╡ c785c038-7ee9-11eb-3f5d-5dc76f60496a
md"""
## The probability model
"""

# ╔═╡ d0919954-7ee9-11eb-03a4-1d1a7c89ade9
md"""
Maximum likelihood estimates are based on the probability model for the observed responses.
In the probability model the distribution of the responses is expressed as a function of one or more *parameters*.

For a continuous distribution the probability density is a function of the responses, given the parameters.
The *likelihood* function is the same expression as the probability density but regarding the observed values as fixed and the parameters as varying.

In general a mixed-effects model incorporates two random variables: $\mathcal{B}$, the $q$-dimensional vector of random effects, and $\mathcal{Y}$, the $n$-dimensional response vector.
The value, $\bf y$, of $\mathcal{Y}$ is observed; the value, $\bf b$, of $\mathcal{B}$ is not.
"""

# ╔═╡ 0bad79b8-7eea-11eb-257d-052e5f103deb
md"""
## Linear Mixed-Effects Models
"""

# ╔═╡ 1983b37c-7eea-11eb-1a6d-b7583fdc647a
md"""
In a linear mixed model the unconditional distribution of $\mathcal{B}$ and the conditional distribution, $(\mathcal{Y} | \mathcal{B}=\bf{b})$, are both multivariate Gaussian distributions,
```math
\begin{aligned}
  (\mathcal{Y} | \mathcal{B}=\bf{b}) &\sim\mathcal{N}(\bf{ X\beta + Z b},\sigma^2\bf{I})\\\\
  \mathcal{B}&\sim\mathcal{N}(\bf{0},\Sigma_\theta) .
\end{aligned}
```
The *conditional mean* of $\mathcal Y$, given $\mathcal B=\bf b$, is the *linear predictor*, $\bf X\bf\beta+\bf Z\bf b$, which depends on the $p$-dimensional *fixed-effects parameter*, $\bf \beta$, and on $\bf b$.
The *model matrices*, $\bf X$ and $\bf Z$, of dimension $n\times p$ and $n\times q$, respectively, are determined from the formula for the model and the values of covariates.
Although the matrix $\bf Z$ can be large (i.e. both $n$ and $q$ can be large), it is sparse (i.e. most of the elements in the matrix are zero).

The *relative covariance factor*, $\Lambda_\theta$, is a $q\times q$ lower-triangular matrix, depending on the *variance-component parameter*, $\bf\theta$, and generating the symmetric $q\times q$ variance-covariance matrix, $\Sigma_\theta$, as
```math
\Sigma_\theta=\sigma^2\Lambda_\theta\Lambda_\theta'
```

The *spherical random effects*, $\mathcal{U}\sim\mathcal{N}(\bf{0},\sigma^2\bf{I}_q)$, determine $\mathcal B$ according to
```math
\mathcal{B}=\Lambda_\theta\mathcal{U}.
```
The *penalized residual sum of squares* (PRSS),
```math
r^2(\theta,\beta,\bf{u})=\|\bf{y} - \bf{X}\beta -\bf{Z}\Lambda_\theta\bf{u}\|^2+\|\bf{u}\|^2,
```
is the sum of the residual sum of squares, measuring fidelity of the model to the data, and a penalty on the size of $\bf u$, measuring the complexity of the model.
Minimizing $r^2$ with respect to $\bf u$,
```math
r^2_{\beta,\theta} =\min_{\bf{u}}\left(\|\bf{y} -\bf{X}{\beta} -\bf{Z}\Lambda_\theta\bf{u}\|^2+\|\bf{u}\|^2\right)
```
is a direct (i.e. non-iterative) computation.
The particular method used to solve this generates a *blocked Choleksy factor*, $\bf{L}_\theta$, which is an lower triangular $q\times q$ matrix satisfying
```math
\bf{L}_\theta\bf{L}_\theta'=\Lambda_\theta'\bf{Z}'\bf{Z}\Lambda_\theta+\bf{I}_q .
```
where ${\bf I}_q$ is the $q\times q$ *identity matrix*.

Negative twice the log-likelihood of the parameters, given the data, $\bf y$, is
```math
d({\bf\theta},{\bf\beta},\sigma|{\bf y})
=n\log(2\pi\sigma^2)+\log(|{\bf L}_\theta|^2)+\frac{r^2_{\beta,\theta}}{\sigma^2}.
```
where $|{\bf L}_\theta|$ denotes the *determinant* of ${\bf L}_\theta$.
Because ${\bf L}_\theta$ is triangular, its determinant is the product of its diagonal elements.

Because the conditional mean, $\bf\mu_{\mathcal Y|\mathcal B=\bf b}=\bf
X\bf\beta+\bf Z\Lambda_\theta\bf u$, is a linear function of both $\bf\beta$ and $\bf u$, minimization of the PRSS with respect to both $\bf\beta$ and $\bf u$ to produce
```math
r^2_\theta =\min_{{\bf\beta},{\bf u}}\left(\|{\bf y} -{\bf X}{\bf\beta} -{\bf Z}\Lambda_\theta{\bf u}\|^2+\|{\bf u}\|^2\right)
```
is also a direct calculation.
The values of $\bf u$ and $\bf\beta$ that provide this minimum are called, respectively, the *conditional mode*, $\tilde{\bf u}_\theta$, of the spherical random effects and the conditional estimate, $\widehat{\bf\beta}_\theta$, of the fixed effects.
At the conditional estimate of the fixed effects the objective is
```math
d({\bf\theta},\widehat{\beta}_\theta,\sigma|{\bf y})
=n\log(2\pi\sigma^2)+\log(|{\bf L}_\theta|^2)+\frac{r^2_\theta}{\sigma^2}.
```
Minimizing this expression with respect to $\sigma^2$ produces the conditional estimate
```math
\widehat{\sigma^2}_\theta=\frac{r^2_\theta}{n}
```
which provides the *profiled log-likelihood* on the deviance scale as
```math
\tilde{d}(\theta|{\bf y})=d(\theta,\widehat{\beta}_\theta,\widehat{\sigma}_\theta|{\bf y})
=\log(|{\bf L}_\theta|^2)+n\left[1+\log\left(\frac{2\pi r^2_\theta}{n}\right)\right],
```
a function of $\bf\theta$ alone.

The MLE of $\bf\theta$, written $\widehat{\bf\theta}$, is the value that minimizes this profiled objective.
We determine this value by numerical optimization.
In the process of evaluating $\tilde{d}(\widehat{\theta}|{\bf y})$ we determine $\widehat{\beta}=\widehat{\beta}_{\widehat\theta}$, $\tilde{\bf u}_{\widehat{\theta}}$ and $r^2_{\widehat{\theta}}$, from which we can evaluate $\widehat{\sigma}=\sqrt{r^2_{\widehat{\theta}}/n}$.

The elements of the conditional mode of $\mathcal B$, evaluated at the parameter estimates,
```math
\tilde{\bf b}_{\widehat{\theta}}=\Lambda_{\widehat{\theta}}\tilde{\bf u}_{\widehat{\theta}}
```
are sometimes called the *best linear unbiased predictors* or BLUPs of the random effects.
Although BLUPs an appealing acronym, I don’t find the term particularly instructive (what is a “linear unbiased predictor” and in what sense are these the “best”?) and prefer the term “conditional modes”, because these are the values of $\bf b$ that maximize the density of the conditional distribution $\mathcal{B} | \mathcal{Y} = {\bf y}$.
For a linear mixed model, where all the conditional and unconditional distributions are Gaussian, these values are also the *conditional means*.
"""

# ╔═╡ e7cf0e1a-7eeb-11eb-230d-572cd2710646
md"""
## Internal structure of $\Lambda_\theta$ and $\bf Z$
"""

# ╔═╡ ebc43efa-7eeb-11eb-35ae-d15dad5b4498
md"""
In the types of `LinearMixedModel` available through the `MixedModels` package, groups of random effects and the corresponding columns of the model matrix, $\bf Z$, are associated with *random-effects terms* in the model formula.

For the simple example
"""

# ╔═╡ fc715350-7eeb-11eb-00c3-1f7cf361258b
# dyestuff = MixedModels.dataset(:dyestuff) |> DataFrame;

# ╔═╡ 9fb9dd78-7eec-11eb-18c9-3119cf3ca1e5
# freqtable(dyestuff, :batch).array

# ╔═╡ 0d642a1e-7eec-11eb-3486-1912b708d399
# fm1 = fit(MixedModel, @formula(yield ~ 1 + (1 | batch)), dyestuff);

# ╔═╡ 36a4acf2-7eec-11eb-189a-0be24bdd7e3b
md"""
the only random effects term in the formula is `(1|batch)`, a simple, scalar random-effects term.
"""

# ╔═╡ fc6a590e-7eed-11eb-0b3a-3f04c9afd905
# t1 = first(fm1.reterms);

# ╔═╡ 42d11236-7eec-11eb-28b0-3523bec7cf69
# Int.(t1) # convert to integers for more compact display

# ╔═╡ 71377f82-7eec-11eb-3b21-5d0712895eca
# @doc ReMat

# ╔═╡ e4d41226-7eed-11eb-1ef7-f3aa3bdcc252
md"""
This `RandomEffectsTerm` contributes a block of columns to the model matrix $\bf Z$ and a diagonal block to $\Lambda_\theta$.
In this case the diagonal block of $\Lambda_\theta$ (which is also the only block) is a multiple of the $6\times6$
identity matrix where the multiple is
"""

# ╔═╡ ebb0bfd6-7eed-11eb-19ee-2711fdf75c6e
# t1.λ

# ╔═╡ 40dfc8a8-7eee-11eb-0756-2d7cdc8b7671
md"""
Because there is only one random-effects term in the model, the matrix $\bf Z$ is the indicators matrix shown as the result of `Int.(t1)`, but stored in a special sparse format.
Furthermore, there is only one block in $\Lambda_\theta$.


For a vector-valued random-effects term, as in
"""

# ╔═╡ 453bfb6a-7eee-11eb-15bd-a7c70c5a2358
# sleepstudy = MixedModels.dataset(:sleepstudy) |> DataFrame;

# ╔═╡ 7cb1296c-7eee-11eb-04ce-2517fe6ad5ee
# freqtable(sleepstudy, :subj, :days)

# ╔═╡ 95e02a6e-7eee-11eb-0c59-df12257fa1f3
# fm2 = fit(MixedModel, 
# 	@formula(reaction ~ 1 + days + (1 + days | subj)), 
# 	sleepstudy);

# ╔═╡ 918b4f2a-7eee-11eb-2bc2-a551d3066cf8
md"""
the model matrix $\bf Z$ is of the form
"""

# ╔═╡ a53c5190-7eee-11eb-2f47-4ba6c47a8cba
# t21 = first(fm2.reterms);

# ╔═╡ b6d76da4-7eee-11eb-04eb-8d498c004e76
# Int.(t21) # convert to integers for more compact display

# ╔═╡ cb313730-7eee-11eb-0918-15ff0616d854
md"""
and $\Lambda_\theta$ is a $36\times36$ block diagonal matrix with $18$ diagonal blocks, all of the form
"""

# ╔═╡ d939b550-7eee-11eb-3a92-1fe7601cefbd
# t21.λ

# ╔═╡ 06cc99d8-7eef-11eb-15b3-e1fb1938b10f
md"""
The $\theta$ vector is

"""

# ╔═╡ 0a6b2744-7eef-11eb-18f6-37561622f70f
# MixedModels.getθ(t21)

# ╔═╡ 152905c0-7eef-11eb-0e41-df989efdfe5d
md"""
Random-effects terms in the model formula that have the same grouping factor are amalgamated into a single `ReMat` object.

"""

# ╔═╡ 365a208a-7eef-11eb-318d-73e49002cb97
# fm3 = fit(MixedModel, 
# 	@formula(reaction ~ 1 + days + (1 | subj) + (0 + days | subj)), 
# 	sleepstudy);

# ╔═╡ 3a4a9742-7eef-11eb-2867-89721ab74991
# t31 = first(fm3.reterms);

# ╔═╡ 1955761a-7eef-11eb-3ca5-bdaf6c23d786
# Int.(t31)

# ╔═╡ 944b1d98-7ef4-11eb-3201-0fac9dea87ca
md"""
For this model the matrix $\bf Z$ is the same as that of model `fm2` but the diagonal blocks of $\Lambda_\theta$ are themselves diagonal.
"""

# ╔═╡ 9d465c8e-7ef4-11eb-364d-fd20590721e2
# t31.λ

# ╔═╡ ab9e5050-7ef4-11eb-26d1-fb95c0b2cd49
# MixedModels.getθ(t31)

# ╔═╡ 2aa51afa-7f09-11eb-0b65-7f0ebf7b6cae
md"""
Random-effects terms with distinct grouping factors generate distinct elements of the `reterms` field of the `LinearMixedModel` object.
Multiple `ReMat` objects are sorted by decreasing numbers of random effects.
"""

# ╔═╡ 33a3d7ae-7f09-11eb-1900-853274cd6981
# penicillin = MixedModels.dataset(:penicillin) |> DataFrame;

# ╔═╡ 409a9c84-7f09-11eb-0c56-7d543e7b4040
# freqtable(penicillin, :sample, :plate)

# ╔═╡ 63178bb6-7f09-11eb-3d64-5964a25ba8f3
# fm4 = fit(MixedModel,
#     @formula(diameter ~ 1 + (1 | sample) + (1 | plate)),
#     penicillin);

# ╔═╡ 7054fd5e-7f09-11eb-2fc5-bd0dd33430c0
# Int.(first(fm4.reterms))

# ╔═╡ 8192db7c-7f09-11eb-1c71-8bd16ee36e13
# Int.(last(fm4.reterms))

# ╔═╡ 89df8ecc-7f09-11eb-150c-6315a3d173f9
md"""
Note that the first `ReMat` in `fm4.reterms` corresponds to grouping factor `plate` even though the term `(1|plate)` occurs in the formula after `(1|sample)`.
"""

# ╔═╡ 937dcac4-7f09-11eb-2d07-cb3f3f51681d
md"""
### Progress of the optimization
"""

# ╔═╡ ae4426ee-7f09-11eb-0077-0bfb03ca1219
md"""
An optional named argument, `verbose=true`, in the call to `fit` for a `LinearMixedModel` causes printing of the objective and the $\theta$ parameter at each evaluation during the optimization.  (Not illustrated here.)

A shorter summary of the optimization process is always available as an
"""

# ╔═╡ eecb3716-7f09-11eb-2eb6-210a010fd864
# @doc OptSummary

# ╔═╡ 0e20c13a-7f0a-11eb-2385-552637082d6e
md"""
object, which is the `optsum` member of the `LinearMixedModel`.
"""

# ╔═╡ 0703c3ca-7f0a-11eb-1b6f-0386cb52031a
# fm2.optsum

# ╔═╡ 31f9b6b6-7f0a-11eb-1f1a-4b75f7fa9f20
md"""
## A blocked Cholesky factor
"""

# ╔═╡ 3933f3ec-7f0a-11eb-2477-5399522a963d
md"""
A `LinearMixedModel` object contains two blocked matrices; a symmetric matrix `A` (only the lower triangle is stored) and a lower-triangular `L` which is the lower Cholesky factor of the updated and inflated `A`.
In versions 4.0.0 and later of `MixedModels` only the blocks in the lower triangle are stored in `A` and `L`, as a `Vector{AbstractMatrix{T}}`
"""

# ╔═╡ 54f21578-7f0a-11eb-0234-8f42e8c7f6b8
# @doc BlockDescription

# ╔═╡ 626c23e4-7f0a-11eb-2152-f3385237d260
# BlockDescription(fm2)

# ╔═╡ db05a866-7f0a-11eb-3656-99a0f94f4042
md"""
Another change in v4.0.0 and later is that the last row of blocks is constructed from `m.Xymat` which contains the full-rank model matrix `X` with the response `y` concatenated on the right.

The operation of installing a new value of the variance parameters, `θ`, and updating `L`
"""

# ╔═╡ df6d3700-7f0a-11eb-3df1-d9149648188b
# @doc setθ!

# ╔═╡ 0a9dad7e-7f0b-11eb-0b9c-3f1048992788
# @doc updateL!

# ╔═╡ 3525a934-7f0b-11eb-0c36-0d55fa91a9ce
md"""
is the central step in evaluating the objective (negative twice the log-likelihood).

Typically, the (1,1) block is the largest block in `A` and `L` and it has a special form, either `Diagonal` or
"""

# ╔═╡ 1378efba-7f0d-11eb-14a7-c177f37dbecd
# @doc UniformBlockDiagonal

# ╔═╡ 2b4ab614-7f0d-11eb-3471-67c2b4030d5f
md"""
providing a compact representation and fast matrix multiplication or solutions of linear systems of equations.
"""

# ╔═╡ 33d7cc9a-7f0d-11eb-38c0-2dd8dc7f9948
md"""
### Modifying the optimization process
"""

# ╔═╡ 46493cc4-7f0d-11eb-34b9-67a1a91d1520
md"""
The `OptSummary` object contains both input and output fields for the optimizer.
To modify the optimization process the input fields can be changed after constructing the model but before fitting it.

Suppose, for example, that the user wishes to try a [Nelder-Mead](https://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method) optimization method instead of the default [`BOBYQA`](https://en.wikipedia.org/wiki/BOBYQA) (Bounded Optimization BY Quadratic Approximation) method.
"""

# ╔═╡ 50daf63c-7f0d-11eb-376e-db1365867656
# fm2.optsum.optimizer = :LN_NELDERMEAD

# ╔═╡ 6e2c3c5a-7f0d-11eb-122a-cba6be178d39
# refit!(fm2)

# ╔═╡ 7d3d079c-7f0d-11eb-0347-ffb82cd25e5b
# fm2.optsum

# ╔═╡ 90573528-7f0d-11eb-0569-d30d0c07a561
md"""
The parameter estimates are quite similar to those using `:LN_BOBYQA` but at the expense of 140 functions evaluations for `:LN_NELDERMEAD` versus 57 for `:LN_BOBYQA`.

See the documentation for the [`NLopt`](https://github.com/JuliaOpt/NLopt.jl) package for details about the various settings.
"""

# ╔═╡ 9a301182-7f0d-11eb-3922-0323e01ae8ef
md"""
### Convergence to singular covariance matrices

"""

# ╔═╡ 9f987880-7f0d-11eb-1694-ade291db9fa9
md"""
To ensure identifiability of $\Sigma_\theta=\sigma^2\Lambda_\theta \Lambda_\theta$, the elements of $\theta$ corresponding to diagonal elements of $\Lambda_\theta$ are constrained to be non-negative.
For example, in a trivial case of a single, simple, scalar, random-effects term as in `fm1`, the one-dimensional $\theta$ vector is the ratio of the standard deviation of the random effects to the standard deviation of the response.
It happens that $-\theta$ produces the same log-likelihood but, by convention, we define the standard deviation to be the positive square root of the variance.
Requiring the diagonal elements of $\Lambda_\theta$ to be non-negative is a generalization of using this positive square root.

If the optimization converges on the boundary of the feasible region, that is if one or more of the diagonal elements of $\Lambda_\theta$ is zero at convergence, the covariance matrix $\Sigma_\theta$ will be *singular*.
This means that there will be linear combinations of random effects that are constant.
Usually convergence to a singular covariance matrix is a sign of an over-specified model.

Singularity can be checked with the `issingular` predicate function.
"""

# ╔═╡ ac1e15ba-7f0d-11eb-3bcd-9f0689fe96a9
# @doc issingular

# ╔═╡ b28ac284-7f0d-11eb-2972-0d24bd3badbd
# issingular(fm2)

# ╔═╡ 43edf734-7f0e-11eb-1cd5-35cd2605a4b3
md"""
## Generalized Linear Mixed-Effects Models

"""

# ╔═╡ 4b63fe46-7f0e-11eb-3516-ffc1779cd2b4
md"""

In a [*generalized linear model*](https://en.wikipedia.org/wiki/Generalized_linear_model) the responses are modelled as coming from a particular distribution, such as `Bernoulli` for binary responses or `Poisson` for responses that represent counts.
The scalar distributions of individual responses differ only in their means, which are determined by a *linear predictor* expression $\eta=\bf X\beta$, where, as before, $\bf X$ is a model matrix derived from the values of covariates and $\beta$ is a vector of coefficients.

The unconstrained components of $\eta$ are mapped to the, possiby constrained, components of the mean response, $\mu$, via a scalar function, $g^{-1}$, applied to each component of $\eta$.
For historical reasons, the inverse of this function, taking components of $\mu$ to the corresponding component of $\eta$ is called the *link function* and the more frequently used map from $\eta$ to $\mu$ is the *inverse link*.

A *generalized linear mixed-effects model* (GLMM) is defined, for the purposes of this package, by
```math
\begin{aligned}
  (\mathcal{Y} | \mathcal{B}=\bf{b}) &\sim\mathcal{D}(\bf{g^{-1}(X\beta + Z b)},\phi)\\\\
  \mathcal{B}&\sim\mathcal{N}(\bf{0},\Sigma_\theta) .
\end{aligned}
```
where $\mathcal{D}$ indicates the distribution family parameterized by the mean and, when needed, a common scale parameter, $\phi$.
(There is no scale parameter for `Bernoulli` or for `Poisson`.
Specifying the mean completely determines the distribution.)
"""

# ╔═╡ 5c90c12c-7f0e-11eb-2e35-6b8c81decdd4
# @doc Bernoulli

# ╔═╡ 7a0f1c76-7f0e-11eb-15b0-d516d339f6ae
# @doc Poisson

# ╔═╡ 89de8452-7f0e-11eb-358b-5f2a34c252f8
md"""
A `GeneralizedLinearMixedModel` object is generated from a formula, data frame and distribution family.
"""

# ╔═╡ 8e48c7ee-7f0e-11eb-3ba2-99d5c231d74c
verbagg = MixedModels.dataset(:verbagg);

# ╔═╡ 9d2290e4-7f0e-11eb-2a98-59f4e41c2607
const vaform = @formula(r2 ~ 1 + anger + gender + btype + situ + (1|subj) + (1|item));

# ╔═╡ a0e117fa-7f0e-11eb-304b-63d17cd05c58
# mdl = GeneralizedLinearMixedModel(vaform, verbagg, Bernoulli());

# ╔═╡ a69fbbd0-7f0e-11eb-1a6e-0957f3ba0cb4
# typeof(mdl);

# ╔═╡ bc4bc4d6-7f0e-11eb-28e1-e75455a67412
md"""
A separate call to `fit!` can be used to fit the model.
This involves optimizing an objective function, the Laplace approximation to the deviance, with respect to the parameters, which are $\beta$, the fixed-effects coefficients, and $\theta$, the covariance parameters.
The starting estimate for $\beta$ is determined by fitting a GLM to the fixed-effects part of the formula
"""

# ╔═╡ 582960c4-7f10-11eb-1e70-8fb2c3ba3768
# mdl.β

# ╔═╡ 60b3fc6a-7f10-11eb-1e88-f5e492f8a8d7
md"""
and the starting estimate for $\theta$, which is a vector of the two standard deviations of the random effects, is chosen to be
"""

# ╔═╡ 684ffe86-7f10-11eb-1be4-d7a2df9c374b
# mdl.θ

# ╔═╡ 7028c944-7f10-11eb-171e-093ee285acd2
md"""
The Laplace approximation to the deviance requires determining the conditional modes of the random effects.
These are the values that maximize the conditional density of the random effects, given the model parameters and the data.
This is done using Penalized Iteratively Reweighted Least Squares (PIRLS).
In most cases PIRLS is fast and stable.
It is simply a penalized version of the IRLS algorithm used in fitting GLMs.

The distinction between the "fast" and "slow" algorithms in the `MixedModels` package (`nAGQ=0` or `nAGQ=1` in `lme4`) is whether the fixed-effects parameters, $\beta$, are optimized in PIRLS or in the nonlinear optimizer.
In a call to the `pirls!` function the first argument is a `GeneralizedLinearMixedModel`, which is modified during the function call.
(By convention, the names of such *mutating functions* end in `!` as a warning to the user that they can modify an argument, usually the first argument.)
The second and third arguments are optional logical values indicating if $\beta$ is to be varied and if verbose output is to be printed.
"""

# ╔═╡ b70d6f72-7f10-11eb-3d93-c7764f1f62f1
# @doc pirls!

# ╔═╡ 7e0f8714-7f10-11eb-3b07-27864aa7b24a
# pirls!(mdl, true, false)

# ╔═╡ d6427842-7f10-11eb-03d6-7502ec2a78c7
# deviance(mdl)

# ╔═╡ 3dc7efe2-7f11-11eb-24dc-c3690569363c
# mdl.β

# ╔═╡ 4344eba0-7f11-11eb-119c-2b6075247f76
# mdl.θ # current values of the standard deviations of the random effects

# ╔═╡ 549e6dea-7f11-11eb-025f-c5432e3b327d
md"""
If the optimization with respect to $\beta$ is performed within PIRLS then the nonlinear optimization of the Laplace approximation to the deviance requires optimization with respect to $\theta$ only.
This is the "fast" algorithm.
Given a value of $\theta$, PIRLS is used to determine the conditional estimate of $\beta$ and the conditional mode of the random effects, **b**.
"""

# ╔═╡ 5e7f0036-7f11-11eb-35ad-2b8380c11e6a
# mdl.b # conditional modes of b

# ╔═╡ 70ccf446-7f11-11eb-1ba9-1921f6142b17
# fit!(mdl, fast=true)

# ╔═╡ 88c6fa12-7f11-11eb-238a-2b08a8aa0bfd
md"""
The optimization process is summarized by
"""

# ╔═╡ 8c193f8e-7f11-11eb-39df-b7d239dbf841
# mdl.LMM.optsum

# ╔═╡ 9e3b5a12-7f11-11eb-235d-5fa61b69734a
md"""
As one would hope, given the name of the option, this fit is comparatively fast.
"""

# ╔═╡ af987696-7f11-11eb-09ff-6f4032063fb0
# @btime fit(MixedModel, vaform, verbagg, Bernoulli(), fast=true)

# ╔═╡ 05047468-7f12-11eb-1ffa-af98a616a491
md"""
The alternative algorithm is to use PIRLS to find the conditional mode of the random effects, given $\beta$ and $\theta$ and then use the general nonlinear optimizer to fit with respect to both $\beta$ and $\theta$.
"""

# ╔═╡ 6a5468fa-7f12-11eb-05b3-6363877352c4
# mdl1 = @btime fit(MixedModel, vaform, verbagg, Bernoulli())

# ╔═╡ 7305bec2-7f12-11eb-2a3c-7d6a4d17135f
md"""
This fit provided slightly better results (Laplace approximation to the deviance of 8151.400 versus 8151.583) but took 6 times as long.
That is not terribly important when the times involved are a few seconds but can be important when the fit requires many hours or days of computing time.
"""

# ╔═╡ Cell order:
# ╠═d4338852-7ee8-11eb-3875-b39a47953223
# ╠═21b9cb60-7eec-11eb-1509-c96fb86d8720
# ╠═affde242-7ee9-11eb-33a9-1f243834119f
# ╟─b579ff12-7ee9-11eb-1530-475e52a04b26
# ╟─c785c038-7ee9-11eb-3f5d-5dc76f60496a
# ╟─d0919954-7ee9-11eb-03a4-1d1a7c89ade9
# ╟─0bad79b8-7eea-11eb-257d-052e5f103deb
# ╟─1983b37c-7eea-11eb-1a6d-b7583fdc647a
# ╟─e7cf0e1a-7eeb-11eb-230d-572cd2710646
# ╟─ebc43efa-7eeb-11eb-35ae-d15dad5b4498
# ╠═fc715350-7eeb-11eb-00c3-1f7cf361258b
# ╠═9fb9dd78-7eec-11eb-18c9-3119cf3ca1e5
# ╠═0d642a1e-7eec-11eb-3486-1912b708d399
# ╟─36a4acf2-7eec-11eb-189a-0be24bdd7e3b
# ╠═fc6a590e-7eed-11eb-0b3a-3f04c9afd905
# ╠═42d11236-7eec-11eb-28b0-3523bec7cf69
# ╠═71377f82-7eec-11eb-3b21-5d0712895eca
# ╟─e4d41226-7eed-11eb-1ef7-f3aa3bdcc252
# ╠═ebb0bfd6-7eed-11eb-19ee-2711fdf75c6e
# ╟─40dfc8a8-7eee-11eb-0756-2d7cdc8b7671
# ╠═453bfb6a-7eee-11eb-15bd-a7c70c5a2358
# ╠═7cb1296c-7eee-11eb-04ce-2517fe6ad5ee
# ╠═95e02a6e-7eee-11eb-0c59-df12257fa1f3
# ╟─918b4f2a-7eee-11eb-2bc2-a551d3066cf8
# ╠═a53c5190-7eee-11eb-2f47-4ba6c47a8cba
# ╠═b6d76da4-7eee-11eb-04eb-8d498c004e76
# ╟─cb313730-7eee-11eb-0918-15ff0616d854
# ╠═d939b550-7eee-11eb-3a92-1fe7601cefbd
# ╟─06cc99d8-7eef-11eb-15b3-e1fb1938b10f
# ╠═0a6b2744-7eef-11eb-18f6-37561622f70f
# ╟─152905c0-7eef-11eb-0e41-df989efdfe5d
# ╠═365a208a-7eef-11eb-318d-73e49002cb97
# ╠═3a4a9742-7eef-11eb-2867-89721ab74991
# ╠═1955761a-7eef-11eb-3ca5-bdaf6c23d786
# ╟─944b1d98-7ef4-11eb-3201-0fac9dea87ca
# ╠═9d465c8e-7ef4-11eb-364d-fd20590721e2
# ╠═ab9e5050-7ef4-11eb-26d1-fb95c0b2cd49
# ╟─2aa51afa-7f09-11eb-0b65-7f0ebf7b6cae
# ╠═33a3d7ae-7f09-11eb-1900-853274cd6981
# ╠═409a9c84-7f09-11eb-0c56-7d543e7b4040
# ╠═63178bb6-7f09-11eb-3d64-5964a25ba8f3
# ╠═7054fd5e-7f09-11eb-2fc5-bd0dd33430c0
# ╠═8192db7c-7f09-11eb-1c71-8bd16ee36e13
# ╟─89df8ecc-7f09-11eb-150c-6315a3d173f9
# ╟─937dcac4-7f09-11eb-2d07-cb3f3f51681d
# ╟─ae4426ee-7f09-11eb-0077-0bfb03ca1219
# ╠═eecb3716-7f09-11eb-2eb6-210a010fd864
# ╟─0e20c13a-7f0a-11eb-2385-552637082d6e
# ╠═0703c3ca-7f0a-11eb-1b6f-0386cb52031a
# ╟─31f9b6b6-7f0a-11eb-1f1a-4b75f7fa9f20
# ╟─3933f3ec-7f0a-11eb-2477-5399522a963d
# ╠═54f21578-7f0a-11eb-0234-8f42e8c7f6b8
# ╠═626c23e4-7f0a-11eb-2152-f3385237d260
# ╟─db05a866-7f0a-11eb-3656-99a0f94f4042
# ╠═df6d3700-7f0a-11eb-3df1-d9149648188b
# ╠═0a9dad7e-7f0b-11eb-0b9c-3f1048992788
# ╟─3525a934-7f0b-11eb-0c36-0d55fa91a9ce
# ╠═1378efba-7f0d-11eb-14a7-c177f37dbecd
# ╟─2b4ab614-7f0d-11eb-3471-67c2b4030d5f
# ╟─33d7cc9a-7f0d-11eb-38c0-2dd8dc7f9948
# ╟─46493cc4-7f0d-11eb-34b9-67a1a91d1520
# ╠═50daf63c-7f0d-11eb-376e-db1365867656
# ╠═6e2c3c5a-7f0d-11eb-122a-cba6be178d39
# ╠═7d3d079c-7f0d-11eb-0347-ffb82cd25e5b
# ╟─90573528-7f0d-11eb-0569-d30d0c07a561
# ╟─9a301182-7f0d-11eb-3922-0323e01ae8ef
# ╟─9f987880-7f0d-11eb-1694-ade291db9fa9
# ╠═ac1e15ba-7f0d-11eb-3bcd-9f0689fe96a9
# ╠═b28ac284-7f0d-11eb-2972-0d24bd3badbd
# ╟─43edf734-7f0e-11eb-1cd5-35cd2605a4b3
# ╟─4b63fe46-7f0e-11eb-3516-ffc1779cd2b4
# ╠═5c90c12c-7f0e-11eb-2e35-6b8c81decdd4
# ╠═7a0f1c76-7f0e-11eb-15b0-d516d339f6ae
# ╟─89de8452-7f0e-11eb-358b-5f2a34c252f8
# ╠═8e48c7ee-7f0e-11eb-3ba2-99d5c231d74c
# ╠═9d2290e4-7f0e-11eb-2a98-59f4e41c2607
# ╠═a0e117fa-7f0e-11eb-304b-63d17cd05c58
# ╠═a69fbbd0-7f0e-11eb-1a6e-0957f3ba0cb4
# ╟─bc4bc4d6-7f0e-11eb-28e1-e75455a67412
# ╠═582960c4-7f10-11eb-1e70-8fb2c3ba3768
# ╟─60b3fc6a-7f10-11eb-1e88-f5e492f8a8d7
# ╠═684ffe86-7f10-11eb-1be4-d7a2df9c374b
# ╟─7028c944-7f10-11eb-171e-093ee285acd2
# ╠═b70d6f72-7f10-11eb-3d93-c7764f1f62f1
# ╠═7e0f8714-7f10-11eb-3b07-27864aa7b24a
# ╠═d6427842-7f10-11eb-03d6-7502ec2a78c7
# ╠═3dc7efe2-7f11-11eb-24dc-c3690569363c
# ╠═4344eba0-7f11-11eb-119c-2b6075247f76
# ╟─549e6dea-7f11-11eb-025f-c5432e3b327d
# ╠═5e7f0036-7f11-11eb-35ad-2b8380c11e6a
# ╠═70ccf446-7f11-11eb-1ba9-1921f6142b17
# ╟─88c6fa12-7f11-11eb-238a-2b08a8aa0bfd
# ╠═8c193f8e-7f11-11eb-39df-b7d239dbf841
# ╟─9e3b5a12-7f11-11eb-235d-5fa61b69734a
# ╠═af987696-7f11-11eb-09ff-6f4032063fb0
# ╟─05047468-7f12-11eb-1ffa-af98a616a491
# ╠═6a5468fa-7f12-11eb-05b3-6363877352c4
# ╟─7305bec2-7f12-11eb-2a3c-7d6a4d17135f
