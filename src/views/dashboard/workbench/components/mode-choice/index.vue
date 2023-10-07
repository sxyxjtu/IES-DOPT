<template>
  <n-divider title-placement='center'>{{ props.title + props.description }}青海跨省跨区外送型新能源大基地项目</n-divider>

  <!-- 第一行 模式选择与经纬度-->
  <n-grid :x-gap='16' :y-gap='16' :item-responsive='true' class='pb-15px'>

    <n-grid-item span='0:24 640:24 1024:12'>
      <n-card :bordered='false' class='rounded-16px shadow-sm'>
        <p class='text-16px font-bold inline-block '>模式选择</p>
        <p class='text-16px text-red inline-block'> *</p>
        <!-- 在文字后面显示下拉框 -->
        <n-select v-model:value='modeChoosed' :options='modeOptions' style='' class='py-5px'
          @update:value="updateModeSelectData" />
      </n-card>
    </n-grid-item>

    <n-grid-item span='0:24 640:24 1024:12'>
      <n-card :bordered='false' class='rounded-16px shadow-sm'>
        <p class='text-16px font-bold inline-block '>地点经纬度(待开发)</p>
        <p class='text-16px text-red inline-block'> *</p>
        <n-space justify='space-between'>
          <n-input-number v-model:value='longitude' class='py-5px ' placeholder='0.0'>
            <template #prefix>经度</template>
          </n-input-number>
          <n-input-number v-model:value='latitude' class='py-5px' placeholder='0.0'>
            <template #prefix>纬度： <!-- prefix: 前缀 --></template>
          </n-input-number>
        </n-space>
      </n-card>
    </n-grid-item>

  </n-grid>

  <!-- 第二行 系统图片与参数输入 -->
  <n-grid :x-gap='16' :y-gap='16' :item-responsive='true' class='pb-15px'>
    <!-- 系统图片 -->
    <n-grid-item span='0:24 640:24 1024:12'>
      <n-card :bordered='false' class='rounded-16px shadow-sm'>
        <n-space justify='center'>
          <p class='text-28px font-bold pb-12px'>系统图</p>
        </n-space>
        <n-space v-for="(value, _) in modeOptions" justify='center'>
          <n-image v-if='modeChoosed == value.value' justify='center' :src="'/' + value.label + '.png'" alt="mode-choice"
            width="600" />
        </n-space>
      </n-card>
    </n-grid-item>
    <!-- 参数输入 -->
    <n-grid-item span='0:24 640:24 1024:12'>
      <n-card class='rounded-16px shadow-sm'>
        <n-tabs type='line' size='large' :tabs-padding='20' pane-style='padding: 20px;'>
          <n-tab-pane name='仿真计算参数输入'>
            <n-spin size="large" :show="isCalculating">
              <template #description>
                正在计算中，请稍等...
              </template>
              <n-collapse :accordion="true">
                <n-collapse-item v-for="(val, key, ind) in simulationParamsInput" :title='key' :name='ind' :disabled='((modeChoosed == 4) && (ind == 4 || ind == 3)) || ((modeChoosed == 5) && (ind == 4)) || ((modeChoosed == 6) && (ind == 3))
                  '>
                  <!-- 只有离网开启储能参数输入 -->
                  <n-space vertical justify='space-between' size='large' style='margin-bottom: 10px;'>
                    <n-input-number v-for="(val_input, key_input, _) in (val as { [key: string]: number; })"
                      v-model:value='val[key_input as keyof typeof val]' :placeholder='val_input.toString()'
                      :parse="parse" :format="format">
                      <template #prefix>{{ key_input }}： </template>
                    </n-input-number>
                  </n-space>
                </n-collapse-item>
                <n-divider></n-divider>
              </n-collapse>
              <n-button size='large' type='info' strong round style='width: 100%;' :on-click="simulateToServer">
                点击进行仿真计算
              </n-button>
            </n-spin>
          </n-tab-pane>

          <n-tab-pane name='优化计算参数输入'>
            <n-spin size="large" :show="isCalculating">
              <template #description>
                正在计算中，请稍等......
              </template>
              <n-gradient-text :size="16">选择待优化容量参数:</n-gradient-text>
              <n-select multiple placeholder="选择容量优化参数" v-model:options="isOptimizationOptions"
                v-model:value="isOptimizationGroup" style='margin-bottom: 15px;margin-top: 5px;' />
              <n-collapse :accordion="true">
                <n-collapse-item v-for="(val, key, ind) in simulationParamsInput" :title='key' :name='ind'
                  :disabled='((modeChoosed == 4) && (ind == 4 || ind == 3)) || ((modeChoosed == 5) && (ind == 4)) || ((modeChoosed == 6) && (ind == 3))'>
                  <n-space vertical justify='space-between' size='large' style='margin-bottom: 10px;'>
                    <n-input-number v-for="(_, key_input) in (val as { [key: string]: number; })"
                      v-model:value='val[key_input as keyof typeof val]' :parse="parse" :format="format">
                      <template #prefix>{{ key_input }}： </template>
                    </n-input-number>
                  </n-space>
                </n-collapse-item>
                <n-divider></n-divider>
              </n-collapse>
              <n-button size='large' type='info' strong round style='width: 100%;'
                :on-click="optimizeToServer">点击进行优化计算</n-button>
            </n-spin>
          </n-tab-pane>

        </n-tabs>
      </n-card>
    </n-grid-item>
  </n-grid>

  <!-- 第三行 外送通道约束 -->
  <n-card :bordered='false' class='rounded-16px shadow-sm'>
    <n-space justify='center'>
      <n-button round :on-click='excelExport' style='margin-top: 3px;'>导入数据</n-button>
      <p class='text-24px font-bold pb-12px'>外送通道负荷</p>
      <n-button round :on-click='jsonExport' style='margin-top: 3px;'>导出数据</n-button>
    </n-space>
    <div ref='powerlineRef' class='w-full h-640px' style="margin-top: 15px;"></div>
  </n-card>



  <n-divider title-placement='center'>
    结果输出
  </n-divider>
  <n-space vertical>
    <n-card :bordered='false' class='rounded-16px shadow-sm'>
      <n-space justify='center'>
        <p class='text-24px font-bold pb-12px'>系统小时运行图</p>
        <n-switch v-model:value="dayOrWeek" size="large" class='pt-15px' @update:value="updateSwich">
          <template #checked> 周数据图 </template>
          <template #unchecked> 日数据图 </template>
        </n-switch>
      </n-space>
      <n-slider v-if="!dayOrWeek" v-model:value="dayChoiceSlider" :step="1" :max="365" :min="1"
        :on-update:value="updateFigure" />
      <n-slider v-else v-model:value="dayChoiceSlider" :step="1" :max="52" :min="1" :on-update:value="updateFigure" />
      <div ref='lineRef' class='w-full h-640px' style="margin-top: 15px;"></div>
    </n-card>
    <n-card :bordered='false' class='rounded-16px shadow-sm'>
      <n-space justify='center'>
        <p class='text-24px font-bold pb-12px'>规模与经济性表</p>
        <n-button type='success' round :on-click='excelExport' style='margin-top: 3px;'>{{ tableData.length
        }}条数据，导出Excel表格</n-button>
      </n-space>
      <n-data-table :columns="tableColumns" :data='tableData' :pagination='{ pageSize: 10 }' :single-line='false' />
    </n-card>
  </n-space>
