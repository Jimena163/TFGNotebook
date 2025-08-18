## Exposure adjustment
using Images: red, green, blue, complement
using Images: AbstractGray, AbstractRGB
using Plots: bar, bar!

# Autocontrast adjustment
function autoContrast(img::AbstractArray; algorithm=Contrast.LinearStretching)
    Contrast.adjust_histogram(img, algorithm())
end

# Contrast adjustment
function adjContrast(img::AbstractArray, min_val::Real=0, max_val::Real=1)
    Contrast.adjust_histogram(img, Contrast.LinearStretching(dst_minval = min_val, dst_maxval = max_val))
end

# Calculate image histogram
function imHistogram(img::AbstractArray{T}, bitdepth::Int=8) where T <: Union{AbstractGray, Number}
    edges, counts = imageHistogram(img, 2^bitdepth)
    counts = reverse(collect(counts))
    return edges, counts
end

function imHistogram(img::AbstractArray{T}, bitdepth::Int=8) where T <: AbstractRGB
    edges = Vector{Vector{Float64}}(undef, 3)
    counts = Vector{Vector{Int}}(undef, 3)
    for (i, c) in enumerate((red, green, blue))
        edges[i], counts[i] = imHistogram(c.(img), bitdepth)
    end
    return edges, counts
end

function imHistogram(img::AbstractArray{T}, plot::Bool, bitdepth::Int=8; alpha::Real=0.5, color=:black, label="") where T <: AbstractGray
    plot == true || return imHistogram(img, bitdepth)
    _, counts = imHistogram(img, bitdepth)
    bar(counts, label=label, linecolor=color, fillcolor=color, alpha=alpha)
end

function imHistogram(img::AbstractArray{T}, plot::Bool, bitdepth::Int=8; alpha::Real=0.5, colors=[:red, :green, :blue], labels=["red", "green", "blue"]) where T <: AbstractRGB
    plot == true || return imHistogram(img, bitdepth)
    _, counts = imHistogram(img, bitdepth)
    bar(counts[1], label=labels[1], linecolor=colors[1], fillcolor=colors[1], alpha=alpha)
    bar!(counts[2], label=labels[2], linecolor=colors[2], fillcolor=colors[2], alpha=alpha)
    bar!(counts[3], label=labels[3], linecolor=colors[3], fillcolor=colors[3], alpha=alpha)
end

# find image complement
function imComplement(img::AbstractArray)
    complement.(img)
end