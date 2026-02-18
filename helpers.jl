function fft_radix2_dit_r(x::Vector)::Vector
    N = length(x)
    if N == 1
        return x
    end
    p = x[1:2:N]
    np = x[2:2:N]
    P = fft_radix2_dit_r(p)
    NP = fft_radix2_dit_r(np)
    result = zeros(ComplexF64,N)
    w = exp(1im*2*pi/N)
    for k in 0:div(N,2)-1
        result[k+1] = P[k+1] + w^(-k)*NP[k+1]
        result[k+1+div(N,2)] = P[k+1] - w^(-k)*NP[k+1]
    end
    return result
end

function pad_to_pow2(x::Vector)::Vector
    N = length(x)
    N2 = 2^ceil(Int, log2(N))
    if N == N2
        return x
    else
        return vcat(x, zeros(N2 - N))
    end
end

function pad_to_pow2_2d(x::Matrix)::Matrix
    R, C = size(x)
    R2 = 2^ceil(Int, log2(R))
    C2 = 2^ceil(Int, log2(C))

    if (R == R2) && (C == C2)
        return x
    elseif (R == R2) && (C != C2)
        return hcat(x, zeros(Float64, R, C2 - C))
    elseif (R != R2) && (C == C2)
        return vcat(x, zeros(Float64, R2 - R, C))
    else
        padding = zeros(Float64, R2, C2)
        padding[1:R, 1:C] = x
        return padding
    end
end

function dwt(x::Vector)::Vector

    # === Slicing === 
    even = x[1:2:end] # approx
    odd = x[2:2:end] # detail

    # === Predict === 
    for i in 1:length(odd)
        if i == 1
            odd[i] -= even[i]
        elseif i <= length(even) - 1
            odd[i] -= (even[i] + even[i+1]) / 2
        else
            odd[i] -= even[i]  
        end
    end

    # === Update === 
    for i in 1:length(even)
        if i == 1
            even[i] += odd[i] / 2
        elseif i <= length(odd)
            even[i] += (odd[i-1] + odd[i]) / 4
        else
            even[i] += odd[i-1] / 2  
        end
    end

    X = [even; odd]
    return X
end

function idwt(X::Vector)::Vector

    # === IDWT = DWT REVERSED ===
    N = Int(length(X) / 2)
    even = X[1:N]
    odd = X[N+1:end]

    # === Undo update === 
    for i in 1:length(even)
        if i == 1
            even[i] -= odd[i] / 2
        elseif i <= length(odd)
            even[i] -= (odd[i-1] + odd[i]) / 4
        else
            even[i] -= odd[i-1] / 2  
        end
    end

    # === Undo predict ===
    for i in 1:length(odd)
        if i == 1
            odd[i] += even[i]
        elseif i <= length(even) - 1
            odd[i] += (even[i] + even[i+1]) / 2
        else
            odd[i] += even[i]  
        end
    end

    x = zeros(length(X))
    x[1:2:end] = even
    x[2:2:end] = odd
    return x
        
end

function lift(x::Matrix, levels::Integer)::Matrix

    X = copy(x) # nastepne poziomy musza uzywac wczensniejszego X 
    rows, columns = size(X)

    for level in 1:levels

        # Najpierw zmiany pionowe (wiersze)
        for i in 1:rows
            X[i, 1:columns] = dwt(X[i, 1:columns]) 
        end

        # Potem zmiany poziome (kolumny)
        for j in 1:columns
            X[1:rows, j] = dwt(X[1:rows, j])
        end

        # LH -> Low pion, High poziom = PIONOWE KRAWEDZIE UWYDATNIONE
        # HL -> High pion, Low poziom = POZIOME KRAWEDZIE UWYDATNIONE

        rows = Int(rows / 2)
        columns = Int(columns / 2)
    end

    return X
end

function normalize_img(img::Matrix, gamma::Float64)::Matrix
    return (img./maximum(img)).^gamma
    # tutaj zakldam ze przekazuje wartosc bezwzgledna abs.(img)
    # gamma < 1 rozjasnienie
    # gamma > 1 przyciemnienie
end

    # 0.0 -> czarny
    # 0.5 -> szary
    # 1.0 -> biały

function get_subbands(X::Matrix, levels::Integer, dir::String, gamma::Float64)
    R, C = size(X)
    # wielkosc obrazu reprezentuje sie:
    # szerokosc x wysokosc
    # kolumny x wiersze

    # prepare dimensions for given level
    size_R = Int(R / 2^(levels-1))
    size_C = Int(C / 2^(levels-1))

    half_size_R = Int(size_R / 2)
    half_size_C = Int(size_C / 2)

    # cut subbands
    LL = X[1:half_size_R, 1:half_size_C]
    LH = X[1:half_size_R, (half_size_C + 1):size_C]
    HL = X[(half_size_R + 1):size_R, 1:half_size_C]
    HH = X[(half_size_R + 1):size_R, half_size_C:size_C]

    # Macierz DWT
    # ┌────┬────┬─────────┐
    # │LL₂ │LH₂ │         │  przykladowo levels = 2
    # ├────┼────┤   LH₁   │  dla kolejnych poziomow przetwarzany jest tylko blok LL
    # │HL₂ │HH₂ │         │  H -> Detale (zmiany, ostre) (High-pass)
    # ├────┴────┼─────────┤  L -> Aproksymacja (core, gładkie) (Low-pass)
    # │   HL₁   │   HH₁   │  
    # └─────────┴─────────┘

    # Save 
    save(joinpath(dir, "dwt_level$(levels)_LL.png"), Gray.(normalize_img(abs.(LL), gamma)))
    save(joinpath(dir, "dwt_level$(levels)_LH.png"), Gray.(normalize_img(abs.(LH), gamma)))
    save(joinpath(dir, "dwt_level$(levels)_HL.png"), Gray.(normalize_img(abs.(HL), gamma)))
    save(joinpath(dir, "dwt_level$(levels)_HH.png"), Gray.(normalize_img(abs.(HH), gamma)))

    # Statistics (Min, Max)
    println(" ")
    println("=== Subbands statistics ===")
    println("LL: min=$(minimum(LL)), max=$(maximum(LL))")
    println("LH: min=$(minimum(LH)), max=$(maximum(LH))")
    println("HL: min=$(minimum(HL)), max=$(maximum(HL))")
    println("HH: min=$(minimum(HH)), max=$(maximum(HH))")
end

