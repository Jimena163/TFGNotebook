using Images: imresize, imrotate, Pad, Fill, padarray, clamp01, clamp01nan, clamp01!, clamp01nan!, scaleminmax, scalesigned, colorsigned, takemap

"""
    imMatching(args...; pad_value::Real=0, method::String="fill")

Match the dimensions of input images by padding or resizing.

- `pad_value`: Value used for padding when the method is "fill".
- `method`: Padding or resizing method. Supported methods are "fill", "replicate", "circular", "symmetric", "reflect", "upscale", and "downscale".
"""
function imMatching(args...; pad_value::Real=0, method::String="fill", collect_arrays::Bool=false)
    max_dims = maxDims(args)
    pad_methods = Dict(
        "fill" => (arg, diff_dim) -> padarray(arg, Fill(pad_value, diff_dim)),
        "replicate" => (arg, diff_dim) -> padarray(arg, Pad(:replicate, diff_dim)),
        "circular" => (arg, diff_dim) -> padarray(arg, Pad(:circular, diff_dim)),
        "symmetric" => (arg, diff_dim) -> padarray(arg, Pad(:symmetric, diff_dim)),
        "reflect" => (arg, diff_dim) -> padarray(arg, Pad(:reflect, diff_dim)),
        "upscale" => arg -> imresize(arg, max_dims),
        "downscale" => arg -> imresize(arg, minDims(args))
    )
    
    haskey(pad_methods, method) || throw(ArgumentError("Invalid padding or resizing method: $method"))

    if method in ["upscale", "downscale"]
        result = map(pad_methods[method], args)
    else
        diff_dims = map(arg -> Int.((max_dims .- size(arg)) ./ 2), args)
        result = map((arg, diff_dim) -> pad_methods[method](arg, diff_dim), args, diff_dims)
    end

    return collect_arrays ? map(collect, result) : result
end

"""
    imRotating(image::AbstractArray; angle::Real=0, method::String="linear", fill::Real=0)

Rotate an image by a specified angle.

- `angle`: Rotation angle in degrees.
- `method`: Interpolation method. Supported methods are "nearest", "linear", and "lanczos".
- `fill`: Value used to fill areas outside the rotated image.
"""
function imRotating(image::AbstractArray; angle::Real=0, method::String="linear", fill::Real=0)
    methods = Dict(
        "nearest" => Constant(),
        "linear" => Linear(),
        "lanczos" => Lanczos(4)
    )
    
    haskey(methods, method) || throw(ArgumentError("Invalid rotation method."))
    
    return imrotate(image, angle; method=methods[method], fill=fill)
end

"""
    imResizing(image::AbstractArray; method::String="linear", scale::Real=0.5)

Resize an image by a specified scale.

- `method`: Interpolation method. Supported methods are "nearest", "linear", and "lanczos".
- `scale`: Scaling factor for resizing.
"""
function imResizing(image::AbstractArray; method::String="linear", scale::Real=0.5)
    methods = Dict(
        "nearest" => Constant(),
        "linear" => Linear(),
        "lanczos" => Lanczos(4)
    )
    
    haskey(methods, method) || throw(ArgumentError("Invalid resizing method."))
    
    scale == 1 && return image 
    return imresize(image; method=methods[method], ratio=scale)
end

"""
    imResizing(image::AbstractArray, args...; method::String="linear")

Resize an image to specified dimensions.

- `method`: Interpolation method. Supported methods are "nearest", "linear", and "lanczos".
"""
function imResizing(image::AbstractArray, args...; method::String="linear")
    methods = Dict(
        "nearest" => Constant(),
        "linear" => Linear(),
        "lanczos" => Lanczos(4)
    )
    
    haskey(methods, method) || throw(ArgumentError("Invalid resizing method."))
    
    return imresize(image, args...; method=methods[method])
end

"""
    imNorm(arr::AbstractArray{T}, ::Val{:slice}) where T<:Real

Normalize a 3D or 4D array per slice to the range [0.0, 1.0].

- For 3D arrays, normalization is applied to each slice independently.
- For 4D arrays, normalization is applied to each slice along the 4th dimension.
"""
function imNorm(arr::AbstractArray{T}, ::Val{:slice}) where T<:Real
    if ndims(arr) == 3
        return mapreduce(i -> imNorm(arr[:, :, i]), (x, y) -> cat(x, y; dims=3), axes(arr, 3))
    elseif ndims(arr) == 4
        return mapreduce(i -> imNorm(view(arr, :, :, :, i), Val(:slice)), (x, y) -> cat(x, y; dims=4), axes(arr, 4))
    else
        error("Per-slice normalization is only supported for 3D or 4D arrays.")
    end
end

"""
    imNorm(arr::AbstractArray{T}, ::Val{:channel}) where T<:Real

Normalize each channel independently in a 3D or 4D array to the range [0.0, 1.0].

- For 3D arrays, normalization is applied to each channel.
- For 4D arrays, normalization is applied to each channel along the 3rd dimension.
"""
function imNorm(arr::AbstractArray{T}, ::Val{:channel}) where T<:Real
    ndims(arr) == 3 && return map(c -> imNorm(arr[:, :, c]), axes(arr, 3))
    ndims(arr) == 4 || error("Per-channel normalization is only supported for 3D or 4D arrays.")
    chans = map(c -> imNorm(view(arr, :, :, c, :)), axes(arr, 3))
    return cat(chans...; dims=3)
end

"""
    imNorm(arr::AbstractArray{T}, ::Val{:slice_channel}) where T<:Real

Normalize each slice and each channel independently in a 4D array to the range [0.0, 1.0].

- Normalization is applied to each slice along the 4th dimension and each channel along the 3rd dimension.
"""
function imNorm(arr::AbstractArray{T}, ::Val{:slice_channel}) where T<:Real
    ndims(arr) == 4 || error("Per-slice-channel normalization is only supported for 4D arrays.")
    slices = map(s -> begin
        slice = view(arr, :, :, :, s)
        chans = map(c -> imNorm(view(slice, :, :, c)), axes(slice, 3))
        cat(chans...; dims=3)
    end, axes(arr, 4))
    return cat(slices...; dims=4)
end

"""
    imNorm(arr::AbstractArray{T}) where T<:Real

Globally normalize an array to the range [0.0, 1.0].

- Normalization is applied to the entire array.
"""
function imNorm(arr::AbstractArray{T}) where T<:Real
    minval, maxval = extrema(arr)
    range = maxval - minval
    @assert range > 0 "Array has no dynamic range."
    return Float32.((arr .- minval) ./ range)
end
