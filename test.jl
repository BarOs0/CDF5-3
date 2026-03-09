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

test_size = 8

test = zeros(test_size)

# for i in 1:test_size
#     test[i] = i-1
# end

test[1] = -1565
test[2] = 2315
test[3] = 7124
test[4] = 12278
test[5] = 12741
test[6] = 25281
test[7] = -1981
test[8] = 11176

odd = test[2:2:end]
even = test[1:2:end]

println("test: ", test, " {", length(test), "}")
println("odd: ", odd, " {", length(odd), "}")
println("even: ", even, " {", length(even), "}")

res = predict(odd,even)
println("result: ", res)