</template>

<script setup lang='ts'>
import { ref, Ref } from 'vue';
// import { watch } from 'vue';
import { type ECOption, useEcharts } from '@/composables';
import * as XLSX from 'xlsx';
import { useMessage, SelectOption } from 'naive-ui'
import { request } from '@/service/request/index';
import { isNull, range } from 'lodash-es';
// 定义子组件参数childrenParams，测试用，不影响主组件
// import fs from 'fs-extra';
const props = defineProps({
  title: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    default: ''
  },
});

const modeChoosed = ref<number>(7); //  1: 风光制氢余电上网 2: 风光制氢余电不上网 3: 离网制氢模式
// 经纬度数据
const longitude = ref<number>(0.0);
const latitude = ref<number>(0.0);
const dayOrWeek = ref<boolean>(false);

const isCalculating = ref<boolean>(false);
// 滑动条数据
const dayChoiceSlider = ref<number>(1);

// 模式选择选项
const modeOptions = [
  // {
  //   label: '风光储',
  //   value: 4
  // },
  // {
  //   label: '风光气储',
  //   value: 5
  // },
  // {
  //   label: '风光煤储',
  //   value: 6
  // },
  {
    label: '风光煤气储',
    value: 7
  },
];

//  检测到模式选择变化时，打印出来
//  watch(simulateOrOptimizeSwitch, (newValue, oldValue) => {
//    console.log('modeChoosed changed from', oldValue, 'to', newValue)
//  })

