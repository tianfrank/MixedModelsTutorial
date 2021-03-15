### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 370be012-7fae-11eb-3467-05a964507c61
using DataFrames#: DataFrame

# ╔═╡ 949007e2-7fb1-11eb-0c33-dbeb6b34e98c
using StatsPlots#: @df

# ╔═╡ fe29e020-7fba-11eb-0741-3194a34abd3c
using FreqTables

# ╔═╡ 09fa2c08-7f38-11eb-3284-051d4364ef3d
using LinearAlgebra

# ╔═╡ 8418480a-7f9f-11eb-37b0-c1d867794c8b
using MixedModels

# ╔═╡ 582f5f76-7fae-11eb-2bf3-29d1022a5f52
using Gadfly

# ╔═╡ 0057d0a4-7fb7-11eb-1c14-a399f32f50de
using MixedModels: block

# ╔═╡ d1ce0aca-7f37-11eb-159e-e700e273ade5
md"""
# Normalized Gauss-Hermite Quadrature

"""

# ╔═╡ dc8aa540-7f37-11eb-2c56-4d7f5549d8a2
md"""
[*Gaussian Quadrature rules*](https://en.wikipedia.org/wiki/Gaussian_quadrature) provide sets of `x` values, called *abscissae*, and corresponding weights, `w`, to approximate an integral with respect to a *weight function*, $g(x)$.
For a `k`th order rule the approximation is
```math
\int f(x)g(x)\,dx \approx \sum_{i=1}^k w_i f(x_i)
```

For the *Gauss-Hermite* rule the weight function is
```math
g(x) = e^{-x^2}
```

and the domain of integration is $(-\infty, \infty)$.
A slight variation of this is the *normalized Gauss-Hermite* rule for which the weight function is the standard normal density
```math
g(z) = \phi(z) = \frac{e^{-z^2/2}}{\sqrt{2\pi}}
```

Thus, the expected value of $f(z)$, where $\mathcal{Z}\sim\mathscr{N}(0,1)$, is approximated as
```math
\mathbb{E}[f]=\int_{-\infty}^{\infty} f(z) \phi(z)\,dz\approx\sum_{i=1}^k w_i\,f(z_i) .
```

Naturally, there is a caveat. For the approximation to be accurate the function $f(z)$ must behave like a low-order polynomial over the range of interest.
More formally, a `k`th order rule is exact when `f` is a `k-1` order polynomial.
"""

# ╔═╡ ee9479be-7f37-11eb-074a-ad7866940be8
md"""
## Evaluating the weights and abscissae

"""

# ╔═╡ fff62c16-7f37-11eb-1e20-63d16ac9904f
md"""
In the [*Golub-Welsch algorithm*](https://en.wikipedia.org/wiki/Gaussian_quadrature#The_Golub-Welsch_algorithm) the abscissae for a particular Gaussian quadrature rule are determined as the eigenvalues of a symmetric tridiagonal matrix and the weights are derived from the squares of the first row of the matrix of eigenvectors.
For a `k`th order normalized Gauss-Hermite rule the tridiagonal matrix has zeros on the diagonal and the square roots of `1:k-1` on the super- and sub-diagonal, e.g.
"""

# ╔═╡ 39f4a98e-7f39-11eb-1cfb-b1e880da12e4
sym3 = SymTridiagonal(zeros(3), sqrt.(1:2))

# ╔═╡ 4fb577d8-7f39-11eb-2047-ffe2be9dba88
ev = eigen(sym3)

# ╔═╡ df274322-7f9f-11eb-0d36-6f5a111f179a
abs2.(ev.vectors[1, :])

# ╔═╡ d6a79224-7f9f-11eb-00d2-1b448059ad5a
abs2.(ev.vectors[1, :])

# ╔═╡ 72775048-7f39-11eb-0168-450d9f1b82e3
md"""
As a function of `k` this can be written as
"""

# ╔═╡ 770491ca-7f39-11eb-0287-756f418d8dda
function gausshermitenorm(k)
    ev = eigen(SymTridiagonal(zeros(k), sqrt.(1:k-1)))
    ev.values, abs2.(ev.vectors[1,:])
