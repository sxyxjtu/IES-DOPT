using Oxygen, HTTP
import JSON

#using DataFrames

include("./head.jl")
include("./components.jl")
include("./simulation.jl")


# #####实际运行时需注释掉此部分
# #示例数据
# paras = Dict("汽轮机出口压力" => 100000,
#             "水泵出口压力" => 700000,
#             "锅炉出口温度" => 701)
# #调用后端模型获得数据
# Data1 = simulate!(paras)
# #####


# 跨域解决方案
const CORS_HEADERS = [
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Headers" => "*",
  "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]
function CorsMiddleware(handler)
  return function (req::HTTP.Request)
    # println("CORS middleware")
    # determine if this is a pre-flight request from the browser
    if HTTP.method(req) ∈ ["POST", "GET", "OPTIONS"]
      return HTTP.Response(200, CORS_HEADERS, HTTP.body(handler(req)))
    else
      return handler(req) # passes the request to the AuthMiddleware
    end
  end
end

@post "/simulation" function (req)
  # 将HTTP请求的正文（request body）转换为 Julia 中的字典（Dict）数据结构
  paras = json(req)
  # 调用后端模型获得数据
  #table = simulate!(paras["inputdata"], Val(paras["mode"]))
  #println(paras)
	println(paras)
  figure,table = simulate!(paras["inputdata"],Val(paras["mode"]))
  #println(figure)
  # 返回数据，匹配前端request要求的格式
  return Dict(
    "code" => 200,
    "message" => "success",
    "data" => Dict(
    # "table" => getTableData(table),
      "table" => OrderedDict(k => round(v, digits=2) for (k, v) in table),
      "figure" => Dict(
      "xyAxis" => figure,
      )
    ))
end

@get "hello" function (req)
    return Dict(
      "code" => 200,
      "message" => "success",
      "data" => "hello world"
    )
  end
  # 本地测试 async=true，服务器上 async=false。同步测试便于调试
  serve(host="0.0.0.0", port=8080, async=true)
  # serve(port=8080, async=true)


