### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 90e7b102-7f35-11eb-075d-09ac37399a88
md"""
# Alternative display and output formats

"""

# ╔═╡ 862765b4-7f35-11eb-3529-a5e8d4a6d0ba
md"""

In the documentation, we have presented the output from MixedModels.jl in the same format you will see when working in the REPL.
You may have noticed, however, that output from other packages received pretty printing.
For example, DataFrames are converted into nice HTML tables.
In MixedModels, we recently (v3.2.0) introduced limited support for such pretty printing.
(For more details on how the print and display system in Julia works, check out [this NextJournal post](https://nextjournal.com/sdanisch/julias-display-system).)

In particular, we have defined Markdown, HTML and LaTeX output, i.e. `show` methods, for our types.
Note that the Markdown output can also be easily and more flexibly translated into HTML, LaTeX (e.g. with `booktabs`) or even a MS Word Document using tools such as [pandoc](https://pandoc.org/).
Packages like `IJulia` and `Documenter` can often detect the presence of these display options and use them automatically.

"""

# ╔═╡ 97e61b74-7f35-11eb-1b64-9dde2450efc3
# using MixedModels, DisplayAs

# ╔═╡ a1bd46ae-7f35-11eb-0cb6-b7553e95694a
# form = @formula(rt_trunc ~ 1 + spkr * prec * load +
#                           (1 + load | item) +
#                           (1 + spkr + prec + load | subj));

# ╔═╡ a96721ea-7f35-11eb-0fb2-69c4dc4278b2
# contr = Dict(:spkr => EffectsCoding(),
#              :prec => EffectsCoding(),
#              :load => EffectsCoding(),
#              :item => Grouping(),
#              :subj => Grouping());

# ╔═╡ b888237c-7f35-11eb-0f29-ef7fb4a9d230
# kbm = fit(MixedModel, form, MixedModels.dataset(:kb07); contrasts = contr)

# ╔═╡ c40361d0-7f35-11eb-3543-c98026ea767f
md"""
Note that the display here is more succinct than the standard REPL display:
"""

# ╔═╡ d919e1a2-7f35-11eb-06db-c58fac512bc9
# kbm |> DisplayAs.Text

# ╔═╡ f6d0c47c-7f35-11eb-1890-390b468d36ae
md"""
This brevity is intentional: we wanted these types to work well with traditional academic publishing constraints on tables.
The summary for a model fit presented in the REPL does not mesh well with being treated as a single table (with columns shared between the random and fixed effects).
In our experience, this leads to difficulties in typesetting the resulting tables.
We nonetheless encourage users to report fit statistics such as the log likelihood or AIC as part of the caption of their table.
If the correlation parameters in the random effects are of interest, then [`VarCorr`](@ref) can also be pretty printed:
"""

# ╔═╡ 115b89a8-7f36-11eb-2f97-455094520487
# VarCorr(kbm)

# ╔═╡ 1a032252-7f36-11eb-1e58-a3c36d45919f
md"""
Similarly for [`BlockDescription`](@ref), `OptSummary` and `MixedModels.likelihoodratiotest`:

"""

# ╔═╡ 237838fc-7f36-11eb-2e06-e373dab3f942
# BlockDescription(kbm)

# ╔═╡ 2c879b54-7f36-11eb-29b6-43f27c34c5b8
# kbm.optsum

# ╔═╡ 3df67f04-7f36-11eb-3239-357b9d7077de
# begin
# m0 = fit(MixedModel, @formula(reaction ~ 1 + (1|subj)), MixedModels.dataset(:sleepstudy))
# m1 = fit(MixedModel, @formula(reaction ~ 1 + days + (1+days|subj)), MixedModels.dataset(:sleepstudy))
# MixedModels.likelihoodratiotest(m0, m1)
# end

# ╔═╡ 5dcb8112-7f36-11eb-25aa-3749cd3813d0
md"""
To explicitly invoke this behavior, we must specify the right `show` method.
(The raw and not rendered output is intentionally shown here.)
"""

# ╔═╡ 6a2c9608-7f36-11eb-17aa-89f319714ca6
# show(MIME("text/markdown"), m1)

