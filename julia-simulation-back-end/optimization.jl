optimizate!(paras,::Val{1}) = optimizate_rankine(paras["朗肯循环参数"]["冷凝器冷却压力(pa)"],
                                    paras["朗肯循环参数"]["水泵供给压力(pa)"],
                                    paras["朗肯循环参数"]["锅炉出口温度(k)"],
									                  paras["朗肯循环参数"]["工质"]
															     )

function optimizate_rankine(汽轮机出口压力,水泵出口压力,锅炉出口温度,工质)

	汽轮机出口压力 = 汽轮机出口压力 isa Number ? 汽轮机出口压力 : parse(Float64,汽轮机出口压力)
  水泵出口压力 = 水泵出口压力 isa Number ? 水泵出口压力 : parse(Float64,水泵出口压力)
	锅炉出口温度 = 锅炉出口温度 isa Number ? 锅炉出口温度 : parse(Float64,锅炉出口温度)


    @info "创建组件..."
      @named turbine = Turbine(P = 汽轮机出口压力,fluid = 工质)
      @named condenser = Condenser(fluid = 工质)
      @named pump = Pump(P = 水泵出口压力,fluid = 工质)
      @named boiler = Boiler(T = 锅炉出口温度,fluid = 工质)

    @info "创建系统..."
  # 构建连接关系
  rc_eqs = [
      connect(turbine.out, condenser.in)
      connect(condenser.out,pump.in)
      connect(pump.out,boiler.in)
      connect(boiler.out,turbine.in)
      D(x) ~ 0
  ]
  @named _rc_model = ODESystem(rc_eqs, t0) #连接关系也需要放到ODESystem中

  # 组件与组件连接关系一起构建系统
  @named rc_model = compose(_rc_model,[turbine, condenser , pump, boiler ])

  # 系统化简
  @info "系统化简..."
  sys = structural_simplify(rc_model)
  #equations(sys) # 查看方程

  # 求解
  @info "创建仿真..."
  prob = ODAEProblem(sys, [0], (0, 0.0))
  #pnew = [600000.0, 4.0e6, 600.0]
  #prob = remake(prob, p = pnew)
  #println(prob.p)
  @info "仿真计算..."
  sol = solve(prob)

  @info "创建优化..."
      function obj_bl(t) # 优化目标函数
        @variables t 
         t_lower = 573.15
         t_upper = 973.15
         pnew = [sol[turbine.out.p][1], sol[boiler.out.p][1], max(t_lower, min(t,t_upper))]
         prob = remake(prob, p = pnew)
         sol = solve(prob)
         println("t = $t")
         h1 = CoolProp.PropsSI.("H", "T", sol[turbine.in.t][1], "P", sol[turbine.in.p][1],"Water" )
            -CoolProp.PropsSI.("H", "T", sol[turbine.out.t][1], "P", sol[turbine.out.p][1], "Water")
          
          return h1
      end
    ###############################################################################
    lower = 573.15
    upper = 973.15

    @info "开始优化..."
    #调用bboptimize函数进行优化
    res = bboptimize(obj_bl; SearchRange = (lower, upper), NumDimensions = 1, 
                     TraceMode = :silent, MaxSteps = 100, TraceEvery = 10,
                     Method=:de_rand_2_bin)
   
    
    # 打印优化结果摘要
    println(BlackBoxOptim.summary(res))
    # 
    # 获取最优解和最优值
    xopt = best_candidate(res)
    fopt = best_fitness(res)
    println("xopt = $xopt")
    println("fopt = $fopt")

    # 优化结果可视化
    prob = remake(prob, p=pnew)
    sol = solve(prob)
#################################################################################


  @info "系统评价..."
  table = OrderedDict("汽轮机入口压力(pa)" => sol[turbine.in.p][1],
  "汽轮机入口温度(k)" => sol[turbine.in.t][1],
  "汽轮机出口温度(k)" => sol[turbine.out.t][1],
  "锅炉入口温度(k)"=> sol[boiler.in.t][1],
  "锅炉出口压力(pa)"=> sol[boiler.out.p][1],
  "锅炉入口压力(pa)"=> sol[boiler.in.p][1])

  plot_sys = [pump, boiler, turbine, condenser];
  propx = :s
  propy = :t

  ss = [sol[getproperty(i.out, propx)][1] for i in plot_sys]
  tt = [sol[getproperty(i.out, propy)][1] for i in plot_sys]

  xAxis = collect(range(ss[1], ss[2], 15))
  yAxis = CoolProp.PropsSI.("T", "P", sol[pump.out.p], "S", collect(range(ss[1], ss[2], 15)), 工质)

  append!(xAxis,collect(range(ss[2], ss[3], 15)))
  append!(yAxis,collect(range(tt[2], tt[3], 15)))

  append!(xAxis,collect(range(ss[3], ss[4], 15)))
  append!(yAxis,CoolProp.PropsSI.("T", "P", sol[turbine.out.p], "S", collect(range(ss[3], ss[4], 15)), 工质))

  append!(xAxis,collect(range(ss[4], ss[1], 15)))
  append!(yAxis,collect(range(tt[4], tt[1], 15)))

  figure = transposeMatrix(xAxis, yAxis)
  #在本地绘图
  plot_local(figure)

  return figure,table
end


