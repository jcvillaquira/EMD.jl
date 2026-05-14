module EMD_IF


export Model
export update_extrema!, substract_mean!, sifting_step!, sifting!, plot_modes


include("dataholders.jl")
include("model.jl")
include("emd.jl")
include("if.jl")


end