# ╔═╡ dc303796-7f36-11eb-2071-655e74e53cf4
# println(sprint(show, MIME("text/markdown"), kbm)) # hide

# ╔═╡ f3b27e2e-7f36-11eb-0068-87a94b46116a
# show(MIME("text/html"), m1)

# ╔═╡ feb65b38-7f36-11eb-3c77-71d9a37edf29
# println(sprint(show, MIME("text/html"), kbm)) # hide

# ╔═╡ 0049293a-7f37-11eb-3880-3d3972d8c32a
md"""
Note for that LaTeX, the column labels for the random effects are slightly changed: σ is placed into math mode and escaped and the grouping variable is turned into a subscript.
Similarly for the likelihood ratio test, the χ² is escaped into math mode.
This transformation improves pdfLaTeX and journal compatibility, but also means that XeLaTeX and LuaTeX may use a different font at this point.
"""

# ╔═╡ 142c571c-7f37-11eb-2522-c910a570d26a
# show(MIME("text/latex"), m1)

# ╔═╡ 1bb60442-7f37-11eb-2a5e-bf914c53b194
# println(sprint(show, MIME("text/latex"), kbm)) # hide

# ╔═╡ 2502a454-7f37-11eb-157f-9f9f9b1b1bf2
md"""
This escaping behavior can be disabled by specifying `"text/xelatex"` as the MIME type.
(Note that other symbols may still be escaped, as the internal conversion uses the `Markdown` module from the standard library, which performs some escaping on its own.)
"""

# ╔═╡ 32257d8c-7f37-11eb-1801-6bc35930da96
# show(MIME("text/xelatex"), m1)

# ╔═╡ 54adbb50-7f37-11eb-1770-29d7f65f1ee3
md"""
This output can also be written directly to file:
"""

# ╔═╡ 621612a4-7f37-11eb-3197-b5042fb39d94
# open("model.md", "w") do io
#     show(io, MIME("text/markdown"), kbm)
# end

# ╔═╡ Cell order:
# ╟─90e7b102-7f35-11eb-075d-09ac37399a88
# ╟─862765b4-7f35-11eb-3529-a5e8d4a6d0ba
# ╠═97e61b74-7f35-11eb-1b64-9dde2450efc3
# ╠═a1bd46ae-7f35-11eb-0cb6-b7553e95694a
# ╠═a96721ea-7f35-11eb-0fb2-69c4dc4278b2
# ╠═b888237c-7f35-11eb-0f29-ef7fb4a9d230
# ╟─c40361d0-7f35-11eb-3543-c98026ea767f
# ╠═d919e1a2-7f35-11eb-06db-c58fac512bc9
# ╟─f6d0c47c-7f35-11eb-1890-390b468d36ae
# ╠═115b89a8-7f36-11eb-2f97-455094520487
# ╟─1a032252-7f36-11eb-1e58-a3c36d45919f
# ╠═237838fc-7f36-11eb-2e06-e373dab3f942
# ╠═2c879b54-7f36-11eb-29b6-43f27c34c5b8
# ╠═3df67f04-7f36-11eb-3239-357b9d7077de
# ╟─5dcb8112-7f36-11eb-25aa-3749cd3813d0
# ╠═6a2c9608-7f36-11eb-17aa-89f319714ca6
# ╠═dc303796-7f36-11eb-2071-655e74e53cf4
# ╠═f3b27e2e-7f36-11eb-0068-87a94b46116a
# ╠═feb65b38-7f36-11eb-3c77-71d9a37edf29
# ╟─0049293a-7f37-11eb-3880-3d3972d8c32a
# ╠═142c571c-7f37-11eb-2522-c910a570d26a
# ╠═1bb60442-7f37-11eb-2a5e-bf914c53b194
# ╟─2502a454-7f37-11eb-157f-9f9f9b1b1bf2
# ╠═32257d8c-7f37-11eb-1801-6bc35930da96
# ╟─54adbb50-7f37-11eb-1770-29d7f65f1ee3
# ╠═621612a4-7f37-11eb-3197-b5042fb39d94