end

# ╔═╡ 88dc35b0-7f39-11eb-3f92-6f3ba34315dd
md"""
providing
"""

# ╔═╡ 91b28a40-7f39-11eb-389d-cfb3d4a7bc96
gausshermitenorm(3)

# ╔═╡ a2305e60-7f39-11eb-1fd0-f1fdde485318
md"""
The weights and positions are often shown as a *lollipop plot*.
For the 9th order rule these are
"""

# ╔═╡ f034fa70-7f9c-11eb-1f51-79308903966c
gh9 = gausshermitenorm(9);

# ╔═╡ af51cf10-7f3a-11eb-0d09-09e126b986d5
Gadfly.plot(x=gh9[1], y=gh9[2], Geom.hair, Geom.point, Guide.ylabel("Weight"), Guide.xlabel(""))

# ╔═╡ 96f96192-7f9b-11eb-06dc-afd8305697bf
md"""
Notice that the magnitudes of the weights drop quite dramatically away from zero, even on a logarithmic scale

"""

# ╔═╡ c1d0a0e6-7f9c-11eb-1807-7bbfb0b69fde
Gadfly.plot(x=gh9[1], y=gh9[2], Geom.hair, Geom.point, Scale.y_log2, Guide.ylabel("Weight (log scale)"), Guide.xlabel(""))

# ╔═╡ 0ee7530a-7f9f-11eb-0d29-3ffc8a08b743
md"""
The definition of `MixedModels.GHnorm` is similar to the `gausshermitenorm` function with some extra provisions for ensuring symmetry of the abscissae and the weights and for caching values once they have been calculated.

"""

# ╔═╡ 4bc3f378-7f9f-11eb-11b0-8f1f03c73722
@doc GHnorm

# ╔═╡ 79d4447a-7f9f-11eb-1db9-a55b4faafa04
GHnorm(3)

# ╔═╡ 93723e64-7f9f-11eb-3f96-dff738aed80a
md"""
By the properties of the normal distribution, when $\mathcal{X}\sim\mathscr{N}(\mu, \sigma^2)$
```math
\mathbb{E}[g(x)] \approx \sum_{i=1}^k g(\mu + \sigma z_i)\,w_i
```

For example, $\mathbb{E}[\mathcal{X}^2]$ where $\mathcal{X}\sim\mathcal{N}(2, 3^2)$ is
"""

# ╔═╡ f0d58dfa-7fad-11eb-318f-2f4e115f2c25
μ = 2; σ = 3; ghn3 = GHnorm(3);

# ╔═╡ f608a622-7fad-11eb-1d2b-857376de6774
sum(@. ghn3.w * abs2(μ + σ * ghn3.z))  # should be μ² + σ² = 13

# ╔═╡ 0109c13c-7fae-11eb-0c80-f15e77994d27
md"""

(In general a dot, '`.`', after the function name in a function call, as in `abs2.(...)`, or before an operator creates a [*fused vectorized*](https://docs.julialang.org/en/stable/manual/performance-tips/#More-dots:-Fuse-vectorized-operations-1) evaluation in Julia.
The macro `@.` has the effect of vectorizing all operations in the subsequent expression.)
"""

# ╔═╡ 1f81ec70-7fae-11eb-15c9-350fd3dc3aa5
md"""
## Application to a model for contraception use

"""

# ╔═╡ 0e4c3280-7fae-11eb-25c7-67ca4864cd7a
md"""
A *binary response* is a "Yes"/"No" type of answer.
For example, in a 1989 fertility survey of women in Bangladesh (reported in [Huq, N. M. and Cleland, J., 1990](https://www.popline.org/node/371841)) one response of interest was whether the woman used artificial contraception.
Several covariates were recorded including the woman's age (centered at the mean), the number of live children the woman has had (in 4 categories: 0, 1, 2, and 3 or more), whether she lived in an urban setting, and the district in which she lived.
The version of the data used here is that used in review of multilevel modeling software conducted by the Center for Multilevel Modelling, currently at University of Bristol (http://www.bristol.ac.uk/cmm/learning/mmsoftware/data-rev.html).
These data are available as the `:contra` dataset.
"""

