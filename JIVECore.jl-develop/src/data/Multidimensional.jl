# ND images manupulation
using Images:  AxisArray, Axis, merge, join, axisvalues, axisnames, axisdim, transpose, adjoint, map, map!, size, eachindex

"""
    imMerge(arrays::AxisArray...)

Merge multiple `AxisArray` objects into a single multidimensional array.

# Arguments
- `arrays::AxisArray...`: A variable number of `AxisArray` objects to be merged. 
  Each array must have compatible dimensions and axes.

# Returns
A new `AxisArray` that combines the input arrays along a new dimension.

# Notes
- The input arrays must have matching axes for all dimensions except the one being merged.
- The function assumes that the arrays are aligned along their axes.
"""
function imMerge(arrays::AxisArray...)
    if isempty(arrays)
        throw(ArgumentError("No arrays provided for merging"))
    end
    for (i, arr) in enumerate(arrays)
        if typeof(arr) != typeof(arrays[1])
            @warn "Array at position $i has a different type: $(typeof(arr))"
        end
    end
    try
        return merge(arrays...)
    catch e
        throw(ErrorException("Failed to merge arrays: $(e)"))
    end
end

"""
    imInsert(A::AxisArray{T,N,D,Ax}, B::AxisArray{T,N,D,Ax}, dim::Symbol, pos::Int=1; fillvalue::T=zero(T)) where {T,N,D,Ax}

Inserts the contents of the `AxisArray` `B` into the `AxisArray` `A` along the specified dimension `dim` at the given position `pos`.

# Arguments
- `A::AxisArray{T,N,D,Ax}`: The target `AxisArray` where the data will be inserted.
- `B::AxisArray{T,N,D,Ax}`: The `AxisArray` to be inserted into `A`.
- `dim::Symbol`: The dimension along which the insertion will occur. This should match one of the axis names of `A`.
- `pos::Int=1`: The position along the specified dimension where the insertion will take place. Defaults to `1`.

# Returns
A new `AxisArray` with the contents of `B` inserted into `A` along the specified dimension.

# Notes
- The function assumes that `A` and `B` have compatible dimensions and axis names, except for the specified dimension `dim`.
"""
function imInsert(A::AxisArray{T,N,D,Ax}, B::AxisArray{T,N,D,Ax}, dim::Symbol, pos::Int=1) where {T,N,D,Ax}
    ndim = findfirst(isequal(dim), axisnames(A))
    last = lastindex(axisvalues(A)[ndim])
    # Check if the position is within the valid range
    if pos < 1 || pos > size(A, ndim) + 1
        throw(ArgumentError("Position out of bounds"))
    end
    merge(A[Axis{dim}(1:pos-1)], B, A[Axis{dim}(pos:last)])
end

"""
    join(arrays::AxisArray...)

Joins multiple `AxisArray` objects along their axes. This function combines the input arrays into a single multidimensional array, ensuring that the axes are aligned and compatible.

# Arguments
- `arrays::AxisArray...`: A variable number of `AxisArray` objects to be joined.

# Returns
A new `AxisArray` resulting from the combination of the input arrays.

# Notes
The input arrays must have compatible axes for the join operation to succeed.
"""
function imJoin(arrays::AxisArray...)
    if isempty(arrays)
        throw(ArgumentError("No arrays provided for joining"))
    end
    for (i, arr) in enumerate(arrays)
        if typeof(arr) != typeof(arrays[1])
            @warn "Array at position $i has a different type: $(typeof(arr))"
        end
    end
    try
        return join(arrays...)
    catch e
        throw(ErrorException("Failed to join arrays: $(e)"))
    end
end

"""
    deleteSlice(A::AxisArray{T,N,D,Ax}, dim::Symbol, pos::Int) where {T,N,D,Ax}

Deletes a single slice from an `AxisArray` along the specified dimension `dim` at the given position `pos`.

# Arguments
- `A::AxisArray{T,N,D,Ax}`: The input `AxisArray` from which a slice will be removed.
- `dim::Symbol`: The dimension along which the slice will be removed, specified as a symbol.
- `pos::Int`: The position of the slice to be removed.

# Throws
- `ArgumentError`: If the position `pos` is out of bounds.
"""
function deleteSlice(A::AxisArray{T,N,D,Ax}, dim::Symbol, pos::Int) where {T,N,D,Ax}
    ndim = findfirst(isequal(dim), axisnames(A))
    last = lastindex(axisvalues(A)[ndim])
    if pos < 1 || pos > size(A, ndim)
        throw(ArgumentError("Position out of bounds"))
    end
    merge(A[Axis{dim}(1:pos-1)], A[Axis{dim}(pos+1:last)])
end

"""
    imDelete(A::AxisArray{T,N,D,Ax}, dim::Symbol, pos::AbstractRange{Int}) where {T,N,D,Ax}

Deletes multiple slices from an `AxisArray` along the specified dimension `dim` at the positions specified by the range `pos`.

# Arguments
- `A::AxisArray{T,N,D,Ax}`: The input `AxisArray` from which slices will be removed.
- `dim::Symbol`: The dimension along which the slices will be removed, specified as a symbol.
- `pos::AbstractRange{Int}`: A range specifying the positions of the slices to be removed.

# Throws
- `ArgumentError`: If the range `pos` is out of bounds.
"""
function imDelete(A::AxisArray{T,N,D,Ax}, dim::Symbol, pos::AbstractRange{Int}) where {T,N,D,Ax}
    ndim = findfirst(isequal(dim), axisnames(A))
    last_index = lastindex(axisvalues(A)[ndim])
    if first(pos) < 1 || last(pos) > size(A, ndim)
        throw(ArgumentError("Position range out of bounds"))
    end
    indices_to_keep = setdiff(1:size(A, ndim), collect(pos))
    merge(A[Axis{dim}(indices_to_keep)])
end


"""
    imDelete(A::AxisArray{T,N,D,Ax}, dim::Symbol, pos::AbstractVector{Int}) where {T,N,D,Ax}

Deletes multiple slices from an `AxisArray` along the specified dimension `dim` at the positions specified by the vector `pos`.

# Arguments
- `A::AxisArray{T,N,D,Ax}`: The input `AxisArray` from which slices will be removed.
- `dim::Symbol`: The dimension along which the slices will be removed, specified as a symbol.
- `pos::AbstractVector{Int}`: A vector specifying the positions of the slices to be removed.

# Throws
- `ArgumentError`: If one or more positions in `pos` are out of bounds.
"""
function imDelete(A::AxisArray{T,N,D,Ax}, dim::Symbol, pos::AbstractVector{Int}) where {T,N,D,Ax}
    ndim = findfirst(isequal(dim), axisnames(A))
    last_index = lastindex(axisvalues(A)[ndim])
    if any(p -> p < 1 || p > size(A, ndim), pos)
        throw(ArgumentError("One or more positions are out of bounds"))
    end
    indices_to_keep = setdiff(1:size(A, ndim), pos)
    merge(A[Axis{dim}(indices_to_keep)])
end