function transposeMatrix(xAxis, yAxis)
    result = [[xAxis[i], yAxis[i]] for i in 1:length(yAxis)]
    #println(result)
    return result
end

function plot_local(data)
     # 提取x和y坐标
     xa = [point[1] for point in data]
     ya = [point[2] for point in data]
     # 创建散点图
    fig = plot(xa, ya, label="数据点", legend=true, markersize=6)
    display(fig)
end