// echarts图表
const lineOptions = ref<ECOption>({
  //  显示工具箱
  toolbox: {
    show: true,
    orient: 'vertical',
    feature: {
      //  保存为图片，背景为白色
      saveAsImage: {
        show: true,
        type: 'png',
        pixelRatio: 4,
      },
      //  显示缩放按钮
      dataZoom: {
        show: true
      },
      //  显示类型切换按钮
      magicType: {
        show: true,
        type: ['stack', 'line', 'bar']
      },
      dataView: {
        show: true,                         // 是否显示该工具。
        title: '数据视图',
        readOnly: false,                    // 是否不可编辑（只读）
        lang: ['数据视图', '关闭', '刷新'],  // 数据视图上有三个话术，默认是['数据视图', '关闭', '刷新']
        backgroundColor: '#fff',             // 数据视图浮层背景色。
        textareaColor: '#fff',               // 数据视图浮层文本输入区背景色
        textareaBorderColor: '#333',         // 数据视图浮层文本输入区边框颜色
        textColor: '#000',                    // 文本颜色。
        buttonColor: '#c23531',              // 按钮颜色。
        buttonTextColor: '#fff',             // 按钮文本颜色。
      },
    }
  },
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross',
      label: {
        backgroundColor: '#6a7985'
      }
    }
  },
  legend: {
    data: ['下载量', '注册数']
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00', '22:00', '24:00'],
    name: '小时数',
    axisLabel: {
      formatter: '{value} h'
    }
  },
  yAxis: [
    {
      type: 'value',
      name: '能量',
      axisLabel: {
        formatter: '{value} kW'
      }
    }
  ],
  series: [
    {
      name: '下载量',
      type: 'line',
      smooth: true,
      stack: 'Total',
      areaStyle: {},
      emphasis: {
        focus: 'series'
      },
      data: [4623, 6145, 6268, 6411, 1890, 4251, 2978, 3880, 3606, 4311]
    },
    {
      name: '注册数',
      type: 'line',
      smooth: true,
      stack: 'Total',
      areaStyle: {},
      emphasis: {
        focus: 'series'
      },
      data: [2208, 2016, 2916, 4512, 8281, 2008, 1963, 2367, 2956, 678]
    }
  ]
}) as Ref<ECOption>;
const { domRef: lineRef } = useEcharts(lineOptions);

const powerLineJson = ref({
  winter: [3, 3, 3, 3, 3, 3, 3, 3, 5.6, 5.6, 5.6, 5.6, 5.6, 5.6, 5.6, 5.6, 5.6, 5.6, 3, 3, 3, 3, 3, 3].map((val) => {
    return val * 1000000;
  }),
  summer: [4, 4, 4, 4, 4, 4, 4, 5.6, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 4, 4, 4, 4].map((val) => {
    return val * 1000000;
  }),
})
const powerlineOptions = ref<ECOption>({
  //  显示工具箱
  toolbox: {
    show: true,
    orient: 'vertical',
    feature: {
      //  保存为图片，背景为白色
      saveAsImage: {
        show: true,
        type: 'png',
        pixelRatio: 4,
      },
      //  显示缩放按钮
      dataZoom: {
        show: true
      },
      dataView: {
        show: true,                         // 是否显示该工具。
        title: '数据视图',
        readOnly: false,                    // 是否不可编辑（只读）
        lang: ['数据视图', '关闭', '刷新'],  // 数据视图上有三个话术，默认是['数据视图', '关闭', '刷新']
        backgroundColor: '#fff',             // 数据视图浮层背景色。
        textareaColor: '#fff',               // 数据视图浮层文本输入区背景色
        textareaBorderColor: '#333',         // 数据视图浮层文本输入区边框颜色
        textColor: '#000',                    // 文本颜色。
        buttonColor: '#c23531',              // 按钮颜色。
        buttonTextColor: '#fff',             // 按钮文本颜色。
      },
    }
  },
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross',
      label: {
        backgroundColor: '#6a7985'
      }
    }
  },
  legend: {
    data: ['夏季曲线', '冬季曲线']
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: range(0, 24),
    name: '小时数',
    axisLabel: {
      formatter: '{value} h'
    }
  },
  yAxis: [
    {
      type: 'value',
      name: '能量',
      axisLabel: {
        formatter: '{value} kW'
      }
    }
  ],
  series: [
    {
      name: '冬季曲线',
      type: 'line',
      smooth: true,
      // stack: 'Total',
      // areaStyle: {},
      emphasis: {
        focus: 'series'
      },
      data: powerLineJson.value.winter
    },
    {
      name: '夏季曲线',
      type: 'line',
      smooth: true,
      // stack: 'Total',
      // areaStyle: {},
      emphasis: {
        focus: 'series'
      },
      data: powerLineJson.value.summer
    },
  ]
}) as Ref<ECOption>;
const { domRef: powerlineRef } = useEcharts(powerlineOptions);


