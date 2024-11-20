
module deconSingle

using FFTW, FileIO, Images

    __precompile__()

    export ConvFFT3_S,flipPSF, align_size, deconvolve_image, load_image_stack

    
    function ConvFFT3_S(inVol, OTF)
        # Realiza la convolución 3D en el dominio de Fourier
        outVol = real(ifft(fft(inVol) .* OTF))
        return outVol
    end

    function flipPSF(inPSF)
        # Obtener las dimensiones de la PSF
        Sx, Sy = size(inPSF)
        Sz = 1  # Si la imagen es 2D, la tercera dimensión será de tamaño 1
    
        if ndims(inPSF) == 3
            Sz = size(inPSF, 3)
        end
        # Crear una matriz de ceros del mismo tamaño que la PSF de entrada
        outPSF = zeros(Sx, Sy, Sz)
        
        # Invertir la PSF en todas las dimensiones
        for i in 1:Sx
            for j in 1:Sy
                for k in 1:Sz
                    outPSF[i, j, k] = inPSF[Sx - i + 1, Sy - j + 1, Sz - k + 1]
                end
            end
        end
        
        return outPSF
    end
    
    function align_size(img1, Sx2, Sy2, Sz2, padValue::Float64=0.0)
        # Obtener las dimensiones de la imagen de entrada
        Sx1, Sy1 = size(img1)
        Sz1 = 1  # Si la imagen es 2D, la tercera dimensión será de tamaño 1
    
        if ndims(img1) == 3
            Sz1 = size(img1, 3)
        end
    
        # Calcular las dimensiones máximas
        Sx = max(Sx1, Sx2)
        Sy = max(Sy1, Sy2)
        Sz = max(Sz1, Sz2)
    
        # Crear una matriz temporal rellena con el valor de relleno
        imgTemp = fill(padValue, Sx, Sy, Sz)
    
        # Calcular los índices de inicio para alinear la imagen
        Sox = round(Int, (Sx - Sx1) / 2) + 1
        Soy = round(Int, (Sy - Sy1) / 2) + 1
        Soz = round(Int, (Sz - Sz1) / 2) + 1
    
        # Asegurarse de que los índices no se salgan de los límites de la imagen temporal
        Sox = max(Sox, 1)
        Soy = max(Soy, 1)
        Soz = max(Soz, 1)
    
        # Colocar la imagen original en la matriz de relleno
        imgTemp[Sox:Sox+Sx1-1, Soy:Soy+Sy1-1, Soz:Soz+Sz1-1].= img1
    
        # Calcular los índices de la imagen resultante
        Sox = round(Int, (Sx - Sx2) / 2) + 1
        Soy = round(Int, (Sy - Sy2) / 2) + 1
        Soz = round(Int, (Sz - Sz2) / 2) + 1
    
        # Asegurarse de que los índices no se salgan de los límites de la imagen temporal
        Sox = max(Sox, 1)
        Soy = max(Soy, 1)
        Soz = max(Soz, 1)
        
        # Asegurarse de que las dimensiones 3D solo se usen si la imagen es 3D
        if Sz2 == 1
            img2 = imgTemp[Sox:Sox+Sx2-1, Soy:Soy+Sy2-1]
        else
            img2 = imgTemp[Sox:Sox+Sx2-1, Soy:Soy+Sy2-1, Soz:Soz+Sz2-1]
        
        end
    
        return img2
    end
    # Función principal de deconvolución
    
    function deconvolve_image(imageStack, psfNormalized, iterations, smallValue=0.001)
        # Asegurarnos de que la imagen tiene 3 dimensiones (añadir una dimensión si es 2D)
        if ndims(imageStack) == 2
            imageStack = reshape(imageStack, size(imageStack, 1), size(imageStack, 2), 1)
        end
        
        Sx, Sy, Sz= size(imageStack)
        
        PSF_fp = align_size(psfNormalized, Sx, Sy, Sz)
        PSF2 = flipPSF(PSF_fp)
        PSF2 = PSF2 / sum(PSF2)
        PSF_bp = align_size(PSF2, Sx, Sy, Sz)
        
        # Inicialización de la estimación de la imagen
        stackEstimate = imageStack  # Usamos la imagen original para la inicialización
        stack = imageStack
        stack .= max.(stack,smallValue)
    
        # Proyectores en el dominio de Fourier
        OTF_fp = fft(ifftshift(PSF_fp))
        OTF_bp = fft(ifftshift(PSF_bp))  # Este es solo un ejemplo, en MATLAB hay una transformación más compleja
    
        # Deconvolución iterativa
        for i in 1:iterations
            # Realizamos la convolución en el dominio de Fourier utilizando las funciones correspondientes
            stackEstimate = stackEstimate .* ConvFFT3_S(stack ./ ConvFFT3_S(stackEstimate, OTF_fp), OTF_bp)
            
            # Aplicamos el valor mínimo para evitar valores negativos o pequeños
            stackEstimate .= max.(stackEstimate, smallValue)
        end    
        
        return stackEstimate
    end
    
    function load_image_stack(folder_path::String)
        # Listar todos los archivos en la carpeta y ordenar
        files = sort(filter(f -> endswith(f, ".tif") || endswith(f, ".png") || endswith(f, ".jpg"), readdir(folder_path)))
    
        # Leer la primera imagen para obtener las dimensiones
        first_image = load(joinpath(folder_path, files[1]))
        height, width = size(first_image)
    
        # Crear una matriz 3D vacía para almacenar las imágenes
        image_stack = Array{Float32, 3}(undef, height, width,length(files))
    
        # Leer el rango de valores para normalización
        max_val = Float32(maximum(first_image)) # Valor máximo para normalización
    
        # Cargar cada imagen en la matriz 3D y convertir a Float32
        for (i, file) in enumerate(files)
            image = load(joinpath(folder_path, file))
            image_stack[:, :, i] = Float32.(image) / max_val
        end
        
        return image_stack
    end
end
