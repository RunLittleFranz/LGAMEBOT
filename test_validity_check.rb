matrix = [
    [1, 3, 3, 0],
    [0, 2, 3, 0],
    [0, 2, 3, 0],
    [0, 2, 2, 1]
]

def sub_matrix(matrix, v)
    xsub = []
    ysub = []
    matrix.each do |sub_m|
        count = 0
        sub_m.each.with_index do |elem, i|
            xsub[i] = 0 if xsub[i].nil?
            if elem == v 
                count += 1
                xsub[i] += 1
            end
        end
        ysub << count
    end
    return [xsub, ysub]
end

def check_validity(matrix, v) # matrice di ingresso e valore da controllare => ritorna true se il valore compone una forma a L 31/13 112/211
    sub_m = sub_matrix(matrix, v)
    flag = true
    sub_m.each do |ssm|
        if (ssm - [0]) == [3,1] || (ssm - [0]).reverse == [3,1] || (ssm - [0]) == [2,1,1] || (ssm - [0]).reverse == [2, 1, 1] 
            flag &= !(ssm.join =~ /13|31|112|211/).nil?       
        else 
            flag = false
        end
    end
    return flag
end

puts check_validity(matrix, 2)