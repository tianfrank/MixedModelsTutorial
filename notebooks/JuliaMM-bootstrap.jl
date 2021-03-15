### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 2afaf4c0-7f13-11eb-1bd9-254bb5a7acaf
begin
using MixedModels
import Random: MersenneTwister
import DataFrames: DataFrame
# import DataFramesMeta: @where
using DataFramesMeta
import Plots: plot, histogram
import StatsPlots: density
using Pipe
end

# ╔═╡ 066826a0-7f13-11eb-187d-a7b9929115aa
md"""
# Parametric bootstrap for mixed-effects models
"""

# ╔═╡ 1787c88c-7f13-11eb-2d7b-b722cce2d780
md"""
Julia is well-suited to implementing bootstrapping and other simulation-based methods for statistical models.
The `parametricbootstrap` function in the [MixedModels package](https://github.com/JuliaStats/MixedModels.jl) provides an efficient parametric bootstrap for mixed-effects models.
"""

# ╔═╡ 2077547e-7f13-11eb-08f9-15964ccbfa89
# @doc parametricbootstrap

# ╔═╡ 6b2980e8-7f13-11eb-1935-d787fae56564
md"""
## The parametric bootstrap
"""

# ╔═╡ 718db832-7f13-11eb-2db1-476785d77994
md"""
[Bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) is a family of procedures
for generating sample values of a statistic, allowing for visualization of the distribution of the
statistic or for inference from this sample of values.

A _parametric bootstrap_ is used with a parametric model, `m`, that has been fit to data.
The procedure is to simulate `n` response vectors from `m` using the estimated parameter values
and refit `m` to these responses in turn, accumulating the statistics of interest at each iteration.

The parameters of a `LinearMixedModel` object are the fixed-effects
parameters, `β`, the standard deviation, `σ`, of the per-observation noise, and the covariance
parameter, `θ`, that defines the variance-covariance matrices of the random effects.

For example, a simple linear mixed-effects model for the `Dyestuff` data in the [`lme4`](http://github.com/lme4/lme4)
package for [`R`](https://www.r-project.org) is fit by
"""

# ╔═╡ 940bc928-7f13-11eb-188c-ed2565ffc4c1
# dyestuff = MixedModels.dataset(:dyestuff);

# ╔═╡ a2a3ccae-7f13-11eb-2d45-0984e06d9102
# m1 = fit(MixedModel, @formula(yield ~ 1 + (1 | batch)), dyestuff);

# ╔═╡ bc2e8506-7f13-11eb-0b9a-df190d074698
# const rng = MersenneTwister(1234321);

# ╔═╡ dd66717a-7f13-11eb-38b4-918c18dbebd0
# samp = parametricbootstrap(rng, 10_000, m1);

# ╔═╡ e7a3ab80-7f13-11eb-184f-55330578f8a8
# df = DataFrame(samp.allpars);

# ╔═╡ ea9dd450-7f13-11eb-2544-19c49f8da0fb
# first(df, 10);

# ╔═╡ 058c5b88-7f14-11eb-20e7-75f6f2c2accc
md"""
Especially for those with a background in [`R`](https://www.R-project.org/) or [`pandas`](https://pandas.pydata.org),
the simplest way of accessing the parameter estimates in the parametric bootstrap object is to create a `DataFrame` from the `allpars` property as shown above.

The [`DataFramesMeta`](https://github.com/JuliaData/DataFramesMeta.jl) package provides macros for extracting rows or columns of a dataframe.
A density plot of the estimates of `σ`, the residual standard deviation, can be created as
"""

# ╔═╡ 0fbdc5ce-7f14-11eb-17d1-77532017a207
# σres = @where(df, :type .== "σ", :group .== "residual").value;

# ╔═╡ 739e3c5e-7f14-11eb-20bf-9d2381b4e714
# density(σres, xlab = "Parametric bootstrap estimates of σ")

# ╔═╡ d5cbbff4-7f15-11eb-2c22-d7ac50d56654
md"""
For the estimates of the intercept parameter, the `getproperty` extractor must be used
"""

# ╔═╡ 60f035c4-7f16-11eb-2090-57b2d9a3ca7c
# βres = @where(df, :type .== "β").value;

# ╔═╡ 533b1bfc-7f15-11eb-3b00-6b84be8ff510
# density(βres, xlab = "Parametric bootstrap estimates of β₁")

# ╔═╡ 3c028b5e-7f16-11eb-0e8d-6fd8f0ff618c
md"""
A density plot of the estimates of the standard deviation of the random effects is obtained as
"""

