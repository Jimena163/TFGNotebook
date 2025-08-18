### OPEN FILES

"""
    img = loadImage()

Returns an image selected by the user
"""
# Function to load a single image selected by the user
function loadImage()
    path = inputDialog(SUPPORTED_IMAGE_FORMATS)
    img = isempty(path) ? nothing : loadImage(path)
end

# Function to load an image from a given path
function loadImage(path::String)
    img = FileIO.load(path)
end

# Function to load multiple images from given paths and store them in a dictionary
function loadImage(paths::Vector{String})
    images = Dict{String, Any}()
    if !isempty(paths)
        for path in paths
            images[basename(path)] = loadImage(path)
        end
    end
    return images
end

# Function to load images with an option to select multiple files
function loadImage(select_multiple::Bool)
    path = inputDialog(SUPPORTED_IMAGE_FORMATS, select_multiple=select_multiple)
    loadImage(path)
end

"""
    img = loadVideo()

Returns a video selected by the user
"""
function loadVideo()
    path = inputDialog(SUPPORTED_VIDEO_FORMATS)
    video = isempty(path) ? nothing : VideoIO.load(path)
end

"""
    img = loadSequence()

Returns a sequence of images (stored in multiple files) selected by the user
"""
function loadSequence()
    path = inputDialog(SUPPORTED_IMAGE_FORMATS, select_multiple=true)
    img = isempty(path) ? nothing : FileIO.load(path[1])
    for i in range(2,length(path))
        img[i] = FileIO.load(path[i])
    end    
    return img    
end

function loadSequence(folder::String; 
    num_images::Union{Int, Nothing} = nothing, 
    start_image::Int = 1, 
    increment::Int = 1, 
    name_filter::String = "", 
    pattern::Union{Regex, Nothing} = nothing, 
    scale::Float64 = 1.0, 
    convert_to_rgb::Bool = false, 
    sort_numerically::Bool = false, 
    use_virtual_stack::Bool = false)

    # Get list of image files in folder
    all_files = readdir(folder)
    image_files = filter(f -> endswith(f, r".png|.jpg|.jpeg|.tif|.tiff|.bmp"), all_files)

    # Apply name filtering
    if name_filter != ""
    image_files = filter(f -> occursin(name_filter, f), image_files)
    end

    # Apply regex pattern filtering
    if pattern !== nothing
    image_files = filter(f -> match(pattern, f) !== nothing, image_files)
    end

    # Sort filenames numerically or alphanumerically
    if sort_numerically
    image_files = sort(image_files, by = x -> parse(Int, match(r"\d+", x).match))
    else
    image_files = sort(image_files)
    end

    # Apply starting index and increment
    image_files = image_files[start_image:increment:end]

    # Limit to num_images if specified
    if num_images !== nothing
    image_files = image_files[1:min(num_images, length(image_files))]
    end

    # Full paths to images
    image_paths = joinpath.(folder, image_files)

    # Handle virtual stack
    if use_virtual_stack
    return image_paths  # Return file paths for on-demand loading
    end

    # Load images
    loaded_images = map(load, image_paths)

    # Resize if scaling is specified
    if scale != 1.0
    loaded_images = [imresize(img; ratio=scale) for img in loaded_images]
    end

    # Convert to RGB if specified
    if convert_to_rgb
    loaded_images = map(img -> colorview(RGB, img), loaded_images)
    end

    return loaded_images
end


"""
    key = loadImage!()

Loads an image from the filesystem and adds it to the `image_data` dictionary.
Its key is stored in `image_keys` and also returned
"""
function loadImage!(image_data::Dict, image_keys::Array)
    path = inputDialog(SUPPORTED_IMAGE_FORMATS)
    name = split(splitpath(path)[end],".")[1]
    key = Data.keyCheck(image_data, String(name))
    image_data[key] = isempty(path) ? nothing : FileIO.load(path)
    push!(image_keys, key)
    println("Image stored as \"$(key)\" ")
    return key
end

loadImage!(name::String, image_data::Dict, image_keys::Array) = begin
    key = Data.keyCheck(image_data, name)
    image_data[key] = loadImage()
    push!(image_keys, key)
    println("Image stored as \"$(key)\" ")
    return key
end

"""
    out = loadClipboard()

    
"""
function loadClipboard()
    # Get clipboard content based on the operating system
    content = ""

    if Sys.iswindows()
        content = read(`powershell Get-Clipboard`, String)
    elseif Sys.isapple()
        content = read(`pbpaste`, String)
    elseif Sys.isunix()
        content = read(`xclip -o -selection clipboard`, String)
    else
        error("Unsupported OS")
    end

    # Strip whitespace
    content = strip(content)

    # Try to classify the clipboard content
    if isempty(content)
        return nothing  # Empty clipboard
    end

    # Detect tabular data (with tabs or commas, multi-line)
    if occursin(r"[\t]", content) || occursin(r"\n.*[,]", content)
        try
            return CSV.read(IOBuffer(content), DataFrame; delim='\t')
        catch
            try
                return CSV.read(IOBuffer(content), DataFrame)
            catch
                return split(content, '\n')  # Fallback for tabular-like data
            end
        end

    # Detect single numeric value
    elseif occursin(r"^\s*[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?\s*$", content)
        return parse(Float64, content)

    # Detect list-like data (comma-separated single line)
    elseif occursin(r"^([^,\n]+,)+[^,\n]+$", content)
        return split(content, ",")

    # Detect multi-line text
    elseif occursin(r"\n", content)
        return split(content, '\n')

    # Fallback to plain text
    else
        return content
    end
end

"""
    img = loadPreviousImage(path::String)
    
Loads the image that comes before the one indicated by the input path in the same directory.
"""
function loadPreviousImage(path::String)
    folder, filename = dirname(path), basename(path)
    all_files = readdir(folder)
    image_files = filter(f -> endswith(f, r".png|.jpg|.jpeg|.tif|.tiff|.bmp"), all_files)
    sorted_files = sort(image_files)
    
    idx = findfirst(x -> x == filename, sorted_files)
    if idx === nothing || idx == 1
        return nothing  # No previous image available
    end
    
    previous_image_path = joinpath(folder, sorted_files[idx - 1])
    return FileIO.load(previous_image_path)
end

"""
    img = loadNextImage(path::String)

Loads the image that comes after the one indicated by the input path in the same directory.
"""
function loadNextImage(path::String)
    folder, filename = dirname(path), basename(path)
    all_files = readdir(folder)
    image_files = filter(f -> endswith(f, r".png|.jpg|.jpeg|.tif|.tiff|.bmp"), all_files)
    sorted_files = sort(image_files)
    
    idx = findfirst(x -> x == filename, sorted_files)
    if idx === nothing || idx == length(sorted_files)
        return nothing  # No next image available
    end
    
    next_image_path = joinpath(folder, sorted_files[idx + 1])
    return FileIO.load(next_image_path)
end
