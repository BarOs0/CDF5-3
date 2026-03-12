function predict(odd::Vector{Int}, even::Vector{Int})::Vector{Int}
    for i in 1:length(odd)
        if i == 1
            odd[i] -= even[i]
        elseif i <= length(even) - 1
            odd[i] -= floor(Int, (even[i] + even[i+1]) / 2)
        else
            odd[i] -= even[i]
        end
    end
    return odd
end

function update(odd::Vector{Int}, even::Vector{Int})::Vector{Int}
    for i in 1:length(even)
            if i == 1
                even[i] += floor(Int, odd[i] / 2)
            elseif i <= length(odd)
                even[i] += floor(Int, (odd[i-1] + odd[i]) / 4)
            else
                even[i] += floor(Int, odd[i-1] / 2)  
            end
        end
    return even
end

test_size = 16

test = zeros(Int, test_size)

# for i in 1:test_size
#     test[i] = i-1
# end

# 0h0FFF
# test[1] = 2531
# test[2] = 2315
# test[3] = 3028
# test[4] = 4086
# test[5] = 453
# test[6] = 705
# test[7] = 2115
# test[8] = 2984
# test[9] = 3021
# test[10] = 1047
# test[11] = 2975
# test[12] = 3474
# test[13] = 1752
# test[14] = 994
# test[15] = 2362
# test[16] = 677

# = 0h00FF
# test[1] = 227
# test[2] = 11
# test[3] = 212
# test[4] = 246
# test[5] = 197
# test[6] = 193
# test[7] = 67
# test[8] = 168
# test[9] = 205
# test[10] = 23
# test[11] = 159
# test[12] = 146
# test[13] = 216
# test[14] = 226
# test[15] = 58
# test[16] = 165

# 0h000F
test[1] = 3
test[2] = 11
test[3] = 4
test[4] = 6
test[5] = 5
test[6] = 1
test[7] = 3
test[8] = 8
test[9] = 13
test[10] = 7
test[11] = 15
test[12] = 2
test[13] = 8
test[14] = 2
test[15] = 10
test[16] = 5

odd = test[2:2:end]
even = test[1:2:end]

println("test: ", test, " {", length(test), "}")
println("odd: ", odd, " {", length(odd), "}")
println("even: ", even, " {", length(even), "}")
println("")
println("======================= PREDICT ========================")
res_predict = predict(odd, even)
println("result predict: ", res_predict, " {", length(res_predict), "}")
println("========================================================")
println("")
println("======================== UPDATE ========================")
res_update = update(res_predict, even)
println("result update: ", res_update, " {", length(res_update), "}")
println("========================================================")