# ╔═╡ 291e0eda-7fae-11eb-0568-b127160abf32
contra = DataFrame(MixedModels.dataset(:contra));

# ╔═╡ 513b2b46-7fae-11eb-0863-a33f2a581040
md"""
A smoothed scatterplot of contraception use versus age

"""

# ╔═╡ 1df7a9a2-7fb9-11eb-1d11-d1a7533abcf7
freqtable(contra, :age, :use)

# ╔═╡ 6c1cdf8c-7fb2-11eb-377a-e7ca73990a76
Gadfly.plot(contra, x=:age, y=:use, Geom.smooth, Guide.xlabel("Centered age (yr)"),    Guide.ylabel("Contraception use"))

# ╔═╡ e39d879e-7fb4-11eb-13ac-0929fe036bcc
md"""
shows that the proportion of women using artificial contraception is approximately quadratic in age.

A model with fixed-effects for age, age squared, number of live children and urban location and with random effects for district, is fit as

"""

# ╔═╡ e992ec48-7fb4-11eb-2dc2-4f8e986d442e
const form1 = @formula use ~ 1 + age + abs2(age) + livch + urban + (1|dist);

# ╔═╡ 4b728752-7fb5-11eb-27e0-dde057432a29
m1 = fit(MixedModel, form1, contra, Bernoulli(), fast = true)

# ╔═╡ 57505a74-7fb5-11eb-277d-039d04765b36
md"""
For a model such as `m1`, which has a single, scalar random-effects term, the unscaled conditional density of the spherical random effects variable, $\mathcal{U}$,
given the observed data, $\mathcal{Y}=\mathbf{y}_0$, can be expressed as a product of scalar density functions, $f_i(u_i),\; i=1,\dots,q$.
In the PIRLS algorithm, which determines the conditional mode vector, $\tilde{\mathbf{u}}$, the optimization is performed on the *deviance scale*,
```math
D(\mathbf{u})=-2\sum_{i=1}^q \log(f_i(u_i))
```
The objective, $D$, consists of two parts: the sum of the (squared) *deviance residuals*, measuring fidelity to the data, and the squared length of $\mathbf{u}$, which is the penalty.
In the PIRLS algorithm, only the sum of these components is needed.
To use Gauss-Hermite quadrature the contributions of each of the $u_i,\;i=1,\dots,q$ should be separately evaluated.
"""

# ╔═╡ 1c033f36-7fbd-11eb-1bcf-ad62edd109ef
propertynames(m1)

# ╔═╡ c0d980fe-7fb5-11eb-34cc-9117603abb9a
const devc0 = map!(abs2, m1.devc0, m1.u[1]);  # start with uᵢ²

# ╔═╡ df26d656-7fb5-11eb-113d-9b5367ba0d12
const devresid = m1.resp.devresid;   # n-dimensional vector of deviance residuals

# ╔═╡ e8970134-7fb5-11eb-1c5c-8f3a8fa9c33c
const refs = only(m1.LMM.reterms).refs;  # n-dimensional vector of indices in 1:q

# ╔═╡ ed90b78e-7fb5-11eb-1129-653871f0e7e0
for (dr, i) in zip(devresid, refs)
    devc0[i] += dr
end

# ╔═╡ fb739fec-7fb5-11eb-1522-874ac4c26f96
devc0

# ╔═╡ 343bdbb4-7fb6-11eb-2de6-d9b63c099ad4
md"""
One thing to notice is that, even on the deviance scale, the contributions of different districts can be of different magnitudes.
This is primarily due to different sample sizes in the different districts.
"""

# ╔═╡ 3ab1909c-7fb6-11eb-2718-8fede509ebeb
freqtable(contra, :dist)'

