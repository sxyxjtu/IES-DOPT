const optimization: AuthRoute.Route = {
  name: 'optimization',
  path: '/optimization',
  component: 'basic',
  meta: { title: 'optimization', icon: 'mdi:menu' },
  children: [
    {
      name: 'optimization_workbench',
      path: '/optimization/workbench',
      component: 'self',
      meta: { title: 'optimization_workbench', icon: 'mdi:menu' }
    }
  ]
};

export default optimization;
