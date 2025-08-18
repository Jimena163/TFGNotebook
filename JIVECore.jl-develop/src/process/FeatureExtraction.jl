## Feature Extraction

"""
    findEdges(image, spatial_scale::Real=1, high::Real=Percentile(80), low::Real=Percentile(20))

Detect edges in the given `image` using the Canny edge detection algorithm with specified parameters.

# Arguments
- `image`: The input image in which edges are to be detected.
- `spatial_scale::Real`: The spatial scale parameter for the Canny algorithm. Default is 1.
- `high::Real`: The high threshold for the Canny algorithm, specified as a percentile. Default is 80th percentile.
- `low::Real`: The low threshold for the Canny algorithm, specified as a percentile. Default is 20th percentile.

# Returns
- `edges`: A binary image where edges are marked.

"""
function findEdges(image::AbstractArray, alg::AbstractEdgeDetectionAlgorithm)
    edges = ImageEdgeDetection.detect_edges(image, alg)
end

function findEdges(image::AbstractArray; spatial_scale::Real=1, high::Real=Percentile(80), low::Real=Percentile(20), thinning_algorithm=NonmaximaSuppression(threshold = low))
    alg = Canny(spatial_scale=spatial_scale, high=high, low=low, thinning_algorithm=thinning_algorithm)
    edges = findEdges(image, alg)
end

function findEdges(image::AbstractArray, subpixel_detection::Bool; spatial_scale::Real=1, high::Real=Percentile(80), low::Real=Percentile(20), thinning_algorithm=nothing)
    default_thinning_algorithm = subpixel_detection ? ImageEdgeDetection.SubpixelNonmaximaSuppression(threshold = low) : ImageEdgeDetection.NonmaximaSuppression(threshold = low)
    thinning_algorithm = isnothing(thinning_algorithm) ? default_thinning_algorithm : thinning_algorithm
    if subpixel_detection
        alg = Canny(spatial_scale=spatial_scale, high=high, low=low, thinning_algorithm=thinning_algorithm)
        edges = ImageEdgeDetection.detect_subpixel_edges(image, alg)
    else
        edges = findEdges(image; spatial_scale=spatial_scale, high=high, low=low, thinning_algorithm=thinning_algorithm)
    end
    return edges
end

"""
    gradientOrientation(im, in_radians=true, is_clockwise=false, compass_direction='E')

Compute the gradient orientation of an image.

# Arguments
- `im::AbstractArray`: The input image for which the gradient orientation is to be computed.
- `in_radians::Bool`: If `true`, the angles are returned in radians. If `false`, the angles are returned in degrees. Default is `true`.
- `is_clockwise::Bool`: If `true`, the angles are measured clockwise. If `false`, the angles are measured counter-clockwise. Default is `false`.
- `compass_direction::Char`: The compass direction from which the angles are measured. Default is `'E'` (East).

# Returns
- `angles::AbstractArray`: An array of gradient orientations for the input image.

# Description
This function computes the gradient orientation of an image using the Scharr operator. The gradient is computed in the first and second spatial dimensions. The angles are interpreted with respect to a canonical Cartesian coordinate system, where the angles are measured counter-clockwise from the positive x-axis by default. The orientation convention can be customized using the `in_radians`, `is_clockwise`, and `compass_direction` parameters.
"""
function gradientOrientation(im::AbstractArray, in_radians = true, is_clockwise = false, compass_direction = 'E')
    # Gradient in the first and second spatial dimension
    g₁, g₂ = imgradients(Gray.(im), KernelFactors.scharr)
    # Interpret the angles with respect to a canonical Cartesian coordinate system
    # where the angles are measured counter-clockwise from the positive x-axis.
    orientation_convention = OrientationConvention(in_radians = in_radians,
                                                   is_clockwise = is_clockwise,
                                                   compass_direction = compass_direction)
    angles = detect_gradient_orientation(g₁, g₂, orientation_convention)
    return angles
end

"""
    computeThinnedEdges(img)

Compute the thinned edges of an image using gradient magnitude and non-maxima suppression.

# Arguments
- `img`: The input image.

# Returns
- `thinnedEdges`: The thinned edges of the input image.
"""
function computeThinnedEdges(img, threshold = Percentile(10))
    # Gradient in the first and second spatial dimension
    g1, g2 = imgradients(img, KernelFactors.scharr)
    # Gradient magnitude
    mag = hypot.(g1, g2)
    f = NonmaximaSuppression(threshold = threshold)
    thinnedEdges = ImageEdgeDetection.thin_edges(mag, g1, g2, f)
end