// 表格数据类型
type TableData = {
  [key: string]: number
}

// 图表数据类型
type FigureData = {
  xAxis: Array<number>
  yAxis: {
    [key: string]: Array<number>
  }
}

// 后端接受数据类型
type BackEndData = {
  table: TableData
  figure: FigureData
}

// 仿真参数数据类型
type SimulationParams = {
  "光伏参数": {
    "装机容量（千瓦）": number,
    "综合效率": number,
    "产品寿命（年）": number,
    "投资成本（￥/kW）": number,
    "运维成本（￥/kW）": number,
    "替换成本（￥/kW）": number,
    "单位设备容量（kW）": number
  },
  "风电参数": {
    "装机容量（千瓦）": number,
    "综合效率": number,
    "产品寿命（年）": number,
    "投资成本（￥/kW）": number,
    "运维成本（￥/kW）": number,
    "替换成本（￥/kW）": number,
    "单位设备容量（kW）": number
  },
  "储能参数": {
    "装机容量（千瓦时）": number,
    "充能阈值": number,
    "产品寿命（年）": number,
    "投资成本（￥/kW）": number,
    "运维成本（￥/kW）": number,
    "替换成本（￥/kW）": number,
    "单位设备容量（kW）": number
  },
  "气电参数": {
    "装机容量（千瓦）": number,
    "发电效率": number,
    "产品寿命（年）": number,
    "投资成本（￥/kW）": number,
    "运维成本（￥/kW）": number,
    "替换成本（￥/kW）": number,
    "单位设备容量（kW）": number
  },
  "煤电参数": {
    "装机容量（千瓦）": number,
    "发电效率": number,
    "产品寿命（年）": number,
    "投资成本（￥/kW）": number,
    "运维成本（￥/kW）": number,
    "替换成本（￥/kW）": number,
    "单位设备容量（kW）": number
  },
  "经济性参数": {
    "系统运营年限（年）": number,
    "煤价格（￥/kg）": number,
    "卖电电价（￥/kwh）": number,
    "燃气价格（￥/Nm3）": number,
    "目标收益率": number,
    "综合税率": number,
    "折旧率": number,
    "煤电碳排放因子（kg/kWh）": number,
    "气电碳排放因子（kg/kWh）": number,
  }
}

const simulationParamsInput = ref<SimulationParams>({
  "光伏参数": {
    "装机容量（千瓦）": 4e6,
    "综合效率": 0.9,
    "产品寿命（年）": 20,
    "投资成本（￥/kW）": 3800,
    "运维成本（￥/kW）": 190,
    "替换成本（￥/kW）": 3800,
    "单位设备容量（kW）": 650
  },
  "风电参数": {
    "装机容量（千瓦）": 1e7,
    "综合效率": 0.9,
    "产品寿命（年）": 20,
    "投资成本（￥/kW）": 3800,
    "运维成本（￥/kW）": 190,
    "替换成本（￥/kW）": 3800,
    "单位设备容量（kW）": 650
  },
  "储能参数": {
    "装机容量（千瓦时）": 15000,
    "充能阈值": 0.9,
    "产品寿命（年）": 20,
    "投资成本（￥/kW）": 1500,
    "运维成本（￥/kW）": 190,
    "替换成本（￥/kW）": 1500,
    "单位设备容量（kW）": 650
  },
  "气电参数": {
    "装机容量（千瓦）": 4e6,
    "发电效率": 0.40,
    "产品寿命（年）": 25,
    "投资成本（￥/kW）": 4900,
    "运维成本（￥/kW）": 160,
    "替换成本（￥/kW）": 4900,
    "单位设备容量（kW）": 1000
  },
  "煤电参数": {
    "装机容量（千瓦）": 4e6,
    "发电效率": 0.38,
    "产品寿命（年）": 25,
    "投资成本（￥/kW）": 15300,
    "运维成本（￥/kW）": 248,
    "替换成本（￥/kW）": 15300,
    "单位设备容量（kW）": 1000
  },

  "经济性参数": {
    "系统运营年限（年）": 20,
    "煤价格（￥/kg）": 0.727,
    "卖电电价（￥/kwh）": 0.228,
    "燃气价格（￥/Nm3）": 1.7,
    "目标收益率": 0.05,
    "综合税率": 0.0,
    "折旧率": 0.05,
    "煤电碳排放因子（kg/kWh）": 1.0,
    "气电碳排放因子（kg/kWh）": 0.5,
  }
});

