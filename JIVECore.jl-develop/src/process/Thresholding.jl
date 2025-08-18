## Thresholding

function pixelThreshold(value, threshold)
    mapc(x->clamp(x, threshold, 1), value)
end

function imageThreshold(image, threshold::Real=0)
    T = typeof(image)
    T(map(x->pixelThreshold(x, threshold), image))
end

# ------

function autoThreshold(image::Matrix{Gray{FixedPointNumbers.N0f8}}, method=HT.Otsu())
    threshold = find_threshold(image, method; nbins=256)
    imageThreshold(image, threshold)
end

function autoThreshold(image::Matrix{Gray{FixedPointNumbers.N0f16}}, method=HT.Otsu())
    threshold = find_threshold(image, method; nbins=65536)
    imageThreshold(image, threshold)
end

function autoThreshold(image::Matrix{RGB{FixedPointNumbers.N0f8}}, method=HT.Otsu())
    threshold = find_threshold(image, method; nbins=256)
    imageThreshold(image, threshold)
end

function autoThreshold(image::Matrix{RGB{FixedPointNumbers.N0f16}}, method=HT.Otsu())
    find_threshold(image, method; nbins=65536)
    imageThreshold(image, threshold)
end