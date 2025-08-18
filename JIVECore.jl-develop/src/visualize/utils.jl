###### Output plotting functions/macros

# Image Window
function imageWindow(path::String)
	image = load(path)
	img_name = split(path,"\\")[end]
	imshow(image, name=img_name)
end

function imageWindow(image...)
	isempty(image) ? "" : imshow(mosaicview(image..., nrow=1))
end

function imageWindow(image,path::String)
	img_name = split(path,"\\")[end]
	isempty(image) ? "" : imshow(image, name=img_name)
end

# Channel View
function channelView(rgb_image)
    v = channelview(rgb_image)
    imshow(PermutedDimsArray(v, (2,3,1)))
end

# GIF
function gif(image)
    ImageShow.gif(image)
end


