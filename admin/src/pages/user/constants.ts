export interface UserInfoListType {
  title: string;
  content: string;
  span?: number;
}

export interface ProductImageItem {
  key: string;
  alt: string;
  image: string;
}

export const USER_INFO_LIST: Array<UserInfoListType> = [
  {
    title: 'pages.user.personalInfo.desc.mobile',
    content: '+86 13800001234',
  },
  {
    title: 'pages.user.personalInfo.desc.phone',
    content: '020-88881234',
  },
  {
    title: 'pages.user.personalInfo.desc.email',
    content: 'farm.ops@example.com',
  },
  {
    title: 'pages.user.personalInfo.desc.seat',
    content: 'A区-农服中心-201',
  },
  {
    title: 'pages.user.personalInfo.desc.entity',
    content: '智慧农场运营中心',
  },
  {
    title: 'pages.user.personalInfo.desc.leader',
    content: '王主任',
  },
  {
    title: 'pages.user.personalInfo.desc.position',
    content: '农业运营主管',
  },
  {
    title: 'pages.user.personalInfo.desc.joinDay',
    content: '2022-03-15',
  },
  {
    title: 'pages.user.personalInfo.desc.group',
    content: '种植管理部/作业协同组/数字化运营小组',
    span: 6,
  },
];

export const GREETING_BANNER_URL =
  'https://images.unsplash.com/photo-1574691250077-03a929faece5?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHxyaWNlJTIwZmllbGR8ZW58MHx8fHwxNzYxODQzMzEyfDA&ixlib=rb-4.1.0&fit=fillmax&h=500&w=800';

export const PROFILE_AVATAR_URL =
  'https://images.unsplash.com/photo-1578526853808-674f81f8f499?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwyfHxyaWNlJTIwZmllbGR8ZW58MHx8fHwxNzYxODQzMzEyfDA&ixlib=rb-4.1.0&fit=fillmax&h=160&w=160';

export const TEAM_MEMBERS = [
  {
    avatar:
      'https://images.unsplash.com/photo-1492288991661-058aa541ff43?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHBvcnRyYWl0fGVufDB8fHx8MTc2MTg0MzM3M3ww&ixlib=rb-4.1.0&fit=fillmax&h=64&w=64',
    title: '李珊珊',
    description: '农事协调员',
  },
  {
    avatar:
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxOXx8cG9ydHJhaXR8ZW58MHx8fHwxNzYxODQzMzc5fDA&ixlib=rb-4.1.0&fit=fillmax&h=64&w=64',
    title: '赵一鸣',
    description: '数据分析师',
  },
  {
    avatar:
      'https://images.unsplash.com/photo-1578526853808-674f81f8f499?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwyfHxyaWNlJTIwZmllbGR8ZW58MHx8fHwxNzYxODQzMzEyfDA&ixlib=rb-4.1.0&fit=fillmax&h=64&w=64',
    title: '孙晨',
    description: '田块巡检员',
  },
  {
    avatar:
      'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwyfHx3b21hbiUyMHBvcnRyYWl0fGVufDB8fHx8MTc2MTg0MzM3M3ww&ixlib=rb-4.1.0&fit=fillmax&h=64&w=64',
    title: '周雨桐',
    description: '农资采购专员',
  },
];

export const PRODUCT_LIST: ProductImageItem[] = [
  {
    key: 'a',
    alt: '稻田监测',
    image:
      'https://images.unsplash.com/photo-1574691250077-03a929faece5?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHxyaWNlJTIwZmllbGR8ZW58MHx8fHwxNzYxODQzMzEyfDA&ixlib=rb-4.1.0&fit=fillmax&h=200&w=200',
  },
  {
    key: 'b',
    alt: '智能灌溉',
    image:
      'https://images.unsplash.com/photo-1578526853808-674f81f8f499?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwyfHxyaWNlJTIwZmllbGR8ZW58MHx8fHwxNzYxODQzMzEyfDA&ixlib=rb-4.1.0&fit=fillmax&h=200&w=200',
  },
  {
    key: 'c',
    alt: '大田管理',
    image:
      'https://images.unsplash.com/photo-1429087969512-1e85aab2683d?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHx3aGVhdCUyMGZpZWxkfGVufDB8fHx8MTc2MTg0MzM0MXww&ixlib=rb-4.1.0&fit=fillmax&h=200&w=200',
  },
  {
    key: 'd',
    alt: '温室种植',
    image:
      'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?ixid=M3w3MjUzNDh8MHwxfHNlYXJjaHwxfHxncmVlbmhvdXNlfGVufDB8fHx8MTc2MTg0MzM0OXww&ixlib=rb-4.1.0&fit=fillmax&h=200&w=200',
  },
];
