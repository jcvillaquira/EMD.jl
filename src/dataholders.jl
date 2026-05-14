abstract type DataHolder end


function stop!(data::DataHolder)
  return false
end


Base.length(data::DataHolder) = length(data.f)


function update_extrema!(data::DataHolder)
  prev, curr = data.f[1], data.f[2]
  for j in 2:(length(data)-1)
    nxt = data.f[j+1]
    data.minima[j] = ( prev > curr ) && ( curr < nxt )
    data.maxima[j] = ( prev < curr ) && ( curr > nxt )
    prev = curr
    curr = nxt
  end
  data.minima[1] = data.minima[end] = data.maxima[1] = data.maxima[end] = true
  return nothing
end


## DataHolder for Empirical Mode Decomposition


mutable struct DataHolderEMD{N} <: DataHolder
  f::Vector
  minima::BitVector       
  maxima::BitVector
  iter::Int
  stop::Bool
end


function DataHolderEMD(f::Vector; N::Int = 3)
  if ( N != 1 ) && ( N != 3 )
    throw("N must be either 1 or 3")
  end
  minima = similar(BitVector, length(f))
  maxima = similar(BitVector, length(f))
  return DataHolderEMD{N}(f, minima, maxima, 0, false)
end


## DataHolder for Iterative Filtering


mutable struct DataHolderIF <: DataHolder
  f::Vector
  minima::BitVector       
  maxima::BitVector
  mean::Vector
  alpha::Float64
  iter::Int
  stop::Bool
  m::Int
end


function DataHolderIF(f::Vector)
  minima = similar(BitVector, length(f))
  maxima = similar(BitVector, length(f))
  mean = similar(f)
  return DataHolderIF(f, minima, maxima, mean, 2, 0, false, 0)
end

