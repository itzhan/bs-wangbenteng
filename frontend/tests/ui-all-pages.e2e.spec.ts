import { expect, test, type Page, type Response } from '@playwright/test';

const FRONTEND_BASE_URL = process.env.FRONTEND_BASE_URL || 'http://127.0.0.1:3000';
const ADMIN_BASE_URL = process.env.ADMIN_BASE_URL || 'http://127.0.0.1:3002';

const FRONTEND_USERNAME = process.env.FRONTEND_USERNAME || 'farmer01';
const FRONTEND_PASSWORD = process.env.FRONTEND_PASSWORD || '123456';
const ADMIN_USERNAME = process.env.ADMIN_USERNAME || 'admin';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '123456';

const TEST_SUFFIX = Date.now().toString();

function isApiMatch(response: Response, pathPart: string, method?: string) {
  const url = response.url();
  const req = response.request();
  const methodMatched = method ? req.method().toUpperCase() === method.toUpperCase() : true;
  return methodMatched && url.includes('/api/') && url.includes(pathPart);
}

async function waitForApiOk(page: Page, pathPart: string, method?: string) {
  const response = await page.waitForResponse((res) => isApiMatch(res, pathPart, method), {
    timeout: 20_000,
  });
  expect(response.status(), `${method || 'ANY'} ${pathPart} 响应状态`).toBeLessThan(400);
  let body: any = null;
  try {
    body = await response.json();
  } catch {
    body = null;
  }
  if (body && typeof body === 'object' && 'code' in body) {
    expect(body.code, `${method || 'ANY'} ${pathPart} 业务状态`).toBe(200);
  }
  return response;
}

async function waitForHeading(page: Page, text: string) {
  await expect(page.getByText(text, { exact: true })).toBeVisible();
}

async function loginFrontend(page: Page) {
  await page.goto(`${FRONTEND_BASE_URL}/login`);
  await waitForHeading(page, '用户登录');

  await page.getByPlaceholder('请输入用户名').fill(FRONTEND_USERNAME);
  await page.getByPlaceholder('请输入密码').fill(FRONTEND_PASSWORD);

  await Promise.all([
    waitForApiOk(page, '/auth/login', 'POST'),
    page.getByRole('button', { name: '登 录' }).click(),
  ]);

  await expect(page).toHaveURL(new RegExp(`${escapeForRegExp(FRONTEND_BASE_URL)}/?$`));
}

async function loginAdmin(page: Page) {
  await page.goto(`${ADMIN_BASE_URL}/login`);
  await expect(page.getByText('农作物种植生产管理系统')).toBeVisible();

  const accountInput = page.locator('input').first();
  const passwordInput = page.locator('input[type="password"]').first();

  await accountInput.fill(ADMIN_USERNAME);
  await passwordInput.fill(ADMIN_PASSWORD);

  await Promise.all([
    waitForApiOk(page, '/auth/login', 'POST'),
    page.getByRole('button', { name: '登录' }).first().click(),
  ]);

  await expect(page).toHaveURL(new RegExp(`${escapeForRegExp(ADMIN_BASE_URL)}/dashboard/base`));
}

async function selectFirstNaiveOptionByPlaceholder(page: Page, placeholder: string) {
  await page.getByPlaceholder(placeholder).first().click();
  await page.locator('.n-base-select-option:not(.n-base-select-option--disabled)').first().click();
}

async function selectFirstTSelectInDialog(page: Page, index: number) {
  const select = page.locator('.t-dialog .t-select').nth(index);
  await select.click();
  await page.locator('.t-select-option:not(.t-is-disabled)').first().click();
}

function escapeForRegExp(text: string) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

