module Process

# -------- Specific Module Packages
using Colors
using ImageContrastAdjustment: build_histogram as imageHistogram
import ImageContrastAdjustment as Contrast
import ImageFiltering, Statistics
using ImageEdgeDetection
using ImageEdgeDetection: Percentile, AbstractEdgeDetectionAlgorithm

# --------- Common packages
using ..Data

# from Images
using Images: AdaptiveEqualization, LinearStretching, Equalization, GammaCorrection, Matching, MidwayEqualization
using Images: FixedPointNumbers

# Exposure adjustment
include("Exposure.jl")
export autoContrast, adjContrast, imHistogram, imComplement
# Threshold
include("Thresholding.jl")
export imageThreshold, autoThreshold
# Filters
include("Filters.jl")
export imSmooth, imSharpen, medianFilter, imSmooth3D, medianFilter3D
# Feature Extraction
include("FeatureExtraction.jl")
export findEdges, gradientOrientation, computeThinnedEdges, findPeaks, sujoyEdgeDetector
# Segmentation
include("Segmentation.jl")
export labels_map, segment_labels, segment_pixel_count,segment_mean, seeded_region_growing, unseeded_region_growing, felzenszwalb, fast_scanning, watershed, hmin_transform, region_adjacency_graph, remove_segment, prune_segments, region_tree, region_splitting
# Deconvolution
include("Deconvolution.jl")
export deconvRL, BackProjector, deconvolution
# utils
include("utils.jl")

end