# ╔═╡ 2ca6ca62-7f16-11eb-0c01-8bdf4a71ab19
# σbatch = @where(df, :type .== "σ", :group .== "batch").value;

# ╔═╡ 6d4dc534-7f16-11eb-0989-ff533948b9ed
# density(σbatch, xlab = "Parametric bootstrap estimates of σ₁")

# ╔═╡ adebd806-7f16-11eb-0fe1-3305270c173a
md"""
Notice that this density plot has a spike, or mode, at zero.
Although this mode appears to be diffuse, this is an artifact of the way that density plots are created.
In fact, it is a pulse, as can be seen from a histogram.
"""

# ╔═╡ b2d3899a-7f16-11eb-3e2a-49e79d9cec1b
# histogram(σbatch, xlab = "Parametric bootstrap estimates of σ₁", legend = false)

# ╔═╡ 7ba04976-7f17-11eb-118d-f1d49c221a5c
md"""
The bootstrap sample can be used to generate intervals that cover a certain percentage of the bootstrapped values.
We refer to these as "coverage intervals", similar to a confidence interval.
The shortest such intervals, obtained with the `shortestcovint` extractor, correspond to a highest posterior density interval in Bayesian inference.
"""

# ╔═╡ 823d0dd2-7f17-11eb-0983-ef010a37dd31
# @doc shortestcovint

# ╔═╡ 6837dec8-7f24-11eb-3c04-61aa9e94c345
# @pipe df |>
# 	groupby(_, [:type, :group, :names]) |> 
# 	combine(_, :value => shortestcovint => :interval)

# ╔═╡ 76c15db6-7f24-11eb-1ebb-cdc83ec5874e
md"""
A value of zero for the standard deviation of the random effects is an example of a *singular* covariance.
It is easy to detect the singularity in the case of a scalar random-effects term.
However, it is not as straightforward to detect singularity in vector-valued random-effects terms.

For example, if we bootstrap a model fit to the `sleepstudy` data
"""

# ╔═╡ 6382c4b4-7f25-11eb-1420-e7e046784e8c
# sleepstudy = MixedModels.dataset(:sleepstudy);

# ╔═╡ 9d7fe746-7f25-11eb-269d-659c34e319f5
# m2 = fit(MixedModel, @formula(reaction ~ 1+days+(1+days|subj)), sleepstudy);

# ╔═╡ b052cd2a-7f25-11eb-186d-2936bd1c7ba9
# samp2 = parametricbootstrap(rng, 10_000, m2, use_threads=true);

# ╔═╡ 12d946f2-7f26-11eb-0cd4-ff611d08ad74
# df2 = DataFrame(samp2.allpars);

# ╔═╡ 26d21208-7f26-11eb-350b-975d27a43b75
# first(df2, 10);

# ╔═╡ 5bdc34d8-7f26-11eb-2330-99447d1cf9ff
md"""
the singularity can be exhibited as a standard deviation of zero or as a correlation of $\pm1$.
"""

# ╔═╡ 6279001e-7f26-11eb-361a-0184f52585d9
# combine(groupby(df2, [:type, :group, :names]), :value => shortestcovint => :interval)

# ╔═╡ 8e62a5ec-7f26-11eb-1c61-97e4b139d05a
md"""
A histogram of the estimated correlations from the bootstrap sample has a spike at `+1`.
"""

# ╔═╡ 9222f2e8-7f26-11eb-253f-2bd46f2947cb
# ρs = @where(df2, :type .== "ρ", :group .== "subj").value;

# ╔═╡ a5c1455c-7f26-11eb-3d06-bd418b7b9f46
# histogram(ρs, xlab = "Parametric bootstrap samples of correlation of random effects", label = false)

# ╔═╡ 2c151338-7f27-11eb-260c-7fe5c6f491a2
md"""
or, as a count,
"""

# ╔═╡ 3029cf68-7f27-11eb-061f-c33f07910322
# sum(ρs .≈ 1)

# ╔═╡ 34f1e1fa-7f27-11eb-0b91-415d28da963a
md"""
Close examination of the histogram shows a few values of `-1`.
"""

# ╔═╡ 3f38c9b2-7f27-11eb-01aa-2b6d4e6c1fc0
# sum(ρs .≈ -1)

# ╔═╡ 4596ff18-7f27-11eb-37df-877affee9ed7
md"""
Furthermore there are even a few cases where the estimate of the standard deviation of the random effect for the intercept is zero.
"""

# ╔═╡ 4d407884-7f27-11eb-2795-d567c0c6a93d
# σs = @where(df2, :type .== "σ", :group .== "subj", :names .== "(ntercept)").value