# ╔═╡ 68eeb64c-7fb6-11eb-031e-7d6eb593815f
md"""
Because the first district has one of the largest sample sizes and the third district has the smallest sample size, these two will be used for illustration.
For a range of $u$ values, evaluate the individual components of the deviance and store them in a matrix.
"""

# ╔═╡ 6d850ea4-7fb6-11eb-2737-d52488deb335
begin
const devc = m1.devc;
const xvals = -5.0:2.0^(-4):5.0;
const uv = vec(m1.u[1]);
const u₀ = vec(m1.u₀[1]);
results = zeros(length(devc0), length(xvals))
for (j, u) in enumerate(xvals)
    fill!(devc, abs2(u))
    fill!(uv, u)
    MixedModels.updateη!(m1)
    for (dr, i) in zip(devresid, refs)
        devc[i] += dr
    end
    copyto!(view(results, :, j), devc)
end
end

# ╔═╡ a7a6e1f2-7fb6-11eb-1caa-f518682744ea
md"""
A plot of the deviance contribution versus $u_1$

"""

# ╔═╡ 8ad90c58-7fb6-11eb-0eec-4961ebab23c7
# Gadfly.plot(x=xvals, y=view(results, 1, :), Geom.line, Guide.xlabel("u₁"), Guide.ylabel("Deviance contribution"))

# ╔═╡ ad3a84fc-7fb6-11eb-2d24-b55533ac5f0e
md"""
shows that the deviance contribution is very close to a quadratic.
This is also true for $u_3$
"""

# ╔═╡ bf003b14-7fb6-11eb-0bed-0f1f846815d8
# Gadfly.plot(x=xvals, y=view(results, 3, :), Geom.line, Guide.xlabel("u₃"), Guide.ylabel("Deviance contribution"))

# ╔═╡ cd21cae6-7fb6-11eb-0425-35d753dda314
md"""
The PIRLS algorithm provides the locations of the minima of these scalar functions, stored as

"""

# ╔═╡ e09ecdda-7fb6-11eb-3cce-2bfbba065e88
m1.u₀[1]

# ╔═╡ eafd3cc6-7fb6-11eb-0d34-93e39cbe051d
md"""
the minima themselves, evaluated as `devc0` above, and a horizontal scale, which is the inverse of diagonal of the Cholesky factor.
As shown below, this is an estimate of the conditional standard deviations of the components of $\mathcal{U}$.
"""

# ╔═╡ 1e77ec68-7fb7-11eb-29ea-f7cce97e0d59
const s = inv.(m1.LMM.L[block(1,1)].diag);

# ╔═╡ 241a6768-7fb7-11eb-37fc-ad7e87af8772
s'

# ╔═╡ 2e3c149e-7fb7-11eb-0fa8-41aba63f444e
md"""
The curves can be put on a common scale, corresponding to the standard normal, as

"""

# ╔═╡ 3eecc40a-7fb7-11eb-308c-d1695ece81be
# for (j, z) in enumerate(xvals)
#     @. uv = u₀ + z * s
#     MixedModels.updateη!(m1)
#     @. devc = abs2(uv) - devc0
#     for (dr, i) in zip(devresid, refs)
#         devc[i] += dr
#     end
#     copyto!(view(results, :, j), devc)
# end

# ╔═╡ 498c2eaa-7fb7-11eb-0ccf-67226a9404e4
# Gadfly.plot(x=xvals, y=view(results, 1, :), Geom.line, Guide.xlabel("Scaled and shifted u₁"), Guide.ylabel("Shifted deviance contribution"))

# ╔═╡ 598a2b68-7fb7-11eb-302e-0dd797bd9f52
# Gadfly.plot(x=xvals, y=view(results, 3, :), Geom.line, Guide.xlabel("Scaled and shifted u₃"), Guide.ylabel("Shifted deviance contribution"))

# ╔═╡ 680aff32-7fb7-11eb-14be-0d5ab931ead2
md"""
On the original density scale these become

"""

