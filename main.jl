using Plots
using Revise
using Dierckx

includet("src/data.jl")
using .EMD

N = 100
dh = DataHolder(rand(N))

update_extrema!(dh)

@time idx_min = findall(dh.minima)
idx_max = findall(dh.maxima)

# Compute splines 
rg = 1:length(f)
spl_min = Spline1D(idx_min, f[idx_min])
spl_max = Spline1D(idx_max, f[idx_max])

# Construct bezier interpolation
pl = plot(dh.f)
# plot!(pl, rg, spl_min(rg))
# plot!(pl, rg, spl_max(rg))
scatter!(pl, idx_min, dh.f[idx_min])
scatter!(pl, idx_max, dh.f[idx_max])
mn = 0.5 .* ( spl_min(rg) .+ spl_max(rg) )
plot!(pl, rg, mn)
