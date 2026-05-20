using Plots
using ProgressBars


struct Model{D<:DataHolder}
  data::D
  modes::Vector{Vector}
  residue::Vector
end


function Model(f::Vector; algorithm = :EMD)
  modes = Vector{Vector{eltype(f)}}()
  residue = copy(f)
  if ( algorithm === :EMD ) || ( algorithm === :EMD3 )
    data = DataHolderEMD(f; N = 3)
    return Model{DataHolderEMD{3}}(data, modes, residue)
  elseif ( algorithm === :EMD1 )
    data = DataHolderEMD(f; N = 1)
    return Model{DataHolderEMD{1}}(data, modes, residue)
  elseif ( algorithm === :IF )
    data = DataHolderIF(f)
    return Model{DataHolderIF}(data, modes, residue)
  end
  throw("Algorithm not recognized.")
end


Base.length(model::Model) = length(model.residue)


function sifting!(model::Model; max_iter = 10)
  for _ in ProgressBar(1:max_iter)
    sifting_step!(model.data)
    push!(model.modes, copy(model.data.f))
    model.residue .-= model.data.f
    model.data.f .= model.residue
  end
end


function plot_modes(model::Model; with_jump = false)
  n_modes = sum(any(m .!= 0) for m in model.modes)
  original = zeros(length(model))
  default(
      size = (1920, 1080),
      legend = false,
      lw = 2,
      margin = 1Plots.mm,
      left_margin = 2Plots.mm,
      bottom_margin = 1Plots.mm
  )
  additional = with_jump ? 4 : 2
  pl = plot(layout = (n_modes + additional, 1));
  for n in 1:n_modes
    original .+= model.modes[n]
    plot!(pl, model.modes[n], subplot = n + additional - 1)
  end
  original .+= model.residue
  plot!(pl, model.residue, subplot = n_modes + additional)
  pos_original = with_jump ? 3 : 1
  plot!(pl, original, subplot = pos_original, linecolor = "red")
  return pl
end