# ╔═╡ 85a1c04e-7fb7-11eb-0634-d7c7424c2c19
# for (j, z) in enumerate(xvals)
#     @. uv = u₀ + z * s
#     MixedModels.updateη!(m1)
#     @. devc = abs2(uv) - devc0
#     for (dr, i) in zip(devresid, refs)
#         devc[i] += dr
#     end
#     copyto!(view(results, :, j), @. exp(-devc/2))
# end

# ╔═╡ 890886d2-7fb7-11eb-06e2-57ada178120f
# Gadfly.plot(x=xvals, y=view(results, 1, :), Geom.line, Guide.xlabel("Scaled and shifted u₁"), Guide.ylabel("Conditional density"))

# ╔═╡ 9ce41bd0-7fb7-11eb-26f4-61842bac20c1
# Gadfly.plot(x=xvals, y=view(results, 3, :), Geom.line, Guide.xlabel("Scaled and shifted u₃"), Guide.ylabel("Conditional density"))

# ╔═╡ ab4f1a6c-7fb7-11eb-0ac1-57c345a30501
md"""
and the function to be integrated with the normalized Gauss-Hermite rule is
"""

# ╔═╡ b97758a2-7fb7-11eb-129b-45ae7b1f2216
# for (j, z) in enumerate(xvals)
#     @. uv = u₀ + z * s
#     MixedModels.updateη!(m1)
#     @. devc = abs2(uv) - devc0
#     for (dr, i) in zip(devresid, refs)
#         devc[i] += dr
#     end
#     copyto!(view(results, :, j), @. exp((abs2(z) - devc)/2))
# end

# ╔═╡ c58d84d6-7fb7-11eb-17d3-913cd13867e6
# Gadfly.plot(x=xvals, y=view(results, 1, :), Geom.line, Guide.xlabel("Scaled and shifted u₁"), Guide.ylabel("Kernel ratio"))

# ╔═╡ d5ebb42e-7fb7-11eb-2077-c715b0671084
# Gadfly.plot(x=xvals, y=view(results, 3, :), Geom.line, Guide.xlabel("Scaled and shifted u₃"), Guide.ylabel("Kernel ratio"))

