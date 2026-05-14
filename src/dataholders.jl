abstract type DataHolder end


function stop!(dh::DataHolder)
  return false
end


## DataHolder for Empirical Mode Decomposition


mutable struct DataHolderEMD <: DataHolder
  f::Vector
  minima::BitVector       
  maxima::BitVector
  iter::Int
  stop::Bool
end


function DataHolderEMD(f::Vector)
  minima = similar(BitVector, length(f))
  maxima = similar(BitVector, length(f))
  return DataHolderEMD(f, minima, maxima, 0, false)
end


## DataHolder for Iterative Filtering


mutable struct DataHolderIF <: DataHolder
end
