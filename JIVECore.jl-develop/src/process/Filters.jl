# import ImageFiltering, Statistics

"""
    medianFilter(img, patch_size)

Apply a median filter to an image using a specified patch size.

# Arguments
- `img`: The input image (can be grayscale, RGB, etc.).
- `patch_size`: Either a single integer or a tuple `(m, n)` specifying the size of the filter window.

"""
# Case for a tuple specifying patch size
function medianFilter(img, patch_size::Tuple{Int, Int})
    return ImageFiltering.mapwindow(Statistics.median, img, patch_size)
end

# Case for a single integer specifying a square patch
function medianFilter(img, patch_size::Int=3)
    return ImageFiltering.mapwindow(Statistics.median, img, (patch_size, patch_size))
end


"""
    medianFilter3D(img, patch_size)

Apply a 3D median filter to an image using a specified patch size.

# Arguments
- `img`: The input image (can be grayscale, RGB, etc.).
- `patch_size`: Either a single integer or a tuple `(i, j, k)` specifying the size of the filter window.

"""
# Case for a tuple specifying patch size
function medianFilter3D(img, patch_size::Tuple{Int, Int, Int})
    return ImageFiltering.mapwindow(Statistics.median, img, patch_size)
end

# Case for a single integer specifying a square patch
function medianFilter3D(img, patch_size::Int=3)
    return ImageFiltering.mapwindow(Statistics.median, img, (patch_size, patch_size, patch_size))
end

"""
    imSmooth(data, σ::Real=0.05, size::Int=3)

Smooth a 2D image or apply a 2D Gaussian filter to each plane of a 3D volume.

# Arguments
- `data`: Input image or 3D volume.
- `σ`: Standard deviation of the Gaussian filter (default: 0.05).
- `size`: Size of the Gaussian kernel (default: 3).

"""
function imSmooth(data, σ::Real=0.05, size::Int=3)
    kernel = ImageFiltering.Kernel.gaussian((σ, σ), (size, size))
    
    if ndims(data) == 2
        # Apply the 2D filter directly
        return ImageFiltering.imfilter(data, kernel)
    elseif ndims(data) == 3
        # Apply the 2D filter to each plane
        return map(plane -> ImageFiltering.imfilter(plane, kernel), eachslice(data, dims=3))
    else
        throw(ArgumentError("Input data must be a 2D image or a 3D volume."))
    end
end

"""
    imSmooth3D(data, σ::Real=0.05, size::Int=3)

Smooth a 3D volume using a 3D Gaussian filter.

# Arguments
- `data`: Input 3D volume.
- `σ`: Standard deviation of the Gaussian filter (default: 0.05 for all dimensions).
- `size`: Size of the Gaussian kernel (default: 3 for all dimensions).

"""
function imSmooth3D(data, σ::Real=0.05, size::Int=3)
    if ndims(data) != 3
        throw(ArgumentError("Input data must be a 3D volume."))
    end

    # Create a 3D Gaussian kernel
    kernel = ImageFiltering.Kernel.gaussian((σ, σ, σ), (size, size, size))

    # Apply the 3D filter
    return ImageFiltering.imfilter(data, kernel)
end

"""
    imSharpen(data; σ::Real=1.0, size::Int=5, alpha::Real=1.0)

Apply unsharp masking to enhance edges in a 2D image or 3D volume (frame-by-frame).

# Arguments
- `data`: Input 2D image or 3D volume.
- `σ`: Standard deviation of the Gaussian filter used for smoothing (default: 1.0).
- `size`: Size of the Gaussian kernel (default: 5).
- `alpha`: Scaling factor for the sharpening effect (default: 1.0).

# Returns
The sharpened image or volume.
"""
function imSharpen(data, σ::Real=1.0, size::Int=5, alpha::Real=1.0)
    # Create the Gaussian kernel
    kernel = ImageFiltering.Kernel.gaussian((σ, σ), (size, size))

    if ndims(data) == 2
        # Apply unsharp masking to a 2D image
        smoothed = ImageFiltering.imfilter(data, kernel)
        return data + alpha * (data - smoothed)
    elseif ndims(data) == 3
        # Apply unsharp masking to each 2D frame in a 3D volume
        return map(frame -> begin
            smoothed = ImageFiltering.imfilter(frame, kernel)
            frame + alpha * (frame - smoothed)
        end, eachslice(data, dims=3))
    else
        throw(ArgumentError("Input data must be a 2D image or a 3D volume."))
    end
end


