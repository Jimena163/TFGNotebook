using Images: otsu_threshold
using Images.ImageSegmentation

function segmentImage(img::AbstractArray, args...; method::String="otsu")
    img_gray = method in ["otsu", "watershed"] ? Data.im2gray(img) : nothing
    segments, th = nothing, nothing

    segments = if method == "otsu"
        th = otsu_threshold(img_gray)
        img_gray .> th
    elseif method == "seeded"
        seeded_region_growing(img, args...)
    elseif method == "unseeded"
        unseeded_region_growing(img, args...)
    elseif method == "felzenszwalb"
        felzenszwalb(img, args...)
    elseif method == "fast"
        fast_scanning(img, args...)
    elseif method == "watershed"
        watershed(img_gray, args...)
    else
        throw(ArgumentError("Invalid segmentation method."))
    end

    if method == "otsu"
        return Data.Gray.(segments), th
    else
        imgs = map(i -> segment_mean(segments, i), labels_map(segments))
        return imgs, segments
    end
end
