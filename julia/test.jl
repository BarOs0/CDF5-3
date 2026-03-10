function predict(odd::Vector, even::Vector)::Vector
    for i in 1:length(odd)
        if i == 1
            odd[i] -= even[i]
        elseif i <= length(even) - 1
            odd[i] -= (even[i] + even[i+1]) / 2
        else
            odd[i] -= even[i]
        end
    end
    return odd
end

function update(odd::Vector, even::Vector)::Vector
    for i in 1:length(even)
            if i == 1
                even[i] += odd[i] / 2
            elseif i <= length(odd)
                even[i] += (odd[i-1] + odd[i]) / 4
            else
                even[i] += odd[i-1] / 2  
            end
        end
    return even
end

test_size = 16

test = zeros(test_size)

# for i in 1:test_size
#     test[i] = i-1
# end

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
