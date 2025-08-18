# Utility functions for internal usage of the module and generally not meant to be exported
###### Input reading functions/macros

# input dialog
function inputDialog(; label = "Select an image file", select_multiple=false) 
    📂 = select_multiple ? Dialog.pick_multi_file : Dialog.pick_file;
    file_path = 📂();
end

function inputDialog(formats::String; label = "Select an image file", select_multiple=false) 
    📂 = select_multiple ? Dialog.pick_multi_file : Dialog.pick_file;
    file_path = 📂(filterlist=formats);
end

function inputDialog(formats::Vector{String}; label = "Select an image file", select_multiple=false) 
    formats = join(formats,";")
    📂 = select_multiple ? Dialog.pick_multi_file : Dialog.pick_file;
    file_path = 📂(filterlist=formats);
end

# save dialog
function saveDialog(folder_only::Bool=false)
    file_path = folder_only ? Dialog.pick_folder() : Dialog.save_file(); 
end

function saveDialog(formats::String) 
    file_path = Dialog.save_file(filterlist=formats);
end

function saveDialog(formats::Vector{String}) 
    formats = join(formats,";")
    file_path = Dialog.save_file(filterlist=formats);
end