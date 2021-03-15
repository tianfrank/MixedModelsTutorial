### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 852e35c2-7e9d-11eb-0dfc-33da770e3a69
using PlutoUI; TableOfContents()

# ╔═╡ 52cb502e-7e9d-11eb-3be6-671378e01345
md"""
# Julia Introduction
"""

# ╔═╡ 7376e680-7e9d-11eb-375a-e30dcdd5bb82
Resource("https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/b5551ca7946b4a25746c045c15fbb8806610f8d0/images/julia-logo-color.svg")

# ╔═╡ 940f8a64-7e9d-11eb-0da1-7b51cfaffe0b
md"""
### A Brief History
- 2009, [A brief history and wild speculation about the future of Julia](https://julialang.org/assets/blog/2018-08-08-one-point-zero/release-1.0-keynote.pdf)
- 2012-2-14, [Why we created Julia](https://julialang.org/blog/2012/02/why-we-created-julia/)
- 2018-8-18, [Release Julia 1.0](https://julialang.org/blog/2018/08/one-point-zero/)
- Now: V1.5.3, V1.7-DEV
"""

# ╔═╡ a4d1fa3a-7e9d-11eb-30cf-9d8e03255eb6
md"""
### The Basic Properties
- _Walks like Python, runs like C_.
- _Come for the syntax, stay for the speed_. [Nature](https://media.nature.com/original/magazine-assets/d41586-019-02310-3/d41586-019-02310-3.pdf)
"""

# ╔═╡ abb7aff2-7e9d-11eb-2999-d1d465ab47a5
# Resource("https://julialang.org/assets/benchmarks/benchmarks.svg")

# ╔═╡ c27c29c0-7e9d-11eb-1268-ade85d38c848
md"""
### Download and Install
- [The Julia Programming Language](https://julialang.org)
"""

# ╔═╡ 811cf738-7e9e-11eb-004b-d14a8e079b55
# using Pkg; Pkg.add()
# varinfo() # Main, Base, Core

# ╔═╡ c8317028-7e9d-11eb-215a-1f88ff61f950
md"""
# Mixed-effects models in Julia
"""

# ╔═╡ d1d0bb36-7e9d-11eb-0b9d-5fdf77d1eb2e
md"""
*MixedModels.jl* is a Julia package providing capabilities for fitting and examining linear and generalized linear mixed-effect models.
It is similar in scope to the [*lme4*](https://github.com/lme4/lme4) package for `R`.

This package defines linear mixed models (`LinearMixedModel`) and generalized linear mixed models (`GeneralizedLinearMixedModel`). Users can use the abstraction for statistical model API to build, fit (`fit`/`fit!`), and query the fitted models.

A _mixed-effects model_ is a statistical model for a _response_ variable as a function of one or more _covariates_. For a categorical covariate the coefficients associated with the levels of the covariate are sometimes called _effects_, as in "the effect of using Treatment 1 versus the placebo". If the potential levels of the covariate are fixed and reproducible, e.g. the levels for `Sex` could be `"F"` and `"M"`, they are modeled with _fixed-effects_ parameters. If the levels constitute a sample from a population, e.g. the `Subject` or the `Item` at a particular observation, they are modeled as _random effects_.

A _mixed-effects_ model contains both fixed-effects and random-effects terms. With fixed-effects it is the coefficients themselves or combinations of coefficients that are of interest. For random effects it is the variability of the effects over the population that is of interest.

In this package random effects are modeled as independent samples from a multivariate Gaussian distribution of the form 𝓑 ~ 𝓝(0, 𝚺). For the response vector, 𝐲, only the mean of conditional distribution, 𝓨|𝓑 = 𝐛 depends on 𝐛 and it does so through a _linear predictor expression_, 𝛈 = 𝐗𝛃 + 𝐙𝐛, where 𝛃 is the fixed-effects coefficient vector and 𝐗 and 𝐙 are model matrices of the appropriate sizes.

In a `LinearMixedModel` the conditional mean, 𝛍 = 𝔼[𝓨|𝓑 = 𝐛], is the linear predictor, 𝛈, and the conditional distribution is multivariate Gaussian, (𝓨|𝓑 = 𝐛) ~ 𝓝(𝛍, σ²𝐈).

In a `GeneralizedLinearMixedModel`, the conditional mean, 𝔼[𝓨|𝓑 = 𝐛], is related to the linear predictor via a _link function_. ·Typical distribution forms are _Bernoulli_ for binary data or _Poisson_ for count data.
"""

# ╔═╡ Cell order:
# ╟─852e35c2-7e9d-11eb-0dfc-33da770e3a69
# ╟─52cb502e-7e9d-11eb-3be6-671378e01345
# ╟─7376e680-7e9d-11eb-375a-e30dcdd5bb82
# ╟─940f8a64-7e9d-11eb-0da1-7b51cfaffe0b
# ╟─a4d1fa3a-7e9d-11eb-30cf-9d8e03255eb6
# ╠═abb7aff2-7e9d-11eb-2999-d1d465ab47a5
# ╟─c27c29c0-7e9d-11eb-1268-ade85d38c848
# ╠═811cf738-7e9e-11eb-004b-d14a8e079b55
# ╟─c8317028-7e9d-11eb-215a-1f88ff61f950
# ╟─d1d0bb36-7e9d-11eb-0b9d-5fdf77d1eb2e