const isOptimizationGroup = ref<Array<number>>([2])
const optimizationTime = ref<number>(1)
const isOptimizationOptions = ref([
  {
    label: '光伏容量',
    value: 0
  },
  {
    label: '风电容量',
    value: 1
  },
  {
    label: "储能容量",
    value: 2
  },
  {
    label: '气电容量',
    value: 3,
    disabled: false
  },
  {
    label: '煤电容量',
    value: 4,
    disabled: false
  }
])

// 监测isOptimizationGroup的值是否改变
// watch(isOptimizationGroup, (val) => {
//   console.log(val)
// })

// 表格头部数据
const tableColumns = ref<Array<{ title: string, key: string }>>([]);
const tableData = ref<TableData[]>([]) // 表格数据
const figureData = ref<FigureData>({ xAxis: [], yAxis: {} }) // 图数据

// 模式选择数据更新
function updateModeSelectData(value: number, options: SelectOption) {
  if (value == 4) {
    isOptimizationOptions.value[3].disabled = true;
    isOptimizationOptions.value[4].disabled = true;
  }
  else if (value == 5) {
    isOptimizationOptions.value[3].disabled = false;
    isOptimizationOptions.value[4].disabled = true;
  }
  else if (value == 6) {
    isOptimizationOptions.value[3].disabled = true;
    isOptimizationOptions.value[4].disabled = false;
  }
  else {
    isOptimizationOptions.value[3].disabled = false;
    isOptimizationOptions.value[4].disabled = false;
  };
  tableData.value = [];
}

// 更新表格数据
const updateFigure = (dayValue: number) => {
  dayChoiceSlider.value = dayValue;
  let dataRange = dayOrWeek.value ? 24 * 7 : 24;
  lineOptions.value.xAxis = {
    type: 'category',
    data: figureData.value.xAxis.slice((dayValue - 1) * dataRange, dayValue * dataRange),
    name: '小时数',
    axisLabel: {
      formatter: '{value} h'
    }
  };
  lineOptions.value.legend = {
    data: Object.keys(figureData.value.yAxis)
  };
  lineOptions.value.series = Object.keys(figureData.value.yAxis).map((key) => {
    return {
      name: key,
      type: 'line',
      smooth: true,
      stack: 'Total',
      areaStyle: {},
      emphasis: {
        focus: 'series'
      },
      data: figureData.value.yAxis[key].slice((dayValue - 1) * dataRange, dayValue * dataRange)
    }
  });
}

const updateSwich = (value: boolean) => {
  dayOrWeek.value = value;
  updateFigure(dayChoiceSlider.value);
}
const message = useMessage();

// 从后端获取数据
function simulateToServer() {
  // let gasCapacity = simulationParamsInput.value["气电参数"]["装机容量（千瓦）"];
  // let coalCapacity = simulationParamsInput.value["煤电参数"]["装机容量（千瓦）"];
  // if (gasCapacity + coalCapacity < 8e6) {
  //   message.error('外送通道约束：气电、煤电总装机容量至少为 8,000,000 kW');
  //   return;
  // }
  isCalculating.value = true;
  request.post('/simulation', {
    "inputdata": simulationParamsInput.value,
    "mode": modeChoosed.value
  }).then((response) => {
    isCalculating.value = false;
    if (!isNull(response.error)) {
      message.error('计算失败');
      return;
    }
    // window.$message.success('仿真成功');
    message.success('计算成功');
    let backEndData = response.data as BackEndData;
    tableData.value.push(backEndData.table);
    tableColumns.value = Object.keys(backEndData.table).map((key, i) => {
      return {
        title: key,
        key: key,
        width: 80,
        resizable: true,
        maxWidth: 200,
      }
    });
    figureData.value = backEndData.figure;
    updateFigure(dayChoiceSlider.value);
  }, (error) => {
    console.log(error);
  });
};



