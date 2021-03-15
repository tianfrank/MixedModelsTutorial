### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9ed028fa-7f31-11eb-11bc-a1cc190a955f
using PlutoUI

# ╔═╡ f7cac330-7f32-11eb-29df-772bc2491a20
using MixedModels, DisplayAs, DataFrames, FreqTables

# ╔═╡ a3529796-7f31-11eb-1824-e3d960695b29
TableOfContents()

# ╔═╡ d7a4e13a-7f28-11eb-2e33-4dad6595372f
md"""
# Rank deficiency in mixed-effects models

"""

# ╔═╡ e716e50c-7f28-11eb-2b61-d58e10c7c630
md"""
The *(column) rank* of a matrix refers to the number of linearly independent columns in the matrix.
Clearly, the rank can never be more than the number of columns; however, the rank can be less than the number of columns.
In a regression context, this corresponds to a (linear) dependency in the predictors.
The simplest case of rank deficiency is a duplicated predictor or a predictor that is exactly a multiple of another predictor.
However, rank deficiency can also arise in more subtle ways, such as from missing cells in a two-factor experimental design.
Rank deficiency can also arise as an extreme case of multicollinearity.
In all cases, it is important to remember that we can only assess the numerical rank of a matrix, which may be less than its theoretical rank, and that evaluation of this numerical rank requires setting some numerical tolerance levels.
These choices are not always well defined.
In other words, the rank of a matrix is well-defined in theory but in practice can be difficult to evaluate.

Rank deficiency can occur in two ways in mixed-effects models: in the fixed effects and in the random effects.
The implications of rank deficiency and thus the handling of it differ between these.
"""

# ╔═╡ 7cb330aa-7f29-11eb-3ed0-fb9841b0362a
md"""
## Fixed effects
"""

# ╔═╡ 804a694a-7f29-11eb-0f44-59e6fbaa6288
md"""
The consequences of rank deficiency in the fixed effects are similar to those in classical ordinary least squares (OLS) regression.
If one or more predictors can be expressed as a linear combination of the other columns, then this column is redundant and the model matrix is rank deficient.
Note however, that the redundant column is not defined uniquely.
For example, in the case that of two columns `a` and `b` where `b = 2a`, then the rank deficiency can be handled by eliminating either `a` or `b`.
While we defined `b` here in terms of `a`, it may be that `b` is actually the more 'fundamental' predictor and hence we may define  `a` in terms of `b` as `a = 0.5b`.
The user may of course possess this information, but the choice is not apparent to the modelling software.
As such, the handling of rank deficiency in `MixedModels.jl` should not be taken as a replacement for thinking about the nature of the predictors in a given model.

There is a widely accepted convention for how to make the coefficient estimates for these redundant columns well-defined: we set their value to zero and their standard errors to `NaN` (and thus also their $z$ and $p$-values).
The values that have been defined to be zero, as opposed to evaluating to zero, are displayed as `-0.0` as an additional visual aid to distinguish them from the other coefficients.
In practice the determination of rank and the redundant coefficients is done via a 'pivoting' scheme during a decomposition to
move the surplus columns to the right side of the model matrix.
In subsequent calculations, these columns are effectively ignored (as their estimates are zero and thus won't contribute to any other computations).
For display purposes, this pivoting is unwound when the `coef` values are displayed.

Both the pivoted and unpivoted coefficients are available in MixedModels.
The `fixef` extractor returns the pivoted, truncated estimates (i.e. the non redundant terms), while the `coef` extractor returns the unpivoted estimates (i.e. all terms, included the redundant ones).
The same holds for the associated `fixefnames` and `coefnames`.
"""

# ╔═╡ 3946fbae-7f32-11eb-0277-dfb76f85b0ba
md"""
### Pivoting is platform dependent
"""

# ╔═╡ 438849c4-7f32-11eb-3cb4-c91987141ec5
md"""
In MixedModels.jl, we use standard numerical techniques to detect rank deficiency.
We currently offer no guarantees as to which exactly of the standard techniques (pivoted QR decomposition, pivoted Cholesky decomposition, etc.) will be used.
This choice should be viewed as an implementation detail.
Similarly, we offer no guarantees as to which of columns will be treated as redundant.
This choice may vary between releases and even between platforms (both in broad strokes of "Linux" vs. "Windows" and at the level of which BLAS options are loaded on a given processor architecture) for the same release.
In other words, *you should not rely on the order of the pivoted columns being consistent!* when you switch to a different computer or a different operating system.
If consistency in the pivoted columns is important to you, then you should instead determine your rank ahead of time and remove extraneous columns / predictors from your model specification.

This lack of consistency guarantees arises from a more fundamental issue: numeric linear algebra is challenging and sensitive to the underlying floating point operations.
Due to rounding error, floating point arithmetic is not associative:
"""

# ╔═╡ 7ed16240-7f32-11eb-364a-1b37aa29e20d
0.1 + 0.1 + 0.1 - 0.3 == 0.1 + 0.1 + (0.1 - 0.3)

# ╔═╡ 90aee8a2-7f32-11eb-3234-53e55340c82b
md"""
This means that "nearly" / numerically rank deficient matrices may or may not be detected as rank deficient, depending on details of the platform.
Determining the rank of a matrix is the type of problem that is well-defined in theory but not in practice.

Currently, a coarse heuristic is applied to reduce the chance that the intercept column will be pivoted, but even this behavior is not guaranteed.
"""

# ╔═╡ a673b76c-7f32-11eb-0216-9940edb8c1ec
md"""
### Undetected Rank Deficiency
"""

