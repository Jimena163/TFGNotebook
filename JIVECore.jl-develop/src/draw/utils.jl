function draw_shape(path)
    img = isempty(path) ? nothing : FileIO.load(path)

    # Add image
    img_height, img_width = size(img)

    # Convertir la imagen a un formato que Plotly pueda usar (base64)
    io = IOBuffer()
    PNGFiles.save(io, img)
    img_data = base64encode(take!(io))

    layout = Layout(
        xaxis = attr(showgrid=false, range=(0,img_width)),
        yaxis = attr(showgrid=false, scaleanchor="x", range=(img_height, 0)),
        images=[
            attr(
                x=0,
                sizex=img_width,
                y=0,
                sizey=img_height,
                xref="x",
                yref="y",
                opacity=1.0,
                layer="below",
                source="data:image/png;base64,$img_data",
            )
        ],
        dragmode="drawrect",
        newshape=attr(line_color="cyan"),
        title_text="Drag to add annotations - use modebar to change drawing tool",
        modebar_add=[
            "drawline",
            "drawopenpath",
            "drawclosedpath",
            "drawcircle",
            "drawrect",
            "eraseshape"
        ],
    )

    Plot(layout)
end