"""
    edges = sujoyEdgeDetector(img; four_connectivity=true)

Compute edges of an image using the Sujoy algorithm.

# Parameters

* `img` (Required): any gray image
* `four_connectivity=true`: if true, kernel is based on 4-neighborhood, else, kernel is based on
   8-neighborhood,

# Returns

* `edges` : gray image
"""
function sujoyEdgeDetector(img::AbstractArray; four_connectivity::Bool=true)
    img_channel = Gray.(img)

    min_val = minimum(img_channel)
    img_channel = img_channel .- min_val
    max_val = maximum(img_channel)

    if max_val == 0
        return img
    end

    img_channel = img_channel./max_val

    if four_connectivity
        krnl_h = centered(Gray{Float32}[0 -1 -1 -1 0; 0 -1 -1 -1 0; 0 0 0 0 0; 0 1 1 1 0; 0 1 1 1 0]./12)
        krnl_v = centered(Gray{Float32}[0 0 0 0 0; -1 -1 0 1 1;-1 -1 0 1 1;-1 -1 0 1 1;0 0 0 0 0 ]./12)
    else
        krnl_h = centered(Gray{Float32}[0 0 -1 0 0; 0 -1 -1 -1 0; 0 0 0 0 0; 0 1 1 1 0; 0 0 1 0 0]./8)
        krnl_v = centered(Gray{Float32}[0 0 0 0 0;  0 -1 0 1 0; -1 -1 0 1 1;0 -1 0 1 0; 0 0 0 0 0 ]./8)
    end

    grad_h = imfilter(img_channel, krnl_h')
    grad_v = imfilter(img_channel, krnl_v')

    grad = (grad_h.^2) .+ (grad_v.^2)

    return grad
end


"""
    findPeaks(image::AbstractArray; min_distance::Int=1, threshold_abs::Real=0, threshold_rel::Union{Real, Nothing}=nothing, exclude_border::Union{Int,Bool}=false, num_peaks::Union{Int,Nothing}=nothing, light_background::Bool=false)

Find local maxima in an image.

# Arguments
- `image::AbstractArray`: The input image in which to find local maxima.
- `min_distance::Int=1`: Minimum number of pixels separating peaks in a region of `2 * min_distance + 1` (i.e., peaks are separated by at least `min_distance`).
- `threshold_abs::Real=0`: Minimum intensity of peaks. Local maxima with intensity less than this value will be ignored.
- `threshold_rel::Union{Real, Nothing}=nothing`: Minimum intensity of peaks, calculated as `maximum(image) * threshold_rel`. If provided, `threshold_abs` is ignored.
- `exclude_border::Union{Int,Bool}=false`: If `true`, excludes peaks near the border of the image. If an integer, excludes peaks within `exclude_border` pixels of the border.
- `num_peaks::Union{Int,Nothing}=nothing`: Maximum number of peaks to return. If `nothing`, all peaks are returned.
- `light_background::Bool=false`: If `true`, finds local minima instead of maxima (useful for images with light background).

# Returns
- `maxima_coords`: A list of coordinates of the local maxima.

"""
function findPeaks(image::AbstractArray; min_distance::Int=1, threshold_abs::Real=0, threshold_rel::Union{Real, Nothing}=nothing, exclude_border::Union{Int,Bool}=false, num_peaks::Union{Int,Nothing}=nothing, light_background::Bool=false) 
    # Calculate relative threshold if provided
    threshold_abs = threshold_rel !== nothing ? maximum(image) * threshold_rel : threshold_abs

    # Find local maxima using findlocalmaxima
    maxima_coords = light_background ? findlocalminima(image) : findlocalmaxima(image)
    
    # Filter maxima based on threshold_abs
    maxima_coords = [p for p in maxima_coords if image[p] > threshold_abs]
    
    # Exclude maxima near the border if exclude_border is specified
    if exclude_border !== false
        if exclude_border === true
            exclude_border = min_distance
        end
        maxima_coords = [p for p in maxima_coords if all(Tuple(p) .> exclude_border) && all(Tuple(p) .<= (size(image) .- exclude_border))]
    end
    
    # Filter maxima based on min_distance in pixels
    if min_distance > 1
        maxima_coords = [p for p in maxima_coords if all(q -> p == q || sqrt(sum((Tuple(p) .- Tuple(q)).^2)) >= min_distance, maxima_coords)]
    end
    
    # Limit the number of peaks if num_peaks is specified
    if num_peaks !== nothing
        maxima_coords = sort(maxima_coords, by=p -> -image[p])
        maxima_coords = maxima_coords[1:min(num_peaks, length(maxima_coords))]
    end
    
    return maxima_coords
end