test.describe('用户端 UI 全页面验证', () => {
  test('公开页面渲染与后端交互', async ({ page }) => {
    await page.goto(`${FRONTEND_BASE_URL}/register`);
    await waitForHeading(page, '用户注册');

    await page.goto(`${FRONTEND_BASE_URL}/`);
    await waitForHeading(page, '农作物种植管理系统');

    await Promise.all([
      waitForApiOk(page, '/crops', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/crops`),
    ]);
    await waitForHeading(page, '作物品种');

    const cropCard = page.locator('.n-card').first();
    if (await cropCard.count()) {
      await Promise.all([
        waitForApiOk(page, '/crops/', 'GET'),
        cropCard.click(),
      ]);
      await expect(page.getByText('作物详情', { exact: true })).toBeVisible();
      await page.keyboard.press('Escape');
    }

    await Promise.all([
      waitForApiOk(page, '/announcements/published', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/announcements`),
    ]);
    await waitForHeading(page, '通知公告');

    const annCard = page.locator('.n-card').first();
    if (await annCard.count()) {
      await Promise.all([
        waitForApiOk(page, '/announcements/', 'GET'),
        annCard.click(),
      ]);
      await expect(page.getByText('公告详情', { exact: true })).toBeVisible();
      await page.keyboard.press('Escape');
    }

    await Promise.all([
      waitForApiOk(page, '/guidance', 'GET'),
      waitForApiOk(page, '/crops', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/guidance`),
    ]);
    await waitForHeading(page, '技术指导');
  });

  test('登录后页面渲染、数据传递与后端交互', async ({ page }) => {
    await loginFrontend(page);

    await Promise.all([
      waitForApiOk(page, '/plans/my', 'GET'),
      waitForApiOk(page, '/crops', 'GET'),
      waitForApiOk(page, '/plots/my', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/plans`),
    ]);
    await waitForHeading(page, '我的种植计划');

    await page.getByRole('button', { name: '新增计划' }).click();
    await page.getByPlaceholder('请输入计划名称').fill(`E2E计划-${TEST_SUFFIX}`);
    await selectFirstNaiveOptionByPlaceholder(page, '请选择作物');
    await page.getByRole('button', { name: '确定' }).click();
    await waitForApiOk(page, '/plans', 'POST');

    const planDetailBtn = page.getByRole('button', { name: '详情' }).first();
    if (await planDetailBtn.count()) {
      await Promise.all([
        waitForApiOk(page, '/plans/', 'GET'),
        planDetailBtn.click(),
      ]);
      await expect(page.getByRole('button', { name: '返回列表' })).toBeVisible();
      await Promise.all([
        waitForApiOk(page, '/plans/my', 'GET'),
        page.getByRole('button', { name: '返回列表' }).click(),
      ]);
    }

    await Promise.all([
      waitForApiOk(page, '/operations', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/operations`),
    ]);
    await waitForHeading(page, '农事操作记录');

    await Promise.all([
      waitForApiOk(page, '/inventory', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/inventory`),
    ]);
    await waitForHeading(page, '物资库存');

    await Promise.all([
      waitForApiOk(page, '/yields', 'GET'),
      waitForApiOk(page, '/plans/my', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/yields`),
    ]);
    await waitForHeading(page, '产量记录');

    await Promise.all([
      waitForApiOk(page, '/costs', 'GET'),
      waitForApiOk(page, '/plans/my', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/costs`),
    ]);
    await waitForHeading(page, '成本记录');

    await page.getByRole('button', { name: '新增记录' }).click();
    await selectFirstNaiveOptionByPlaceholder(page, '请选择计划');
    await selectFirstNaiveOptionByPlaceholder(page, '请选择费用类型');
    await page.getByPlaceholder('金额').fill('88');
    await page.getByRole('button', { name: '确定' }).click();
    await waitForApiOk(page, '/costs', 'POST');

    await Promise.all([
      waitForApiOk(page, '/dashboard', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/dashboard`),
    ]);
    await waitForHeading(page, '数据看板');

    await Promise.all([
      waitForApiOk(page, '/users/current', 'GET'),
      page.goto(`${FRONTEND_BASE_URL}/profile`),
    ]);
    await waitForHeading(page, '个人中心');

    const profileName = page.getByPlaceholder('真实姓名');
    await profileName.fill(`测试用户${TEST_SUFFIX.slice(-4)}`);
    await Promise.all([
      waitForApiOk(page, '/users/current/profile', 'PUT'),
      page.getByRole('button', { name: '保存修改' }).click(),
    ]);
  });
});

test.describe('管理端 UI 全页面验证', () => {
  test('登录后所有管理页面渲染、数据提交与后端交互', async ({ page }) => {
    await loginAdmin(page);

    await Promise.all([
      waitForApiOk(page, '/dashboard', 'GET'),
      waitForApiOk(page, '/inventory/warnings', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/dashboard/base`),
    ]);
    await expect(page.getByText('用户总数')).toBeVisible();

    await Promise.all([
      waitForApiOk(page, '/crops', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/crop/index`),
    ]);
    await expect(page.getByText('作物管理')).toBeVisible();
    await page.getByRole('button', { name: '新增作物' }).click();
    await page.getByPlaceholder('请输入作物名称').fill(`E2E作物-${TEST_SUFFIX}`);
    await page.getByPlaceholder('请输入品种').fill('测试品种A');
    await Promise.all([
      waitForApiOk(page, '/crops', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/plans', 'GET'),
      waitForApiOk(page, '/users', 'GET'),
      waitForApiOk(page, '/plots', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/plan/index`),
    ]);
    await expect(page.getByText('种植计划')).toBeVisible();
    await page.getByRole('button', { name: '新增计划' }).click();
    await page.getByPlaceholder('请输入计划名称').fill(`E2E管理计划-${TEST_SUFFIX}`);
    await selectFirstTSelectInDialog(page, 0);
    await selectFirstTSelectInDialog(page, 1);
    await Promise.all([
      waitForApiOk(page, '/plans', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/operations', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/operation/index`),
    ]);
    await expect(page.getByText('田间作业')).toBeVisible();

    await Promise.all([
      waitForApiOk(page, '/yields', 'GET'),
      waitForApiOk(page, '/plans', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/yield-cost/yield`),
    ]);
    await expect(page.getByText('产量记录')).toBeVisible();
    await page.getByRole('button', { name: '新增记录' }).click();
    await selectFirstTSelectInDialog(page, 0);
    await page.getByPlaceholder('请输入产量').fill('123');
    await Promise.all([
      waitForApiOk(page, '/yields', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/costs', 'GET'),
      waitForApiOk(page, '/plans', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/yield-cost/cost`),
    ]);
    await expect(page.getByText('成本记录')).toBeVisible();
    await page.getByRole('button', { name: '新增记录' }).click();
    await selectFirstTSelectInDialog(page, 0);
    await selectFirstTSelectInDialog(page, 1);
    await page.getByPlaceholder('请输入金额').fill('66');
    await Promise.all([
      waitForApiOk(page, '/costs', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/materials', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/material/index`),
    ]);
    await expect(page.getByText('农资信息')).toBeVisible();
    await page.getByRole('button', { name: '新增农资' }).click();
    await page.getByPlaceholder('请输入名称').fill(`E2E农资-${TEST_SUFFIX}`);
    await selectFirstTSelectInDialog(page, 0);
    await Promise.all([
      waitForApiOk(page, '/materials', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/inventory', 'GET'),
      waitForApiOk(page, '/materials', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/material/inventory`),
    ]);
    await expect(page.getByText('库存管理')).toBeVisible();
    await page.getByRole('button', { name: '入库/出库' }).click();
    await selectFirstTSelectInDialog(page, 0);
    await selectFirstTSelectInDialog(page, 1);
    await page.getByPlaceholder('请输入数量').fill('10');
    await Promise.all([
      waitForApiOk(page, '/inventory/operate', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/inventory/records', 'GET'),
      waitForApiOk(page, '/materials', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/material/records`),
    ]);
    await expect(page.getByText('库存记录')).toBeVisible();

    await Promise.all([
      waitForApiOk(page, '/announcements', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/content/announcement`),
    ]);
    await expect(page.getByText('公告管理')).toBeVisible();
    await page.getByRole('button', { name: '新增公告' }).click();
    await page.getByPlaceholder('请输入标题').fill(`E2E公告-${TEST_SUFFIX}`);
    await page.getByPlaceholder('请输入公告内容').fill('这是自动化测试创建的公告内容');
    await Promise.all([
      waitForApiOk(page, '/announcements', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/guidance', 'GET'),
      waitForApiOk(page, '/crops', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/content/guidance`),
    ]);
    await expect(page.getByText('技术指导')).toBeVisible();
    await page.getByRole('button', { name: '新增指导' }).click();
    await page.getByPlaceholder('请输入标题').fill(`E2E指导-${TEST_SUFFIX}`);
    await page.getByPlaceholder('请输入技术指导内容').fill('自动化测试指导内容');
    await Promise.all([
      waitForApiOk(page, '/guidance', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await Promise.all([
      waitForApiOk(page, '/logs', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/system/log`),
    ]);
    await expect(page.getByText('系统日志')).toBeVisible();

    await Promise.all([
      waitForApiOk(page, '/config', 'GET'),
      page.goto(`${ADMIN_BASE_URL}/system/config`),
    ]);
    await expect(page.getByText('系统配置')).toBeVisible();
    await page.getByRole('button', { name: '新增配置' }).click();
    await page.getByPlaceholder('请输入配置键').fill(`e2e.config.${TEST_SUFFIX}`);
    await page.getByPlaceholder('请输入配置值').fill('enabled');
    await Promise.all([
      waitForApiOk(page, '/config', 'POST'),
      page.getByRole('button', { name: '确定' }).last().click(),
    ]);

    await page.goto(`${ADMIN_BASE_URL}/user/index`);
    await expect(page.getByText('My Account')).toBeVisible();
  });
});