function optimizeToServer() {
  let isOptimizationList = Object.values(isOptimizationOptions.value).map((val) => {
    // 如果选择了该优化参数，则isOptimizationGroup中含有该数值，返回该数值的索引，不存在找不到则返回-1
    return isOptimizationGroup.value.indexOf(val.value) > -1 ? 1 : 0;
  });
  let gasCapacity = simulationParamsInput.value["气电参数"]["装机容量（千瓦）"];
  let coalCapacity = simulationParamsInput.value["煤电参数"]["装机容量（千瓦）"];
  if (gasCapacity + coalCapacity < 8e6 && isOptimizationList[3] == 0 && isOptimizationList[4] == 0) {
    message.error('外送通道约束：气电、煤电总装机容量至少为 8,000,000 kW');
    return;
  }
  isCalculating.value = true;
  // 不同模式下，优化参数不同，进行筛选
  if (modeChoosed.value == 4) {
    isOptimizationList.filter((_, index) => { return index <= 2 });
  }
  else if (modeChoosed.value == 5) {
    isOptimizationList.filter((_, index) => { return index <= 3 });
  }
  else if (modeChoosed.value == 6) {
    isOptimizationList.filter((_, index) => { return index != 3 });
  }

  request.post('/optimization', {
    "inputdata": Object.assign({}, simulationParamsInput.value, { "优化时长": optimizationTime.value }),
    "mode": modeChoosed.value,
    "isopt": isOptimizationList
  }).then((response) => {
    isCalculating.value = false;
    if (!isNull(response.error)) {
      message.error('计算失败');
      return;
    }
    message.success('计算成功');
    let backEndData = response.data as BackEndData;
    tableData.value.push(backEndData.table);
    tableColumns.value = Object.keys(backEndData.table).map((key) => {
      return {
        title: key,
        key: key,
        width: 80,
        resizable: true,
        maxWidth: 200,
      }
    });
    figureData.value = backEndData.figure;
    updateFigure(dayChoiceSlider.value);
  }, (error) => {
    console.log(error);
  });
}

// 输入框格式化
const format = (value: number | null) => {
  if (value === null) return ''
  return value.toLocaleString('en-US')
};
const parse = (input: string) => {
  const nums = input.replace(/,/g, '').trim()
  if (/^\d+(\.(\d+)?)?$/.test(nums)) return Number(nums)
  return nums === '' ? null : Number.NaN
};

// 导出excel
function excelExport() {

  //  const worksheet = XLSX.utils.aoa_to_sheet(excleData);
  const worksheet = XLSX.utils.json_to_sheet(tableData.value);

  //  设置每列的列宽，10代表10个字符，注意中文占2个字符
  worksheet['!cols'] = Object.keys(tableData.value[0]).map(() => {
    return {
      wpx: 100,
      alignment: {
        wrapText: true
      }
    }
  });

  //  新建一个工作簿,创建虚拟workbook
  const workbook = XLSX.utils.book_new();

  /* 将工作表添加到工作簿,生成xlsx文件(book,sheet数据,sheet命名)*/
  XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');

  /* 输出工作表， 由文件名决定的输出格式(book,xlsx文件名称)*/
  let name = Date().split(" ").slice(3, 5).join("_") + '_规模与经济性表.xlsx';
  XLSX.writeFile(workbook, name);

  return 0;
};

// 导出json数据函数
function jsonExport() {
  // 定义 JSON 数据
  // 将 JSON 数据转换为字符串，并采用pretty print的格式展示
  const json = JSON.stringify(powerLineJson.value, null, 2);

  // 创建 Blob 对象
  const blob = new Blob([json], { type: 'application/json' });

  // 创建 URL
  const url = URL.createObjectURL(blob);

  // 创建 a 标签
  const link = document.createElement('a');
  link.href = url;
  link.download = 'data.json';

  // 模拟点击 a 标签
  link.click();

  // 释放 URL
  URL.revokeObjectURL(url);
}

</script>

<style scoped></style>
