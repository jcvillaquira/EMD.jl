using Dierckx
using Interpolations


function sifting_step!(data::DataHolderEMD)
  while !stop!(data)
    update_extrema!(data)
    substract_mean!(data)
  end
end


function get_mean(data::DataHolderEMD{3})
  rg = 1:length(data)
  idx_min = findall(data.minima)
  idx_max = findall(data.maxima)
  spl_min = Spline1D(idx_min, data.f[idx_min])
  spl_max = Spline1D(idx_max, data.f[idx_max])
  mn = 0.5 .* ( spl_min(rg) .+ spl_max(rg) )
  return mn
end


function get_mean(data::DataHolderEMD{1})
  rg = 1:length(data)
  idx_min = findall(data.minima)
  idx_max = findall(data.maxima)
  spl_min = linear_interpolation(idx_min, data.f[idx_min])
  spl_max = linear_interpolation(idx_max, data.f[idx_max])
  mn = 0.5 .* ( spl_min(rg) .+ spl_max(rg) )
  return mn
end


function substract_mean!(data::DataHolderEMD)
  try
    mn = get_mean(data)
    @. data.f -= mn
  catch
    data.stop = true
    return nothing
  end
end


function stop!(data::DataHolderEMD)
  if data.stop || ( data.iter >= 10 )
    data.iter = 0
    data.stop = false
    return true
  end
  data.iter += 1
  return false
end