# ╔═╡ aeb321b0-7f32-11eb-3500-a9ac65054199
md"""
Undetected rank deficiency in the fixed effects will lead to numerical issues, such as nonsensical estimates.
A `PosDefException` may indicate rank deficiency because the covariance matrix will only be positive semidefinite and not positive definite (see [Details of the parameter estimation](@ref)).
In other words, checking that the fixed effects are full rank is a great first step in debugging a `PosDefException`.

Note that `PosDefException` is not specific to rank deficiency and may arise in other ill-conditioned models.
In any case, examining the model specification and the data to verify that they work together is the first step.
For generalized linear mixed-effects models, it may also be worthwhile to try out `fast=true` instead of the default `fast=false`.
See this [GitHub issue](https://github.com/JuliaStats/MixedModels.jl/issues/349) and linked Discourse discussion for more information.
"""

# ╔═╡ d1ddbd94-7f32-11eb-3824-c953afe7b157
md"""
## Random effects

"""

# ╔═╡ da06b16a-7f32-11eb-07c5-916a48d68a59
md"""
Rank deficiency presents less of a problem in the random effects than in the fixed effects because the "estimates" (more formally, the conditional modes of the random effects given the observed data) are determined as the solution to a penalized least squares problem.
The *shrinkage* effect which moves the conditional modes (group-level predictions) towards the grand mean is a form of *regularization*, which provides well-defined "estimates" for overparameterized models.
(For more reading on this general idea, see also this [blog post](https://jakevdp.github.io/blog/2015/07/06/model-complexity-myth/) on the model complexity myth.)

The nature of the penalty in the penalized least squares solution is such that the "estimates" are well-defined even when the covariance matrix of the random effects converges to a "singular" or "boundary" value.
In other words, singularity of the covariance matrix for the random effects, which means that there are one or more directions in which there is no variability in the random effects, is different from singularity of the model matrix for the random effects, which would affect the ability to define uniquely these coefficients.
The penalty term always provides a unique solution for the random-effects coefficients.

In addition to handling naturally occurring rank deficiency in the random effects, the regularization allows us to fit explicitly overparameterized random effects.
For example, we can use `fulldummy` to fit both an intercept term and $n$ indicator variables in the random effects for a categorical variable with $n$ levels instead of the usual $n-1$ contrasts.
"""

# ╔═╡ e7790212-7f32-11eb-34c0-af9bb9bc0735
kb07 = MixedModels.dataset(:kb07) |> DataFrame;

# ╔═╡ 874d5a86-7f33-11eb-30c7-2367931c5582
freqtable(kb07, :prec).array

# ╔═╡ 04a4f544-7f33-11eb-20e4-7dc3b160364b
contrasts = Dict(var => HelmertCoding() for var in (:spkr, :prec, :load));

# ╔═╡ 1b247e3e-7f33-11eb-0a57-1f46fa1fee6a
fm1 = fit(MixedModel, @formula(rt_raw ~ spkr * prec * load + (1|subj) + (1+prec|item)), kb07; contrasts=contrasts);

# ╔═╡ 4d4e68be-7f33-11eb-00c7-d13d3938f476
DisplayAs.Text(fm1)

# ╔═╡ 2a3b918c-7f33-11eb-3ddf-cb77f716a764
fm2 = fit(MixedModel, @formula(rt_raw ~ spkr * prec * load + (1|subj) + (1+fulldummy(prec)|item)), kb07; contrasts=contrasts);

# ╔═╡ 6d5a78cc-7f33-11eb-1763-0dc518c9df30
DisplayAs.Text(fm2)

# ╔═╡ b180613e-7f33-11eb-3dea-3b5d2dad7f7f
md"""
This may be useful when the `PCA` property suggests a random effects structure larger than only main effects but smaller than all interaction terms.
This is also similar to the functionality provided by `dummy` in `lme4`, but as in the difference between `zerocorr` in Julia and `||` in R, there are subtle differences in how this expansion interacts with other terms in the random effects.
"""

# ╔═╡ Cell order:
# ╠═9ed028fa-7f31-11eb-11bc-a1cc190a955f
# ╟─a3529796-7f31-11eb-1824-e3d960695b29
# ╟─d7a4e13a-7f28-11eb-2e33-4dad6595372f
# ╟─e716e50c-7f28-11eb-2b61-d58e10c7c630
# ╟─7cb330aa-7f29-11eb-3ed0-fb9841b0362a
# ╟─804a694a-7f29-11eb-0f44-59e6fbaa6288
# ╟─3946fbae-7f32-11eb-0277-dfb76f85b0ba
# ╟─438849c4-7f32-11eb-3cb4-c91987141ec5
# ╠═7ed16240-7f32-11eb-364a-1b37aa29e20d
# ╟─90aee8a2-7f32-11eb-3234-53e55340c82b
# ╟─a673b76c-7f32-11eb-0216-9940edb8c1ec
# ╟─aeb321b0-7f32-11eb-3500-a9ac65054199
# ╟─d1ddbd94-7f32-11eb-3824-c953afe7b157
# ╟─da06b16a-7f32-11eb-07c5-916a48d68a59
# ╠═f7cac330-7f32-11eb-29df-772bc2491a20
# ╠═e7790212-7f32-11eb-34c0-af9bb9bc0735
# ╠═874d5a86-7f33-11eb-30c7-2367931c5582
# ╠═04a4f544-7f33-11eb-20e4-7dc3b160364b
# ╠═1b247e3e-7f33-11eb-0a57-1f46fa1fee6a
# ╠═4d4e68be-7f33-11eb-00c7-d13d3938f476
# ╠═2a3b918c-7f33-11eb-3ddf-cb77f716a764
# ╠═6d5a78cc-7f33-11eb-1763-0dc518c9df30
# ╟─b180613e-7f33-11eb-3dea-3b5d2dad7f7f