# ╔═╡ 619e5b18-7f27-11eb-2d96-0302d3dafc54
# sum(σs .≈ 0)

# ╔═╡ 6c75fd28-7f27-11eb-0663-d3d63598446a
md"""
There is a general condition to check for singularity of an estimated covariance matrix or matrices in a bootstrap sample.
The parameter optimized in the estimation is `θ`, the relative covariance parameter.
Some of the elements of this parameter vector must be non-negative and, when one of these components is approximately zero, one of the covariance matrices will be singular.

The `issingular` method for a `MixedModel` object that tests if a parameter vector `θ` corresponds to a boundary or singular fit.

This operation is encapsulated in a method for the `issingular` 
"""

# ╔═╡ 7370a798-7f27-11eb-27a6-513e6b014e13
# sum(issingular(samp2))

# ╔═╡ Cell order:
# ╠═2afaf4c0-7f13-11eb-1bd9-254bb5a7acaf
# ╟─066826a0-7f13-11eb-187d-a7b9929115aa
# ╟─1787c88c-7f13-11eb-2d7b-b722cce2d780
# ╠═2077547e-7f13-11eb-08f9-15964ccbfa89
# ╟─6b2980e8-7f13-11eb-1935-d787fae56564
# ╟─718db832-7f13-11eb-2db1-476785d77994
# ╠═940bc928-7f13-11eb-188c-ed2565ffc4c1
# ╠═a2a3ccae-7f13-11eb-2d45-0984e06d9102
# ╠═bc2e8506-7f13-11eb-0b9a-df190d074698
# ╠═dd66717a-7f13-11eb-38b4-918c18dbebd0
# ╠═e7a3ab80-7f13-11eb-184f-55330578f8a8
# ╠═ea9dd450-7f13-11eb-2544-19c49f8da0fb
# ╟─058c5b88-7f14-11eb-20e7-75f6f2c2accc
# ╠═0fbdc5ce-7f14-11eb-17d1-77532017a207
# ╠═739e3c5e-7f14-11eb-20bf-9d2381b4e714
# ╟─d5cbbff4-7f15-11eb-2c22-d7ac50d56654
# ╠═60f035c4-7f16-11eb-2090-57b2d9a3ca7c
# ╠═533b1bfc-7f15-11eb-3b00-6b84be8ff510
# ╟─3c028b5e-7f16-11eb-0e8d-6fd8f0ff618c
# ╠═2ca6ca62-7f16-11eb-0c01-8bdf4a71ab19
# ╠═6d4dc534-7f16-11eb-0989-ff533948b9ed
# ╟─adebd806-7f16-11eb-0fe1-3305270c173a
# ╠═b2d3899a-7f16-11eb-3e2a-49e79d9cec1b
# ╟─7ba04976-7f17-11eb-118d-f1d49c221a5c
# ╠═823d0dd2-7f17-11eb-0983-ef010a37dd31
# ╠═6837dec8-7f24-11eb-3c04-61aa9e94c345
# ╟─76c15db6-7f24-11eb-1ebb-cdc83ec5874e
# ╠═6382c4b4-7f25-11eb-1420-e7e046784e8c
# ╠═9d7fe746-7f25-11eb-269d-659c34e319f5
# ╠═b052cd2a-7f25-11eb-186d-2936bd1c7ba9
# ╠═12d946f2-7f26-11eb-0cd4-ff611d08ad74
# ╠═26d21208-7f26-11eb-350b-975d27a43b75
# ╟─5bdc34d8-7f26-11eb-2330-99447d1cf9ff
# ╠═6279001e-7f26-11eb-361a-0184f52585d9
# ╟─8e62a5ec-7f26-11eb-1c61-97e4b139d05a
# ╠═9222f2e8-7f26-11eb-253f-2bd46f2947cb
# ╠═a5c1455c-7f26-11eb-3d06-bd418b7b9f46
# ╟─2c151338-7f27-11eb-260c-7fe5c6f491a2
# ╠═3029cf68-7f27-11eb-061f-c33f07910322
# ╟─34f1e1fa-7f27-11eb-0b91-415d28da963a
# ╠═3f38c9b2-7f27-11eb-01aa-2b6d4e6c1fc0
# ╟─4596ff18-7f27-11eb-37df-877affee9ed7
# ╠═4d407884-7f27-11eb-2795-d567c0c6a93d
# ╠═619e5b18-7f27-11eb-2d96-0302d3dafc54
# ╟─6c75fd28-7f27-11eb-0663-d3d63598446a
# ╠═7370a798-7f27-11eb-27a6-513e6b014e13
