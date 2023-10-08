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
      }，
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
      title: '工作台',
      icon: 'mdi:monitor-dashboard',
      order: 1
    }
  }],
  admin: [],
  user: []
};