# ╔═╡ Cell order:
# ╠═370be012-7fae-11eb-3467-05a964507c61
# ╠═949007e2-7fb1-11eb-0c33-dbeb6b34e98c
# ╠═fe29e020-7fba-11eb-0741-3194a34abd3c
# ╟─d1ce0aca-7f37-11eb-159e-e700e273ade5
# ╟─dc8aa540-7f37-11eb-2c56-4d7f5549d8a2
# ╟─ee9479be-7f37-11eb-074a-ad7866940be8
# ╟─fff62c16-7f37-11eb-1e20-63d16ac9904f
# ╠═09fa2c08-7f38-11eb-3284-051d4364ef3d
# ╠═39f4a98e-7f39-11eb-1cfb-b1e880da12e4
# ╠═4fb577d8-7f39-11eb-2047-ffe2be9dba88
# ╠═df274322-7f9f-11eb-0d36-6f5a111f179a
# ╠═d6a79224-7f9f-11eb-00d2-1b448059ad5a
# ╟─72775048-7f39-11eb-0168-450d9f1b82e3
# ╠═770491ca-7f39-11eb-0287-756f418d8dda
# ╟─88dc35b0-7f39-11eb-3f92-6f3ba34315dd
# ╠═91b28a40-7f39-11eb-389d-cfb3d4a7bc96
# ╟─a2305e60-7f39-11eb-1fd0-f1fdde485318
# ╠═f034fa70-7f9c-11eb-1f51-79308903966c
# ╠═af51cf10-7f3a-11eb-0d09-09e126b986d5
# ╟─96f96192-7f9b-11eb-06dc-afd8305697bf
# ╠═c1d0a0e6-7f9c-11eb-1807-7bbfb0b69fde
# ╟─0ee7530a-7f9f-11eb-0d29-3ffc8a08b743
# ╠═8418480a-7f9f-11eb-37b0-c1d867794c8b
# ╠═4bc3f378-7f9f-11eb-11b0-8f1f03c73722
# ╠═79d4447a-7f9f-11eb-1db9-a55b4faafa04
# ╟─93723e64-7f9f-11eb-3f96-dff738aed80a
# ╠═f0d58dfa-7fad-11eb-318f-2f4e115f2c25
# ╠═f608a622-7fad-11eb-1d2b-857376de6774
# ╟─0109c13c-7fae-11eb-0c80-f15e77994d27
# ╟─1f81ec70-7fae-11eb-15c9-350fd3dc3aa5
# ╟─0e4c3280-7fae-11eb-25c7-67ca4864cd7a
# ╠═291e0eda-7fae-11eb-0568-b127160abf32
# ╟─513b2b46-7fae-11eb-0863-a33f2a581040
# ╠═582f5f76-7fae-11eb-2bf3-29d1022a5f52
# ╠═1df7a9a2-7fb9-11eb-1d11-d1a7533abcf7
# ╠═6c1cdf8c-7fb2-11eb-377a-e7ca73990a76
# ╟─e39d879e-7fb4-11eb-13ac-0929fe036bcc
# ╠═e992ec48-7fb4-11eb-2dc2-4f8e986d442e
# ╠═4b728752-7fb5-11eb-27e0-dde057432a29
# ╟─57505a74-7fb5-11eb-277d-039d04765b36
# ╠═1c033f36-7fbd-11eb-1bcf-ad62edd109ef
# ╠═c0d980fe-7fb5-11eb-34cc-9117603abb9a
# ╠═df26d656-7fb5-11eb-113d-9b5367ba0d12
# ╠═e8970134-7fb5-11eb-1c5c-8f3a8fa9c33c
# ╠═ed90b78e-7fb5-11eb-1129-653871f0e7e0
# ╠═fb739fec-7fb5-11eb-1522-874ac4c26f96
# ╟─343bdbb4-7fb6-11eb-2de6-d9b63c099ad4
# ╠═3ab1909c-7fb6-11eb-2718-8fede509ebeb
# ╟─68eeb64c-7fb6-11eb-031e-7d6eb593815f
# ╠═6d850ea4-7fb6-11eb-2737-d52488deb335
# ╟─a7a6e1f2-7fb6-11eb-1caa-f518682744ea
# ╠═8ad90c58-7fb6-11eb-0eec-4961ebab23c7
# ╟─ad3a84fc-7fb6-11eb-2d24-b55533ac5f0e
# ╠═bf003b14-7fb6-11eb-0bed-0f1f846815d8
# ╟─cd21cae6-7fb6-11eb-0425-35d753dda314
# ╠═e09ecdda-7fb6-11eb-3cce-2bfbba065e88
# ╟─eafd3cc6-7fb6-11eb-0d34-93e39cbe051d
# ╠═0057d0a4-7fb7-11eb-1c14-a399f32f50de
# ╠═1e77ec68-7fb7-11eb-29ea-f7cce97e0d59
# ╠═241a6768-7fb7-11eb-37fc-ad7e87af8772
# ╟─2e3c149e-7fb7-11eb-0fa8-41aba63f444e
# ╠═3eecc40a-7fb7-11eb-308c-d1695ece81be
# ╠═498c2eaa-7fb7-11eb-0ccf-67226a9404e4
# ╠═598a2b68-7fb7-11eb-302e-0dd797bd9f52
# ╟─680aff32-7fb7-11eb-14be-0d5ab931ead2
# ╠═85a1c04e-7fb7-11eb-0634-d7c7424c2c19
# ╠═890886d2-7fb7-11eb-06e2-57ada178120f
# ╠═9ce41bd0-7fb7-11eb-26f4-61842bac20c1
# ╟─ab4f1a6c-7fb7-11eb-0ac1-57c345a30501
# ╠═b97758a2-7fb7-11eb-129b-45ae7b1f2216
# ╠═c58d84d6-7fb7-11eb-17d3-913cd13867e6
# ╠═d5ebb42e-7fb7-11eb-2077-c715b0671084
