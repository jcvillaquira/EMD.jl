module EMD_IF


using Dierckx
using Interpolations
using Plots


export Model
export update_extrema!, substract_mean!, sifting_step!, sifting!, plot_modes

include("dataholders.jl")
include("model.jl")
include("emd.jl")

## Stop criterion for each algorithm
end
