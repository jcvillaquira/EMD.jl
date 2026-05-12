module EMD


using Dierckx


export Model
export update_extrema!, substract_mean!, sifting_step!, sifting!


mutable struct DataHolder
  f::Vector
  minima::BitVector       
  maxima::BitVector
  iter::Int
  stop::Bool
end


function DataHolder(f::Vector)
  minima = similar(BitVector, length(f))
  maxima = similar(BitVector, length(f))
  return DataHolder(f, minima, maxima, 0, false)
end


function stop!(dh::DataHolder)
  println(dh.iter)
  if dh.stop || ( dh.iter >= 10 )
    dh.iter = 0
    return true
  end
  dh.iter += 1
  return false
end


struct Model
  dh::DataHolder
  modes::Vector{Vector}
  residue::Vector
end


function Model(f::Vector)
  dh = DataHolder(f)
  modes = Vector{Vector{eltype(f)}}()
  residue = copy(f)
  return Model(dh, modes, residue)
end


Base.length(model::Model) = length(model.dh.f)


function update_extrema!(model::Model)
  prev, curr = model.dh.f[1], model.dh.f[2]
  for j in 2:(length(model)-1)
    nxt = model.dh.f[j+1]
    model.dh.minima[j] = ( prev > curr ) && ( curr < nxt )
    model.dh.maxima[j] = ( prev < curr ) && ( curr > nxt )
    prev = curr
    curr = nxt
  end
  model.dh.minima[1] = model.dh.minima[end] = model.dh.maxima[1] = model.dh.maxima[end] = true
  return nothing
end


function get_mean(model::Model)
  rg = 1:length(model)
  idx_min = findall(model.dh.minima)
  idx_max = findall(model.dh.maxima)
  spl_min = Spline1D(idx_min, model.dh.f[idx_min])
  spl_max = Spline1D(idx_max, model.dh.f[idx_max])
  mn = 0.5 .* ( spl_min(rg) .+ spl_max(rg) )
  return mn
end


function substract_mean!(model::Model)
  try
    mn = get_mean(model)
    @. model.dh.f -= mn
  catch
    model.dh.stop = true
    return nothing
  end
end


function sifting_step!(model::Model)
  while !stop!(model.dh)
    update_extrema!(model)
    substract_mean!(model)
  end
end


function sifting!(model::Model)
  for _ in 1:10
    sifting_step!(model)
    push!(model.modes, copy(model.dh.f))
    model.residue .-= model.dh.f
    model.dh.f .= model.residue
  end
end


end
