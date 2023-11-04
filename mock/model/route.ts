export const routeModel: Record<Auth.RoleType, AuthRoute.Route[]> = {
  super: [{
    name: 'dashboard',
    path: '/dashboard',
    component: 'basic',
    children: [
			{
        name: 'dashboard_analysis',
        path: '/dashboard/analysis',
        component: 'self',
        meta: {
          title: '蒸汽动力循环仿真',
          requiresAuth: true,
          icon: 'icon-park-outline:analysis'
        }
      },
      // {
      //   name: 'dashboard_workbench',
      //   path: '/dashboard/workbench',
      //   component: 'self',
      //   meta: {
      //     title: '风光煤气储',
      //     requiresAuth: true,
      //     icon: 'icon-park-outline:workbench',
      //   }
      // },
      // {
      //   name: 'dashboard_scenario',
      //   path: '/dashboard/scenario',
      //   component: 'self',
      //   meta: {
      //     title: '风光煤气氢储',
      //     requiresAuth: true,
      //     icon: 'icon-park-outline:editor',
      //   }
      // }
    ],
    meta: {
      title: '仿真',
      icon: 'mdi:monitor-dashboard',
      order: 1
    }
  },
	{
		name: 'optimization',
		path: '/optimization',
		component: 'basic',
		children: [
			{
        name: 'optimization_workbench',
        path: '/optimization/workbench',
        component: 'self',
        meta: {
          title: '第一个优化问题',
          requiresAuth: true,
          icon: 'icon-park-outline:analysis'
        }
      },

		],
		meta: {
			title: '优化',
			icon: 'icon-park-outline:workbench',
			order: 2
		}
	}],
  admin: [],
  user: []
};
